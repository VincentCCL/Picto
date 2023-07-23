#!/usr/bin/env python
# -*- coding: utf-8 -*-

#python3 wsd_evaluation.py > polysemous_words_results.txt

'''
By Magali Norré
Date: 25.01.2023
'''

import pandas as pd
import statistics

#Load results (logs), 8 columns used / 14
data = pd.read_csv('polysemous_words_logs.tsv', sep="\t")

precision_arasaac, precision_sclera, precision_beta = 0, 0, 0
recall_arasaac, recall_sclera, recall_beta = 0, 0, 0
fsore_arasaac, fsore_sclera, fsore_beta = 0, 0, 0

recall_baseline_arasaac = 99 #with Text-to-Picto v. 2.1 (oov_3 wrongnum_4 nonum_9 hyper_15 xpos_8 anto_10 penal_9 dict_2)
#recall_baseline_arasaac, recall_baseline_sclera, recall_baseline_beta = 99, ?, ?
recall_rel_improv_arasaac, recall_rel_improv_sclera, recall_rel_improv_beta = 0, 0, 0
precision_baseline_arasaac = 40.4 #with Text-to-Picto v. 2.1 (oov_3 wrongnum_4 nonum_9 hyper_15 xpos_8 anto_10 penal_9 dict_2)
#precision_baseline_arasaac, precision_baseline_slera, precision_baseline_beta = 40.4, ?, ?
precision_rel_improv_arasaac, precision_rel_improv_sclera, precision_rel_improv_beta = 0, 0, 0

fscore_baseline_arasaac = 57.19 #with Text-to-Picto v. 2.1 (oov_3 wrongnum_4 nonum_9 hyper_15 xpos_8 anto_10 penal_9 dict_2)
#fscore_baseline_arasaac, fscore_baseline_slera, fscore_baseline_beta = 69.69, ?, ?
fscore_rel_improv_arasaac, fscore_rel_improv_sclera, fscore_rel_improv_beta = 0, 0, 0

count_all, count_arasaac, count_sclera, count_beta = 0, 0, 0, 0
no_picto = 0

synset_arasaac, synset_sclera, synset_beta = [], [], []

wordtodisambiguate = [] # e.g. 'alcool'
sense_wolf_correct = [] #e.g. 'fre-30-07884567-n'
sense_wolf_wsd_arasaac = [] #e.g. 'fre-30-07884567-n'
sense_wolf_wsd_sclera = [] #e.g. 'fre-30-07884567-n'
sense_wolf_wsd_beta = [] #e.g. []

url_wsd_arasaac, url_wsd_sclera, url_wsd_beta = [], [], []

for row in data.itertuples():
    wordtodisambiguate.append(row.wordToDisambiguate)
    sense_wolf_correct.append(row.sense_wolf_correct)
    sense_wolf_wsd_arasaac.append(row.sense_wolf_wsd_arasaac)
    sense_wolf_wsd_sclera.append(row.sense_wolf_wsd_sclera)
    sense_wolf_wsd_beta.append(row.sense_wolf_wsd_beta)
    url_wsd_arasaac.append(row.url_wsd_arasaac)
    url_wsd_sclera.append(row.url_wsd_sclera)
    url_wsd_beta.append(row.url_wsd_beta)

count_word = len(sense_wolf_correct) #number of polysemous_words to evaluate

translated_arasaac, translated_sclera, translated_beta = 0, 0, 0
untranslated_arasaac_lemma, untranslated_arasaac_index = [], []
oktranslated_arasaac, oktranslated_sclera, oktranslated_beta = 0, 0, 0
oktranslated_arasaac_lemma, oktranslated_arasaac_index = [], []
badtranslated_arasaac_lemma, badtranslated_arasaac_index = [], []

#--------------------------------------------------
    
for wolf_correct,wsd_arasaac,wsd_sclera,wsd_beta,url_arasaac,url_sclera,url_beta in zip(sense_wolf_correct, sense_wolf_wsd_arasaac, sense_wolf_wsd_sclera, sense_wolf_wsd_beta, url_wsd_arasaac, url_wsd_sclera, url_wsd_beta):

    #precision (true positive): number of correct synset (by pictograph set)
    wolf_correct = wolf_correct.split("_")    
    if wsd_arasaac in wolf_correct:
        oktranslated_arasaac += 1
        oktranslated_arasaac_index.append(len(synset_arasaac))
        synset_arasaac.append("v") #arasaac synset correct
    elif wsd_arasaac == "[]":
        untranslated_arasaac_index.append(len(synset_arasaac))
        synset_arasaac.append("y") #no arasaac synset
    else:
        badtranslated_arasaac_index.append(len(synset_arasaac))
        synset_arasaac.append("x") #arasaac synset incorrect
    if wsd_sclera in wolf_correct:
        oktranslated_sclera += 1
        synset_sclera.append("v") #sclera synset correct
    elif wsd_sclera == "[]":
        synset_sclera.append("y") #no sclera synset
    else:
        synset_sclera.append("x") #sclera synset incorrect
    if wsd_beta in wolf_correct:
        oktranslated_beta += 1
        synset_beta.append("v") #beta synset correct
    elif wsd_beta == "[]":
        synset_beta.append("y") #no beta synset
    else:
        synset_beta.append("x") #beta synset incorrect

    #recall: number of translated words (by pictograph set)
    if wsd_arasaac != "[]":
        translated_arasaac += 1
    if wsd_sclera != "[]":
        translated_sclera += 1
    if wsd_beta != "[]":
        translated_beta += 1
    if wsd_arasaac == "[]" and wsd_arasaac == "[]" and wsd_sclera == "[]":
        no_picto += 1
    
    #number of pictographs (by pictograph set)
    if "http" in url_arasaac:
        count_arasaac += url_arasaac.count('http')
    if "http" in url_sclera:
        count_sclera += url_sclera.count('http')
    if "http" in url_beta:
        count_beta += url_beta.count('http')

untranslated_arasaac = count_word - translated_arasaac
badtranslated_arasaac = count_word - oktranslated_arasaac - untranslated_arasaac

for i in oktranslated_arasaac_index:
    oktranslated_arasaac_lemma.append(wordtodisambiguate[i])
for i in untranslated_arasaac_index:
    untranslated_arasaac_lemma.append(wordtodisambiguate[i])
for i in badtranslated_arasaac_index:
    badtranslated_arasaac_lemma.append(wordtodisambiguate[i])

#recall: percentage of translated word = number of translated word / number of polysemous_words (by pictograph set)
recall_arasaac = (translated_arasaac/count_word)*100
recall_sclera = (translated_sclera/count_word)*100
recall_beta = (translated_beta/count_word)*100

#precision: percentage of correct synset = number of correct synset / number of translated word (by pictograph set)
precision_arasaac = (oktranslated_arasaac/recall_arasaac)*100
precision_sclera = (oktranslated_sclera/recall_sclera)*100
precision_beta = (oktranslated_beta/recall_beta)*100

#fscore: harmonic mean of recall and precision (by pictograph set)
#fscore_arasaac = 2 * (precision_arasaac * recall_arasaac) / (precision_arasaac + recall_arasaac)
fscore_arasaac = statistics.harmonic_mean([recall_arasaac, precision_arasaac])
fscore_sclera = statistics.harmonic_mean([recall_sclera, precision_sclera])
fscore_beta = statistics.harmonic_mean([recall_beta, precision_beta])

recall_rel_improv_arasaac = recall_arasaac - recall_baseline_arasaac
precision_rel_improv_arasaac = precision_arasaac - precision_baseline_arasaac
fscore_rel_improv_arasaac = fscore_arasaac - fscore_baseline_arasaac

count_all = count_arasaac + count_sclera + count_beta

#--------------------------------------------------

print("% precision (arasaac, sclera, beta)" + "\t" + str(precision_arasaac) + "\t" + str(precision_sclera) + "\t" + str(precision_beta))
print("% recall (arasaac, sclera, beta)" + "\t" + str(recall_arasaac) +"\t" + str(recall_sclera) + "\t" + str(recall_beta))
print("% fscore (arasaac, sclera, beta)" + "\t" + str(fscore_arasaac) + "\t" + str(fscore_sclera) + "\t" + str(fscore_beta) + "\n")

print("% precision relative improv." + "\t" + str(precision_rel_improv_arasaac))
print("% recall relative improv." + "\t" + str(recall_rel_improv_arasaac))
print("% fscore relative improv." + "\t" + str(fscore_rel_improv_arasaac) + "\n")

print("# wordToDisambiguate (arasaac, sclera, beta)" + "\t" + str(count_word))
print("# translated words (arasaac)" + "\t" + str(translated_arasaac))
print("# untranslated words (arasaac)" + "\t" + str(untranslated_arasaac))
print("untranslated words (arasaac)" + "\t" + str(untranslated_arasaac_lemma) + "\n")

print("# oktranslated words (arasaac)" + "\t" + str(oktranslated_arasaac))
print("oktranslated words (arasaac)" + "\t" + str(oktranslated_arasaac_lemma) + "\n")
print("# badtranslated words (arasaac)" + "\t" + str(badtranslated_arasaac))
print("badtranslated words (arasaac)" + "\t" + str(badtranslated_arasaac_lemma) + "\n")

print("# picto (arasaac, sclera, beta)" + "\t" + str(count_arasaac) + "\t" + str(count_sclera) + "\t" + str(count_beta))
print("# picto (all)" + "\t" + str(count_all))
print("# no picto (all)" + "\t" + str(no_picto) + "\n")
      
print("Arasaac picto" + "\t" + str(synset_arasaac))
print("Sclera picto" + "\t" + str(synset_sclera))
print("Beta picto" + "\t" + str(synset_beta))

file1 = open("res.tsv", "w")
new_line = str(str(synset_arasaac) + "\t" + str(recall_arasaac) + "\t" + str(recall_rel_improv_arasaac) + "\t" + str(precision_arasaac) + "\t" + str(precision_rel_improv_arasaac) + "\t" + str(fscore_arasaac) + "\t" + str(fscore_rel_improv_arasaac) + "\t" + str(count_all) + "\t" + str(count_arasaac) + "|" + str(count_sclera) + "|" + str(count_beta) + "\t" + str(no_picto) + "\n")
file1.write(new_line)
file1.close()
