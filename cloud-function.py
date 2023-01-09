from google.cloud import storage
import numpy as np
import openpyxl
import json
import random
from pymagnitude import Magnitude
from sudachipy import tokenizer, dictionary


POSTPOSITONAL_PARTICLE = "助詞"

def hello_world(request):

    request_json = request.get_json()
    if request.args and 'message' in request.args:
        return request.args.get('message')
    elif request_json and 'message' in request_json:
        return request_json['message']
    else:

        model, meigen_vecs, meigen_list = load_tools()
        tokenizer_obj = dictionary.Dictionary().create()
        schedule = request_json['schedule']
        plan = request_json['plan']

        schedule_with_similar_words = schedule
        if plan == "premium":
          schedule_with_similar_words = generate_schedule_with_similar_words(model, tokenizer_obj, schedule)
        
        schedule_vec = word2vector(model, tokenizer_obj, schedule_with_similar_words)

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
            
        most_fit_meigen = ((meigen_list["Sheet1"]).cell(int(max_index)+1, 2)).value
        
        return json.dumps({"most_fit_meigen": most_fit_meigen}, ensure_ascii=False)

def word2vector(model, tokenizer_obj, sentence, unknowns=[]):

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


def load_tools():
    storage_client = storage.Client()
    bucket = storage_client.get_bucket('gcf-sources-1048067232771-us-central1')

    blob = bucket.get_blob('chive-1.2-mc90.magnitude')
    blob.download_to_filename("/tmp/chive-1.2-mc90.magnitude")
  
    blob = bucket.get_blob('meigen_list.xlsx')
    blob.download_to_filename("/tmp/meigen_list.xlsx")

    blob = bucket.get_blob('meigen_vecs_chiVe.npz')
    blob.download_to_filename("/tmp/meigen_vecs_chiVe.npz")

    model = Magnitude("/tmp/chive-1.2-mc90.magnitude")
    meigen_vecs = np.load("/tmp/meigen_vecs_chiVe.npz")
    meigen_list = openpyxl.load_workbook("/tmp/meigen_list.xlsx")

    return model, meigen_vecs, meigen_list

def generate_schedule_with_similar_words(model, tokenizer_obj, schedule):
  
  schedule_with_similar_words = schedule
  ms = tokenizer_obj.tokenize(schedule)

  for m in ms:
    if m.part_of_speech()[0] != POSTPOSITONAL_PARTICLE:
        w = m.surface()
        if w == 'word ''':
          continue
        try:
          for sm in model.most_similar(w, topn=4):
            schedule_with_similar_words  += sm[0]
        except KeyError as e:
          print(e)

  return schedule_with_similar_words