#!/usr/bin/env python
# -*- coding: utf-8 -*-

import gensim
from gensim.models import Word2Vec
from gensim.models import KeyedVectors

'''
all_clear[_lemmatized].txt: medical comparable corpus [lemmatized] (encyclopedia articles, drug leaflets, cochrane summaries)
all_clear2.text: medical + general language comparable corpus (encyclopedia articles, drug leaflets, cochrane summaries + encyclopedia articles)
'''

model_clear = Word2Vec(corpus_file="all_clear.txt", vector_size=500, window=7, sample=1e-5, hs=1, negative=50, min_count=20, alpha=0.025, cbow_mean=0) #medical (cbow)
model_clear.save("clear.500.model")
model_clear = Word2Vec(corpus_file="all_clear_lemmatized.txt", vector_size=500, window=7, sample=1e-5, hs=1, negative=50, min_count=20, alpha=0.025) #medical lemmatized (cbow)
model_clear.save("clear.500_lem.model")

model_clear = Word2Vec(corpus_file="all_clear2.txt", vector_size=500, window=7, sample=1e-5, hs=1, negative=50, min_count=20, alpha=0.025, cbow_mean=0) #medical + general (cbow)
model_clear.save("all_clear.500.model")

model_clear = Word2Vec(corpus_file="all_clear.txt", sg=1, vector_size=500, window=7, sample=1e-5, hs=1, negative=50, min_count=20, alpha=0.025) #medical (skip)
model_clear.save("skip_clear.500.model")
model_clear = Word2Vec(corpus_file="all_clear_lemmatized.txt", sg=1, vector_size=500, window=7, sample=1e-5, hs=1, negative=50, min_count=20, alpha=0.025) #medical lemmatized (skip)
model_clear.save("skip_clear.500_lem.model")

model_clear = Word2Vec(corpus_file="all_clear2.txt", sg=1, vector_size=500, window=7, sample=1e-5, hs=1, negative=50, min_count=20, alpha=0.025) #medical + general (skip)
model_clear.save("skip_all_clear.500.model")

model = model_clear.wv
print(model.vectors.shape)
