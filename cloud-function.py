import MeCab
from google.cloud import storage
import gensim
import numpy as np
import openpyxl
import json
import markovify
import random

def hello_world(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    request_json = request.get_json()
    if request.args and 'message' in request.args:
        return request.args.get('message')
    elif request_json and 'message' in request_json:
        return request_json['message']
    elif request_json and 'new_meigen' in request_json:
        recipe_markov = {}
        size = 3
        mecab = MeCab.Tagger()
        mecab = MeCab.Tagger("")
        mecab.parse("")

        recipes = {}
        
        with open('./recipe.txt', encoding="utf-8_sig") as f:
          for line in f:
            meigen_of_recipe = ""
            
            data = ["BEGIN","BEGIN"]

            node = mecab.parseToNode(line).next
            while node.next:
                data.append(node.surface)
                meigen_of_recipe += node.surface
                node = node.next

            data.append("END")
            recipes[meigen_of_recipe] = 1

            for i in range(len(data)-size+1):
              value = data[i+size-1] # 最後の要素だけ取り出す
              key = tuple(data[i:i+size-1])

              if key not in recipe_markov.keys():
                recipe_markov[key] = []
              recipe_markov[key].append(value)

          while True:
            key = tuple(["BEGIN","BEGIN"])
            new_meigen = ""
            # indexes = []

            while True: 
              length = len(recipe_markov[key])
              key = tuple([key[1] , recipe_markov[key][random.randint(0, length-1)]])

              if key[0] != "BEGIN":
                new_meigen += key[0]
              if key[1] == "END":
                break

            if recipes.get(new_meigen) is None:
              # 原文とかぶってない     
              return json.dumps(new_meigen, ensure_ascii=False)
    else:

        model, meigen_vecs, meigen_list = load_tools()
        mecab=MeCab.Tagger('-Owakati')
        schedules = request_json['schedules']
        most_fit_meigens = []

        for schedules_per_user in schedules:
          most_fit_meigens_per_person = []
          for schedule in schedules_per_user:

            schedule_with_similar_words = generate_schedule_with_similar_words(model, mecab, schedule)
            schedule_vec = text2vector(model, mecab, schedule_with_similar_words)

            if schedule_vec is not None:
              max_similarity_score = 0
              max_index = 0
              for i, vec_key in enumerate(meigen_vecs.files):
                meigen_vec = meigen_vecs[vec_key]
                if max_similarity_score < cos_similarity(schedule_vec, meigen_vec.T):
                  max_similarity_score = cos_similarity(schedule_vec, meigen_vec.T)
                  max_index = i
                
              most_fit_meigen = ((meigen_list["Sheet1"]).cell(int(max_index)+1, 2)).value
              most_fit_meigens_per_person.append(most_fit_meigen)
              
          most_fit_meigens.append(most_fit_meigens_per_person)
        
        return json.dumps(most_fit_meigens, ensure_ascii=False)

def text2vector(model, mecab, sentence, unknowns=[]):
    """
    文章ベクトルを求める関数。
    300次元のベクトルを返す。未知の単語で文章ベクトルが求められないときはNoneを返す。
    @param sentence 文章
    @param unknowns 辞書にない不明な語があったら格納する配列。呼び出しもとから渡すこと。Noneなら何もしない。
    """
    _sv = np.empty((0,300), np.float32)
    for w in mecab.parse(sentence).split():
        if len(w) <= 1:
          continue
        try:
          wv = model[w]
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

    blob = bucket.get_blob('model.vec')
    blob.download_to_filename("/tmp/model.vec")
    blob = bucket.get_blob('meigen_list.xlsx')
    blob.download_to_filename("/tmp/meigen_list.xlsx")
    blob = bucket.get_blob('meigen_vecs.npz')
    blob.download_to_filename("/tmp/meigen_vecs.npz")

    model = gensim.models.KeyedVectors.load_word2vec_format("/tmp/model.vec", binary=False)
    meigen_vecs = np.load("/tmp/meigen_vecs.npz")
    meigen_list = openpyxl.load_workbook("/tmp/meigen_list.xlsx")

    return model, meigen_vecs, meigen_list

def generate_schedule_with_similar_words(model, mecab, schedule):
  
  schedule_with_similar_words = schedule

  mm_list = mecab.parse(schedule).split()
  for mm in mm_list:
    if len(mm) <= 1:
      # 助詞はskip
      continue     
    for sm in model.most_similar(mm, topn=4):
      schedule_with_similar_words  += sm[0]

  return schedule_with_similar_words