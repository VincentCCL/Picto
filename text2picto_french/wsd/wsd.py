#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
By Magali Norré
Date: 06.01.2023
Version with decreasing cosine similarity (rank > 1)
'''

from sys import exit
import numpy
import pandas as pd
import re

import psycopg2 #postgresql from https://www.psycopg.org/docs/usage.html
from more_itertools import unique_everseen

from gensim.models import KeyedVectors

import fasttext
import fasttext.util

import torch
from transformers import CamembertForMaskedLM, AutoTokenizer, AutoConfig
from transformers import FlaubertModel, FlaubertTokenizer
from transformers import AutoModelForMaskedLM #drbert/camembert-bio

#from transformers import MarianMTModel, MarianTokenizer #if Marian-NMT for get_usage (english->french)

#0) Load models

choice_models = {
    1: '1a | Word2Vec - frWac2Vec cbow size=500 vocab=150252',
    2: '1b | Word2Vec - frWac2Vec skip size=500 vocab=119227',
    3: '2a | Word2Vec - frWiki2Vec cbow size=500 vocab=66819',    
    4: '3ab | Word2Vec - CLEAR medical + general cbow/skip size=500/300 vocab=198164',
    5: '4ab | Word2Vec - CLEAR medical cbow/skip size=500/300 vocab=79456',
    6: '5a | fastText - CC/Wiki cbow size=300 vocab=?',
    7: '6a | fastText - CLEAR medical + general cbow size=500/300/100 vocab=198164',
    8: '6b | fastText - CLEAR medical + general skip size=500/300/100 vocab=198164',
    9: '7a | fastText - CLEAR medical cbow size=500/300/100 vocab=79456',
    10: '7b | fastText - CLEAR medical skip size=500/300/100 vocab=79456',
    11: '8ABCDEF | CamemBERT - base/large size=768/1024',
    12: '9ABCD | FlauBERT - base/large/small size=768/1024/512',
    13: '10ABCD | DrBERT - base size=768',
    14: '11A | CamemBERT-bio - base size=768',
    15: 'Exit'
}

def print_menu():
    for key in choice_models.keys():
        print (key, '--', choice_models[key])

print_menu()
option = ''

try:
    option = int(input('Enter your choice: '))
except:
    print('Wrong input. Please enter a number...')

if option == 1: #1a
    model = KeyedVectors.load_word2vec_format("model_frwac2vec-frwiki2vec/6_frWac_no_postag_no_phrase_500_cbow_cut100.bin", binary=True, unicode_errors="ignore") #1a
    #model = KeyedVectors.load_word2vec_format("model_frwac2vec-frwiki2vec/1_frWac_non_lem_no_postag_no_phrase_200_cbow_cut0.bin", binary=True, unicode_errors="ignore")
    
    '''
    model_frwac2vec-frwiki2vec/
    1_frWac_non_lem_no_postag_no_phrase_200_cbow_cut0.bin | 2_frWac_non_lem_no_postag_no_phrase_200_cbow_cut100.bin | 3_frWac_non_lem_no_postag_no_phrase_200_skip_cut100.bin | 4_frWac_non_lem_no_postag_no_phrase_500_skip_cut100.bin
    5_frWac_non_lem_no_postag_no_phrase_500_skip_cut200.bin | #6_frWac_no_postag_no_phrase_500_cbow_cut100.bin | #7_frWac_no_postag_no_phrase_500_skip_cut100.bin | 8_frWac_no_postag_no_phrase_700_skip_cut50.bin
    #9_frWac_postag_no_phrase_700_skip_cut50.bin | #10_frWac_postag_no_phrase_1000_skip_cut100.bin | 11_frWac_no_postag_phrase_500_cbow_cut10.bin | 12_frWac_no_postag_phrase_500_cbow_cut100.bin
    '''    
    
elif option == 2: #1b
    model = KeyedVectors.load_word2vec_format("model_frwac2vec-frwiki2vec/7_frWac_no_postag_no_phrase_500_skip_cut100.bin", binary=True, unicode_errors="ignore") #1b

elif option == 3: #2a
    model = KeyedVectors.load_word2vec_format("model_frwac2vec-frwiki2vec/17_frWiki_no_phrase_no_postag_500_cbow_cut10.bin", binary=True, unicode_errors="ignore") #2a
    #model = KeyedVectors.load_word2vec_format("model_frwac2vec-frwiki2vec/20_frWiki_no_phrase_no_postag_1000_skip_cut200.bin", binary=True, unicode_errors="ignore")

    '''
    model_frwac2vec-frwiki2vec/
    13_frWiki_no_lem_no_postag_no_phrase_1000_cbow_cut100.bin | 14_frWiki_no_lem_no_postag_no_phrase_1000_skip_cut100.bin | 15_frWiki_no_lem_no_postag_no_phrase_1000_cbow_cut200.bin | 16_frWiki_no_lem_no_postag_no_phrase_1000_skip_cut200.bin
    #17_frWiki_no_phrase_no_postag_500_cbow_cut10.bin | 18_frWiki_no_phrase_no_postag_700_cbow_cut100.bin | 19_frWiki_no_phrase_no_postag_1000_skip_cut100.bin | 20_frWiki_no_phrase_no_postag_1000_skip_cut200.bin
    '''

elif option == 4: #3a
    model = KeyedVectors.load("model_clear/cbow_all_clear.500.model") #3a
    #model = KeyedVectors.load("model_clear/cbow_all_clear.300.model") #3a'
    #model = KeyedVectors.load("model_clear/skip_all_clear.500.model") #3b
    #model = KeyedVectors.load("model_clear/skip_all_clear.300.model") #3b'
    model = model.wv
elif option == 5: #4a
    model = KeyedVectors.load("model_clear/cbow_clear.500.model") #4a
    #model = KeyedVectors.load("model_clear/cbow_clear.300.model") #4a'
    #model = KeyedVectors.load("model_clear/skip_clear.500.model") #4b
    #model = KeyedVectors.load("model_clear/skip_clear.300.model") #4b'
    model = model.wv
elif option == 6: #5a
    model = fasttext.load_model('model_cc-fr/cc.fr.300.bin') #5a
elif option == 7: #6a|6a'
    model = fasttext.load_model('model_clear/ft_cbow_all_clear_500.bin') #6a
    #model = fasttext.load_model('model_clear/ft_cbow_all_clear_300.bin') #6a'
    #model = fasttext.load_model('model_clear/ft_cbow_all_clear_100.bin')
elif option == 8: #6b|6b'
    model = fasttext.load_model('model_clear/ft_skip_all_clear_500.bin') #6b
    #model = fasttext.load_model('model_clear/ft_skip_all_clear_300.bin') #6b'
    #model = fasttext.load_model('model_clear/ft_skip_all_clear_100.bin')
elif option == 9: #7a|7a'
    model = fasttext.load_model('model_clear/ft_cbow_clear_500.bin') #7a
    #model = fasttext.load_model('model_clear/ft_cbow_clear_lem_500.bin') #7a_lem
    #model = fasttext.load_model('model_clear/ft_cbow_clear_300.bin') #7a'
    #model = fasttext.load_model('model_clear/ft_cbow_clear_lem_300.bin') #7a'_lem
    #model = fasttext.load_model('model_clear/ft_cbow_clear_100.bin')
elif option == 10: #7b|7b'
    model = fasttext.load_model('model_clear/ft_skip_clear_500.bin') #7b
    #model = fasttext.load_model('model_clear/ft_skip_clear_lem_500.bin') #7b_lem
    #model = fasttext.load_model('model_clear/ft_skip_clear_300.bin') #7b'
    #model = fasttext.load_model('model_clear/ft_skip_clear_lem_300.bin') #7b'_lem
    #model = fasttext.load_model('model_clear/ft_skip_clear_100.bin')
    
elif option == 11: #8A-F
    model = "camembert-base" #camembert-base | camembert/camembert-base-oscar-4gb | camembert/camembert-base-ccnet | camembert/camembert-base-ccnet-4gb | camembert/camembert-base-wikipedia-4gb | camembert/camembert-large
    camembert = CamembertForMaskedLM.from_pretrained(model)
    tokenizer = AutoTokenizer.from_pretrained(model)

    def get_camembert_vector(to_embed): #camembert
        tokenized = tokenizer(to_embed, return_tensors="pt", padding=True)
        input_ids = tokenized["input_ids"][0] 
        with torch.no_grad():
            model_output = camembert(**tokenized, output_hidden_states=True)
        token_embeddings = model_output.hidden_states[-1]
        return token_embeddings

elif option == 12: #9A-D
    model = "flaubert/flaubert_base_uncased" #flaubert/flaubert_base_uncased | flaubert/flaubert_base_cased | flaubert/flaubert_large_cased | flaubert/flaubert_small_cased
    flaubert,log = FlaubertModel.from_pretrained(model, output_loading_info=True)
    flaubert_tokenizer = FlaubertTokenizer.from_pretrained(model, do_lowercase=True) 

    def get_flaubert_vector(to_embed): #flaubert
        token_ids = torch.tensor([flaubert_tokenizer.encode(to_embed)])
        last_layer = flaubert(token_ids)[0]
        vector = last_layer[:,0,:]
        return vector

elif option == 13: #10A-D
    model = "Dr-BERT/DrBERT-7GB" #Dr-BERT/DrBERT-7GB | Dr-BERT/DrBERT-4GB | Dr-BERT/DrBERT-4GB-CP-PubMedBERT | Dr-BERT/DrBERT-4GB-CP-CamemBERT (?) or ./DrBERT_4GB_CP_CAMEMBERT
    tokenizer = AutoTokenizer.from_pretrained(model)
    drbert = AutoModelForMaskedLM.from_pretrained(model)

    def get_drbert_vector(to_embed):
        tokenized = tokenizer(to_embed, return_tensors="pt", padding=True)
        input_ids = tokenized["input_ids"][0] 
        with torch.no_grad():
            model_output = drbert(**tokenized, output_hidden_states=True)
        token_embeddings = model_output.hidden_states[-1]
        return token_embeddings

elif option == 14: #11A
    model = "almanach/camembert-bio-base"
    camembert_bio = AutoModelForMaskedLM.from_pretrained(model)
    tokenizer = AutoTokenizer.from_pretrained(model)

    def get_camembertbio_vector(to_embed):
        tokenized = tokenizer(to_embed, return_tensors="pt", padding=True)
        input_ids = tokenized["input_ids"][0] 
        with torch.no_grad():
            model_output = camembert_bio(**tokenized, output_hidden_states=True)
        token_embeddings = model_output.hidden_states[-1]
        return token_embeddings
        
elif option == 15:
    exit()
else:
    print('Invalid option. Please enter a number between 1 and 15.')

#Load test corpus
data = pd.read_csv('polysemous_words.tsv', sep="\t") #!# polysemous_words_70.tsv polysemous_words_60.tsv

sentence_id = [] #e.g. 'id1'
wordToDisambiguate = [] #e.g. 'alcool'
pos = [] #e.g. 'NOUN'
sentence_example = [] #e.g. 'avez-vous bu de l'alcool ?'
sentence_lemma = [] #e.g. 'avoir,boire,alcool'
sense_pictoID_correct = [] #e.g. '26626' (arasaac)
sense_wolf_correct = [] #e.g. 'fre-30-07884567-n'

for row in data.itertuples():
    sentence_id.append(row.id)
    word = str(row.wordToDisambiguate).replace("’", "''")
    wordToDisambiguate.append(word)
    pos.append(row.pos_wolf)
    sentence_example.append(row.sentence1)
    lemma = str(row.sentence1_lemma).split(",")
    sentence_lemma.append(lemma)
    sense_pictoID_correct.append(row.sense1_pictoID_correct_arasaac)
    sense_wolf_correct.append(row.sense_wolf_correct)

wordToDisambiguate = {k: v for k, v in zip(sentence_id, wordToDisambiguate)}
pos = {k: v for k, v in zip(sentence_id, pos)}
sentence_example = {k: v for k, v in zip(sentence_id, sentence_example)}
sentence_lemma = {k: v for k, v in zip(sentence_id, sentence_lemma)}
sense_pictoID_correct = {k: v for k, v in zip(sentence_id, sense_pictoID_correct)}
sense_wolf_correct = {k: v for k, v in zip(sentence_id, sense_wolf_correct)}

#--------------------------------------------------

#Connect to an existing database
connection = psycopg2.connect(
    host="localhost",
    database="fre30", #or fre30 (wolf), wonef30c (coverage), wonef30f (f-score), wonef30p (precision)
    user="magali",
    password="magali")

#Open a cursor to perform database operations
cursor = connection.cursor()

def get_synsetID(index):

    query1 = f"select id from lexunits where lemma='{wordToDisambiguate.get(index)}'"; #and disable is null;"

    #Execute a command / query the database
    cursor.execute(query1)

    #Obtain data as Python objects
    synsetid = [item[0] for item in cursor.fetchall()]
    
    if len(synsetid) == 0:
        query1 = f"select id from lexunits where lemma like '%{wordToDisambiguate.get(index)}%'"; #and disable is null;" #e.g. 'règles' -> 'règle|règles'
        cursor.execute(query1)
        synsetid = [item[0] for item in cursor.fetchall()]
    
    return synsetid

def get_synonyms(index):
    
    synonyms = []

    for synset in synsetid:
        #query2 = f"select lemma from lexunits where id='{synset}' and disable is null and id in (select synset from posspecific where pos='{pos.get(index)}');"
        query2 = f"select lemma from lexunits where id='{synset}'"; #and disable is null;"
        cursor.execute(query2)
        if option == 11 or option == 12 or option == 13 or option == 14: #camembert | flaubert | drbert | camembert-bio
            synonyms.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()]) #including multiword expressions, e.g. ['alcool', 'boisson alcoolisée'] (parameters A|B-a|c)
            #synonyms.append([re.sub("_", " ", item[0] + ".") for item in cursor.fetchall()]) #including multiword expressions, e.g. ['alcool.', 'boisson alcoolisée.'] (parameters A|B-b|e|f)
        else:
            synonyms.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()]) #including multiword expressions, e.g. ['alcool', 'boisson alcoolisée']
            #synonyms.append([item[0] for item in cursor.fetchall()])

    for synonym in synonyms:
        if f"{wordToDisambiguate.get(index)}" in synonym:
            synonym.remove(f"{wordToDisambiguate.get(index)}")
    
    #synonyms[:] = list(unique_everseen(synonyms)) #removing duplicates
    return synonyms

def get_hyperonyms(index):
    
    hyperonyms = []
    
    for synset in synsetid:
        #query3 = f"select distinct lemma from lexunits where id in (select target from relations where relation='HAS_HYPERONYM' and synset='{synset}') and id in (select synset from posspecific where pos='{pos.get(index)}');"
        query3 = f"select distinct lemma from lexunits where id in (select target from relations where relation='HAS_HYPERONYM' and synset='{synset}');"
        cursor.execute(query3)
        if option == 11 or option == 12 or option == 13 or option == 14: #camembert | flaubert | drbert | camembert-bio
            hyperonyms.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()]) #(parameters A|B-a)
            #hyperonyms.append([re.sub("_", " ", item[0] + ".") for item in cursor.fetchall()]) #(parameters A|B-b|f)
        else:
            hyperonyms.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()])
            #hyperonyms.append([item[0] for item in cursor.fetchall()])

    return hyperonyms

def get_hyponyms(index):
    
    hyponyms = []

    for synset in synsetid:
        #query4 = f"select distinct lemma from lexunits where id in (select synset from relations where relation='HAS_HYPERONYM' and target='{synset}') and id in (select synset from posspecific where pos='{pos.get(index)}');"
        query4 = f"select distinct lemma from lexunits where id in (select synset from relations where relation='HAS_HYPERONYM' and target='{synset}');"
        cursor.execute(query4)
        if option == 11 or option == 12 or option == 13 or option == 14: #camembert | flaubert | drbert | camembert-bio
            hyponyms.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()]) #(parameters A|B-a)
            #hyponyms.append([re.sub("_", " ", item[0] + ".") for item in cursor.fetchall()]) #(parameters A|B-b|f)
        else:
            hyponyms.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()])
            #hyponyms.append([item[0] for item in cursor.fetchall()])

    return hyponyms

def get_xpos(index):
    
    xpos, xpos_2 = [], []

    for synset in synsetid:
        query5 = f"select distinct lemma from lexunits where id in (select target from relations where relation='ENG_DERIVATIVE' and synset='{synset}');"
        cursor.execute(query5)
        if option == 11 or option == 12 or option == 13 or option == 14: #camembert | flaubert | drbert | camembert-bio
            xpos.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()]) #(parameters A|B-a)
            #xpos.append([re.sub("_", " ", item[0] + ".") for item in cursor.fetchall()]) #(parameters A|B-b|f)
        else:
            xpos.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()])
            #xpos.append([item[0] for item in cursor.fetchall()])
        query6 = f"select distinct lemma from lexunits where id in (select synset from relations where relation='ENG_DERIVATIVE' and target='{synset}');"
        cursor.execute(query6)
        if option == 11 or option == 12 or option == 13 or option == 14: #camembert | flaubert | drbert | camembert-bio
            xpos_2.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()]) #(parameters A|B-a)
            #xpos_2.append([re.sub("_", " ", item[0] + ".") for item in cursor.fetchall()]) #(parameters A|B-b|f)
        else:
            xpos_2.append([re.sub("_", " ", item[0]) for item in cursor.fetchall()])
            #xpos_2.append([item[0] for item in cursor.fetchall()])

    if xpos == xpos_2:
        pass #print("ok: keep one side of relation")
    else:
        xpos.extend(xpos_2)
        xpos[:] = list(unique_everseen(xpos))
        #print(f"xpos concatenation of two sides and removing duplicates: {xpos}")

    return xpos

def get_usage(index): #!#
    
    ''' Marian-NMT
    src = "en"
    trg = "fr"
    model_name = f"Helsinki-NLP/opus-mt-{src}-{trg}"
    tokenizer = MarianTokenizer.from_pretrained(model_name)
    model = MarianMTModel.from_pretrained(model_name)
    '''
    
    usage = []
    
    for synset in synsetid:
        #query6 = f"select def2 from usage where lemma_synset='{wordToDisambiguate.get(index)}' and id_synset='{synset}';" #if definition with Google Translate
        query6 = f"select usage_fr from usage where lemma_synset='{wordToDisambiguate.get(index)}' and id_synset='{synset}';" #if usage with Google Translate (usage_fr column from database)
        #e.g. select usage_fr from usage where lemma_synset='alcool' and id_synset='fre-30-07884567-n'; -> l'alcool (ou la boisson) l'a ruiné or alcohol (or drink) ruined him
        #query6 = f"select usage_eng from usage where lemma_synset='{wordToDisambiguate.get(index)}' and id_synset='{synset}';" #if Marian-NMT
        cursor.execute(query6)
        usage.append([item[0] for item in cursor.fetchall()]) #["l'alcool (ou la boisson) l'a ruiné"] or ['alcohol (or drink) ruined him'] (parameters A|B-c)
        #usage.append([item[0] + "." for item in cursor.fetchall()]) #["l'alcool (ou la boisson) l'a ruiné."] or ['alcohol (or drink) ruined him.'] (parameters A|B-d|e|f)
        
        ''' MarianNMT
    print("USAGE_EN : ", usage)
    usage_translated = []
        
    for u in usage:
        if len(u) > 0: #only if english text
            translated = model.generate(**tokenizer(u, return_tensors="pt", padding=True))
            usage_fr = [tokenizer.decode(t, skip_special_tokens=True) for t in translated]
            usage_translated.append(usage_fr)
        else:
            usage_translated.append(list(""))
        
    print("USAGE_FR : ", usage_translated)
    print(type(usage_translated))
    return usage_translated #if Marian-NMT
        '''
    
    return usage #if Google Translate

def get_picto():
    
    #target_language = (arasaac, sclera, beta)
    synsetArasaac_max, synsetSclera_max, synsetBeta_max = [], [], []
    arasaac_bySynset, sclera_bySynset, beta_bySynset = [], [], []
    id_arasaac, lemma_sclera, lemma_beta = [], [], []
    url_arasaac, url_sclera, url_beta = [], [], []
    
    cos_vec_ph_synset_sorted = dict(sorted(cos_vec_ph_synset.items(), key=lambda item:item[1], reverse=True))
    
    for j in cos_vec_ph_synset_sorted.values():
        for k, val in cos_vec_ph_synset.items():
            if val == j:

                #query7 = f"select distinct idpicto from arasaac where synset='{synsets}';"
                query7 = f"select distinct idpicto from arasaac where synset='{synsetids.get(k)}';"
                cursor.execute(query7)
                res_arasaac = cursor.fetchall()

                #query8 = f"select distinct lemma from sclera where synset='{synsets}';"
                query8 = f"select distinct lemma from sclera where synset='{synsetids.get(k)}';"
                cursor.execute(query8)
                res_sclera = cursor.fetchall()

                #query9 = f"select distinct lemma from beta where synset='{synsets}';"
                query9 = f"select distinct lemma from beta where synset='{synsetids.get(k)}';"
                cursor.execute(query9)
                res_beta = cursor.fetchall()
    
                if len(res_arasaac)>0:
                    arasaac_bySynset.append(len(res_arasaac))
                    for idpicto in res_arasaac:
                        synsetArasaac_max.append(synsetids.get(k))
                        url = f"<img src=\"https://static.arasaac.org/pictograms/{idpicto[0]}/{idpicto[0]}_500.png\" width=\"110\"  heigth=\"110\">"
                        #url = f"https://static.arasaac.org/pictograms/{idpicto[0]}/{idpicto[0]}_500.png"
                        id_arasaac.append(idpicto[0])
                        url_arasaac.append(url)
                if len(res_sclera)>0:
                    sclera_bySynset.append(len(res_sclera))
                    for lemmasclera in res_sclera:
                        synsetSclera_max.append(synsetids.get(k))
                        lemma_sclera.append(lemmasclera)
                        url = f"<img src=\"http://webservices.ccl.kuleuven.be/picto/sclera//{lemmasclera[0]}.png\" width=\"110\"  heigth=\"110\">"
                        #url = f"http://webservices.ccl.kuleuven.be/picto/sclera//{lemmasclera[0]}.png"
                        url_sclera.append(url)
                if len(res_beta)>0:
                    beta_bySynset.append(len(res_beta))
                    for lemmabeta in res_beta:
                        synsetBeta_max.append(synsetids.get(k))
                        lemma_beta.append(lemmabeta)
                        url = f"<img src=\"http://webservices.ccl.kuleuven.be/picto/beta//{lemmabeta[0]}.png\" width=\"110\"  heigth=\"110\">"
                        #url = f"http://webservices.ccl.kuleuven.be/picto/beta//{lemmabeta[0]}.png"
                        url_beta.append(url)
    l = []                
    if len(arasaac_bySynset)>0:
        synsetArasaac_max = synsetArasaac_max[0]
        arasaac_number = arasaac_bySynset[0]
        url_arasaac = url_arasaac[0:arasaac_number]
        id_arasaac = id_arasaac[0:arasaac_number]
        for url, id_a in zip(url_arasaac[0:arasaac_number], id_arasaac):
            #print(url)
        #'''
        #for id_a in id_arasaac:
            query10 = f"select distinct lemma from arasaac where idpicto='{id_a}';"
            cursor.execute(query10)
            lemma_arasaac = cursor.fetchall()
            for lemma in lemma_arasaac:
                lemma = str(lemma)
                lemma = re.sub("\(\'|\"|(_[0-9])|(,)", "", str(lemma))
                lemma = re.sub("\'\)|\)|\(", "", str(lemma))
                lemma = re.sub("_", " ", str(lemma))
                l.append(lemma)
            print(url, list(unique_everseen(l)))
        #'''
    else:
        print("[NO_ARASAAC]")
    if len(sclera_bySynset)>0:
        synsetSclera_max = synsetSclera_max[0]
        sclera_number = sclera_bySynset[0]
        url_sclera = url_sclera[0:sclera_number]
        for url in url_sclera[0:sclera_number]:
            print(url)
    else:
        print("[NO_SCLERA]")
    if len(beta_bySynset)>0:
        synsetBeta_max = synsetBeta_max[0]
        beta_number = beta_bySynset[0]
        url_beta = url_beta[0:beta_number]
        for url in url_beta[0:beta_number]:
            print(url)
    else:
        print("[NO_BETA]")

    if len(arasaac_bySynset)==0 and len(sclera_bySynset)==0 and len(beta_bySynset)==0:
        print("[NO_PICTO]") #No pictograph linked to the max synsets

    return url_arasaac, url_sclera, url_beta, id_arasaac, synsetArasaac_max, synsetSclera_max, synsetBeta_max 
    
#--------------------------------------------------

def idRelVectorBySynset(n):
  
  synsetids[var+str(n)] = synsetid[n]
  
  if len(list(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])) > 0: #default (parameters A|B-a|b), word2vec | fasttext | camembert | flaubert | drbert | camembert-bio
  #if len(list(usage[n])) > 0: #(parameters A|B-c|d), camembert | flaubert | drbert | camembert-bio
  #if len(list(usage[n] + synonyms[n])) > 0: #(parameters A|B-e), camembert | flaubert | drbert | camembert-bio
  #if len(list(usage[n] + synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])) > 0: #(parameters A|B-f), camembert | flaubert | drbert | camembert-bio
  
    if option == 1 or option == 2 or option == 3 or option == 4 or option == 5: #Word2vec
        synsets[var+str(n)] = list(unique_everseen(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n]))
        vectors[var+str(n)] = model.get_mean_vector(synsets.get(var+str(n))) #default: pre_normalize=True
        
    if option == 6 or option == 7 or option == 8 or option == 9 or option == 10: #fastText
        relations = ' '.join(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])
        synsets[var+str(n)] = relations
        vectors[var+str(n)] = model.get_sentence_vector(synsets.get(var+str(n)))

    if option == 11: #camembert
       synsets[var+str(n)] = list(unique_everseen(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])) #default (parameters A|B-a|b)
       #synsets[var+str(n)] = list(usage[n]) #(parameters A|B-c|d)
       #synsets[var+str(n)] = list(usage[n] + synonyms[n]) #(parameters A|B-e)
       #synsets[var+str(n)] = list(usage[n] + synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n]) #(parameters A|B-f)
       relations_str = ' '.join(synsets.get(var+str(n)))
       print(relations_str)
       print(type(relations_str))
       vectors[var+str(n)] = get_camembert_vector(relations_str)[0][0].tolist()
       #vectors[var+str(n)] = get_camembert_vector(synsets.get(var+str(n)))[0][0].tolist()
    
    if option == 12: #flaubert
        synsets[var+str(n)] = list(unique_everseen(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])) #default (parameters A|B-a|b)
        #synsets[var+str(n)] = list(usage[n]) #(parameters A|B-c|d)
        #synsets[var+str(n)] = list(usage[n] + synonyms[n]) #(parameters A|B-e)
        #synsets[var+str(n)] = list(usage[n] + synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n]) #(parameters A|B-f)
        relations_str = ' '.join(synsets.get(var+str(n)))
        print(relations_str)
        print(type(relations_str))
        vectors[var+str(n)] = get_flaubert_vector(relations_str)[0].tolist()
        #vectors[var+str(n)] = get_flaubert_vector(synsets.get(var+str(n)))[0].tolist()
        
    if option == 13: #drbert
        synsets[var+str(n)] = list(unique_everseen(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])) #default (parameters A|B-a|b)
        #synsets[var+str(n)] = list(usage[n]) #(parameters A|B-c|d)
        #synsets[var+str(n)] = list(usage[n] + synonyms[n]) #(parameters A|B-e)
        #synsets[var+str(n)] = list(usage[n] + synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n]) #(parameters A|B-f)
        relations_str = ' '.join(synsets.get(var+str(n)))
        print(relations_str)
        print(type(relations_str))
        vectors[var+str(n)] = get_drbert_vector(relations_str)[0][0].tolist()
        #vectors[var+str(n)] = get_drbert_vector(synsets.get(var+str(n)))[0][0].tolist()

    if option == 14: #camembert-bio
       synsets[var+str(n)] = list(unique_everseen(synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n])) #default (parameters A|B-a|b)
       #synsets[var+str(n)] = list(usage[n]) #(parameters A|B-c|d)
       #synsets[var+str(n)] = list(usage[n] + synonyms[n]) #(parameters A|B-e)
       #synsets[var+str(n)] = list(usage[n] + synonyms[n] + hyperonyms[n] + hyponyms[n] + xpos[n]) #(parameters A|B-f)
       relations_str = ' '.join(synsets.get(var+str(n)))
       print(relations_str)
       print(type(relations_str))
       vectors[var+str(n)] = get_camembertbio_vector(relations_str)[0][0].tolist()
       #vectors[var+str(n)] = get_camembertbio_vector(synsets.get(var+str(n)))[0][0].tolist()        
        
  else:
    synsets[var+str(n)] = "NAN"
    vectors[var+str(n)] = "NAN"
    
  return synsets, vectors

def cosVectorBySynset(n, index):
  if synsets.get(var+str(n)) != "NAN":
    cos_vec_ph_synset[var+str(n)] = numpy.dot(vec_phrase.get(index),vectors.get(var+str(n)))/(numpy.linalg.norm(vec_phrase.get(index))*numpy.linalg.norm(vectors.get(var+str(n))))
  else:
    pass

  return cos_vec_ph_synset

#--------------------------------------------------

file1 = open("polysemous_words_logs.tsv", "w")
file2 = open("polysemous_words_logs.html", "w")

#14 columns
header_logs = str("wordToDisambiguate" + "\t" + "sentence" + "\t" + "sense1_pictoID_correct_arasaac" + "\t" + "sense_pictoID_wsd_arasaac" + "\t" + "sense_wolf_correct" + "\t" + "sense_wolf_wsd_arasaac" + "\t" + "synset_lemma_wsd_arasaac" + "\t" + "url_wsd_arasaac" + "\t" + "sense_wolf_wsd_sclera" + "\t" + "synset_lemma_wsd_sclera" + "\t" + "url_wsd_sclera" + "\t" + "sense_wolf_wsd_beta" + "\t" + "synset_lemma_wsd_beta" + "\t" + "url_wsd_beta" + "\n")
file1.write(header_logs)

var = "synset"

for i in range(1,101): #word1 -> 1,2 / 1word100 -> 1,101
    
    synsetids = {} #dict of synset identifiers, e.g. {synset0: 'fre-30-07884567-n', synset1: '...', etc.}
    synsets = {} #dict of synset lemmas (relations of wordToDisambiguate)

    vectors = {} #dict of vector (synset lemma relations of wordToDisambiguate)
    vec_phrase = {} #dict of the sentence vector
    cos_vec_ph_synset = {} #dict of cosine vectors
    cos_vec_ph_synset_sorted = [] #sorted list of cosine vectors

    index = "id" + str(i) #sentence number
    
    sentence = sentence_lemma.get(index) #e.g. 'avoir,boire,alcool'
    l = []
    
    #1/2) Vectors of content words (sentence) + mean
    
    if option == 1 or option == 2 or option == 3 or option == 4 or option == 5: #Word2vec
        #vec_phrase[index] = model.get_mean_vector(sentence) #[avoir, boire, alcool]
        for i in sentence:
            if model.has_index_for(i): #for oov
                l.append(model.get_vector(i)) #[avoir, boire, alcool]
                #l.append(i) #OR
        #mean_vec_sentence = model.get_mean_vector(l, pre_normalize=False) #OR
        mean_vec_sentence = numpy.mean(l, axis=0) #arithmetic average
        #mean_vec_sentence = numpy.average(l, axis=0) #weighted average
        vec_phrase[index] = mean_vec_sentence
        
    if option == 6 or option == 7 or option == 8 or option == 9 or option == 10: #fastText
        #vec_phrase[index] = model.get_sentence_vector(sentence_example.get(index)) #avez-vous bu de l'alcool ?
        for i in sentence:
            l.append(model.get_word_vector(i)) #[avoir, boire, alcool]
        mean_vec_sentence = numpy.mean(l, axis=0) #arithmetic average
        #mean_vec_sentence = numpy.average(l, axis=0) #weighted average
        vec_phrase[index] = mean_vec_sentence
        
    sentence = ' '.join(sentence) #default (parameters A), [avoir, boire, alcool]
    print(sentence) #default (parameters A), [avoir, boire, alcool]
    print(type(sentence)) #default (parameters A), [avoir, boire, alcool]
    #print(sentence_example.get(index)) #(parameters B), avez-vous bu de l'alcool ?
    #print(type(sentence_example.get(index))) #(parameters B), avez-vous bu de l'alcool ?
        
    if option == 11: #camembert
        #vec_phrase[index] = get_camembert_vector(sentence_example.get(index))[0][0].tolist() #(parameters B), avez-vous bu de l'alcool ?
        vec_phrase[index] = get_camembert_vector(sentence)[0][0].tolist() #default (parameters A), [avoir, boire, alcool]
        
    if option == 12: #flaubert
        #vec_phrase[index] = get_flaubert_vector(sentence_example.get(index))[0].tolist() #(parameters B), avez-vous bu de l'alcool ?
        vec_phrase[index] = get_flaubert_vector(sentence)[0].tolist() #default (parameters A), [avoir, boire, alcool]
        
    if option == 13: #drbert
        #vec_phrase[index] = get_drbert_vector(sentence_example.get(index))[0][0].tolist() #(parameters B), avez-vous bu de l'alcool ?
        vec_phrase[index] = get_drbert_vector(sentence)[0][0].tolist() #default (parameters A), [avoir, boire, alcool]
        
    if option == 14: #camembert-bio
        #vec_phrase[index] = get_camembertbio_vector(sentence_example.get(index))[0][0].tolist() #(parameters B), avez-vous bu de l'alcool ?
        vec_phrase[index] = get_camembertbio_vector(sentence)[0][0].tolist() #default (parameters A), [avoir, boire, alcool]
    
    #3/4) Vectors of syn/hyper/hyponyms/xpos (synset 1) + mean
    #5) Vectors of syn/hyper/hyponyms/xpos (synsets 2/3/...) + mean
    
    synsetid = get_synsetID(index) #e.g. ['fre-30-07884567-n', 'fre-30-14708720-n', 'fre-30-14941230-n']
    synonyms = get_synonyms(index) #e.g. [['boisson alcoolisée'], [], ['spiritueux']]
    hyperonyms = get_hyperonyms(index) #e.g. [['boisson', 'breuvage', 'drogue'], ['liquide'], ['liquide']]
    hyponyms = get_hyponyms(index) #e.g. [['apéritif', 'cordial', 'eau-de-vie', 'esprit', 'gnole', 'gnôle', 'kava', 'kava-kava', 'kawa', 'kumiz', 'liqueur', 'perry', 'poiré', 'pulque', 'ratafia', 'saké', 'spiritueux', 'vin'], ['alcool isopropylique', 'alcool méthylique', 'butan-1-ol', 'butanol', 'carbinol', 'cyclohexanol', "d'alcool de bois", 'de naphte de bois', "d'esprit de bois", 'diol', 'éthanol', 'Éthanol', 'glycérine', 'glycérol', 'glycol', 'isopropanol', 'le méthanol', 'méthanol', 'propanol', 'stérol'], []]
    xpos = get_xpos(index) #e.g. [['alcoolique', 'alcoolisé', 'intoxiquer'], ['alcoolique', 'alcoolisé'], []]
    
    usage = get_usage(index) #!#

    for synset in range(len(synsetid)):
        idRelVectorBySynset(synset)
        
    #6) Cosine similarity between sentence vector and synset vector 1
    #7) Cosine similarity between sentence vector and synset vectors 2/3/...
    
    for synset in range(len(synsets)):
        cos_vec_ph_synset = cosVectorBySynset(synset, index)
        
    #print(wordToDisambiguate.get(index), "\t", len(synsetid), "\t", len(cos_vec_ph_synset))
        
    #8) Compare the scores (the synset with the max cosine)
    
    #max_synset = [k  for (k, val) in cos_vec_ph_synset.items() if val == max(cos_vec_ph_synset.values())]
    #max_synset = '|'.join(max_synset) #if several max
    #max_synset = re.sub("\|synset[0-9]+", "", max_synset) #keep the first
 
    print(wordToDisambiguate.get(index), "-->", sentence_example.get(index))

    urls = get_picto()
    
    arasaac_url = ' | '.join(urls[0])
    sclera_url = ' | '.join(urls[1])
    beta_url = ' | '.join(urls[2])
    arasaac_id = ''.join(str(urls[3]))
    arasaac_max_synset_id = ''.join(str(urls[4]))
    sclera_max_synset_id = ''.join(str(urls[5]))
    beta_max_synset_id = ''.join(str(urls[6]))

    arasaac_max_synset_lemmas = [k for (k, val) in synsetids.items() if val == arasaac_max_synset_id]
    arasaac_max_synset_lemmas = ''.join(arasaac_max_synset_lemmas)
    arasaac_max_synset_lemmas = synsets.get(arasaac_max_synset_lemmas)
    sclera_max_synset_lemmas = [k for (k, val) in synsetids.items() if val == sclera_max_synset_id]
    sclera_max_synset_lemmas = ''.join(sclera_max_synset_lemmas)
    sclera_max_synset_lemmas = synsets.get(sclera_max_synset_lemmas)
    beta_max_synset_lemmas = [k for (k, val) in synsetids.items() if val == beta_max_synset_id]
    beta_max_synset_lemmas = ''.join(beta_max_synset_lemmas)
    beta_max_synset_lemmas = synsets.get(beta_max_synset_lemmas)
    
    print("Synset Arasaac -->", arasaac_max_synset_id, arasaac_max_synset_lemmas)
    print("Synset Sclera -->", sclera_max_synset_id, sclera_max_synset_lemmas)
    print("Synset Beta -->", beta_max_synset_id, beta_max_synset_lemmas)
    print("\n")
    
    new_line = str(str(wordToDisambiguate.get(index)) + "\t" + str(sentence_example.get(index)) + "\t" + str(sense_pictoID_correct.get(index)) + "\t" + arasaac_id + "\t" + str(sense_wolf_correct.get(index)) + "\t" + str(arasaac_max_synset_id) + "\t" + str(arasaac_max_synset_lemmas) + "\t<p> " + arasaac_url + " <p>\t" + str(sclera_max_synset_id) + "\t" + str(sclera_max_synset_lemmas) + "\t<p> " + sclera_url + " <p>\t" + str(beta_max_synset_id) + "\t" + str(beta_max_synset_lemmas) + "\t<p> " + beta_url + " <p>\n")
    file1.write(new_line)
    new_line2 = str(str(index) + " --> " + str(wordToDisambiguate.get(index)) + " --> " + str(sentence_example.get(index)) + "<p> Arasaac --> | " + arasaac_url + " | Sclera --> | " + sclera_url + " | Beta --> | " + beta_url + " <p>")
    file2.write(new_line2)

file1.close()
file2.close()
cursor.close()
connection.close()
