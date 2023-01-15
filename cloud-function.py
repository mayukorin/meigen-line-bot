from google.cloud import storage
import numpy as np
import openpyxl
import json
import random
from pymagnitude import Magnitude
from sudachipy import tokenizer, dictionary


POSTPOSITONAL_PARTICLE = '助詞'

def hello_world(request):

    request_json = request.get_json()
    if request_json and 'schedule' in request_json and 'plan' in request_json:
        model, meigen_vecs, meigen_list = load_tools()
        schedule = request_json['schedule']
        plan = request_json['plan']

        schedule_with_similar_words = schedule
        if plan == 'premium':
          schedule_with_similar_words = generate_schedule_with_similar_words(model, schedule)
        
        schedule_vec = calc_schedule_vec(model, schedule_with_similar_words)

        most_fit_meigen = calc_most_fit_meigen(schedule_vec, meigen_vecs, meigen_list)
        
        return json.dumps({'most_fit_meigen': most_fit_meigen}, ensure_ascii=False)
    else:
      return 'nothing'


def load_tools():
    storage_client = storage.Client()
    bucket = storage_client.get_bucket('gcf-sources-1048067232771-us-central1')

    word2_vec_model = load_word2_vec_model(bucket)
    meigen_vecs = load_meigen_vecs(bucket)
    meige_list = load_meigen_list(bucket)

    return model, meigen_vecs, meigen_list

def load_meigen_vecs(bucket):
  blob = bucket.get_blob('meigen_vecs_chiVe.npz')
  blob.download_to_filename('/tmp/meigen_vecs_chiVe.npz')
  meigen_vecs = np.load('/tmp/meigen_vecs_chiVe.npz')

  return meigen_vecs

def load_meigen_list(bucket):
  blob = bucket.get_blob('meigen_list.xlsx')
  blob.download_to_filename('/tmp/meigen_list.xlsx')
  meigen_list = openpyxl.load_workbook('/tmp/meigen_list.xlsx')

  return meigen_list

def load_word2_vec_model(bucket):
  blob = bucket.get_blob('chive-1.2-mc90.magnitude')
  blob.download_to_filename('/tmp/chive-1.2-mc90.magnitude')
  word2_vec_model = Magnitude('/tmp/chive-1.2-mc90.magnitude')

  return word2_vec_model

def generate_schedule_with_similar_words(model, schedule):

  tokenizer_obj = dictionary.Dictionary().create()
  ms = tokenizer_obj.tokenize(schedule)

  schedule_with_similar_words = schedule

  for m in ms:
    if m.part_of_speech()[0] != POSTPOSITONAL_PARTICLE:
        w = m.surface()
        try:
          for sm in model.most_similar(w, topn=4):
            schedule_with_similar_words += sm[0]
        except KeyError as e:
          print(e)

  return schedule_with_similar_words


def calc_schedule_vec(model, sentence, unknowns=[]):

    tokenizer_obj = dictionary.Dictionary().create()
    ms = tokenizer_obj.tokenize(sentence)

    _sv = np.empty((0,300), np.float32)
    for m in ms:
      if not m.part_of_speech()[0].endswith(POSTPOSITONAL_PARTICLE):
        w = m.surface()
        try:
          wv = model.query(w)
          _sv = np.append(_sv, np.array([wv]), axis=0) 
        except KeyError:
          if w not in unknowns:
            unknowns.append(w)
    if _sv.shape[0]>0:
      return np.array([np.average(_sv, axis = 0)]) # 類似度で重み付き平均にしてもよいかも
    else:
      print('Ignore sentence', sentence)
      return None

def cos_similarity(v1, v2):
    return np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))

def calc_most_fit_meigen(schedule_vec, meigen_vecs, meigen_list):

  if schedule_vec is not None:
    max_similarity_score = 0
    max_index = 0
    for i, vec_key in enumerate(meigen_vecs.files):
      meigen_vec = meigen_vecs[vec_key]
      if max_similarity_score < cos_similarity(schedule_vec, meigen_vec.T):
        max_similarity_score = cos_similarity(schedule_vec, meigen_vec.T)
        max_index = i
  else:
    max_index = 0
  
  most_fit_meigen = ((meigen_list['Sheet1']).cell(int(max_index)+1, 2)).value

  return most_fit_meigen