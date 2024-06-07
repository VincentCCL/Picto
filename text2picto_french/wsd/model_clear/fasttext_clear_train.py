#!/usr/bin/env python
# -*- coding: utf-8 -*-

import gensim
import fasttext
import fasttext.util

'''
all_clear[_lemmatized].txt: medical comparable corpus [lemmatized] (encyclopedia articles, drug leaflets, cochrane summaries)
all_clear2.text: medical + general language comparable corpus (encyclopedia articles, drug leaflets, cochrane summaries + encyclopedia articles)
'''

ft_cbow = fasttext.train_unsupervised('all_clear.txt', model='cbow', dim=500) #medical (cbow)
ft_cbow.save_model("ft_cbow_clear_500.bin")
print(ft_cbow.get_dimension())
ft_cbow = fasttext.train_unsupervised('all_clear_lemmatized.txt', model='cbow', dim=500) #medical lemmatized (cbow)
ft_cbow.save_model("ft_cbow_clear_lem_500.bin")
print(ft_cbow.get_dimension())

ft_cbow2 = fasttext.train_unsupervised('all_clear2.txt', model='cbow', dim=500) #medical + general (cbow)
ft_cbow2.save_model("ft_cbow_all_clear_500.bin")
print(ft_cbow2.get_dimension())

ft_skip = fasttext.train_unsupervised('all_clear.txt', model='skipgram', dim=500) #medical (skip)
ft_skip.save_model("ft_skip_clear_500.bin")
print(ft_skip.get_dimension())
ft_skip = fasttext.train_unsupervised('all_clear_lemmatized.txt', model='skipgram', dim=500) #medical lemmatized (skip)
ft_skip.save_model("ft_skip_clear_lem_500.bin")
print(ft_skip.get_dimension())

ft_skip2 = fasttext.train_unsupervised('all_clear2.txt', model='skipgram', dim=500) #medical + general (skip)
ft_skip2.save_model("ft_skip_all_clear_500.bin")
print(ft_skip2.get_dimension())
