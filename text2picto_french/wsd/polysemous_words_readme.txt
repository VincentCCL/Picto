By Magali Norré
Date: 06.01.2023

Metadata of polysemous_words.tsv

This file contains:

- 100 rows
100 French different polysemous_words used in medical dialogue (see wordToDisambiguate column)

- 22 columns

-- id: id[1-100]

For example: id1

-- wordToDisambiguate: French polysemous words from the BabelDr system, https://babeldr.unige.ch
The BabelDr corpus contains anamnesis questions (triage scale) and medical instructions of doctor

For example: alcool

-- pos_wolf: part-of-speech of wordToDisambiguate from French WordNets, i.e. WOLF (Sagot and Fišer 2008) and WoNeF (Pradet et al. 2014), in uppercase
NOUN, -n/NOM, #52
VERB, -v/VER:..., #38
ADJECTIVE, -a/ADJ, #5
ADVERB, -r/ADV, #5

For example: NOUN

-- sentence1: a first sentence example from BabelDr, in lowercase

For example: avez-vous bu de l'alcool ?

-- sentence1_lemma: lemmas of the first sentence example from BabelDr (only nouns, verbs, adjectives and adverbs of TreeTagger), separated by ","

For example: avoir,boire,alcool

-- sense1_pictoID_correct_arasaac: at least a correct Arasaac* pictograph identifier, related to the first sentence example (sentence1); several can be correct, separated by "," (non-exhaustive list), in square brackets []

For example: [26626]

The Arasaac pictograph can be displayed with the idpicto on Arasaac website: https://static.arasaac.org/pictograms/{idpicto}/{idpicto}_500.png
Example: https://static.arasaac.org/pictograms/26626/26626_500.png
Or on KULeuven server: https://text2picto.ccl.kuleuven.be/arasaac/{idpicto}.png
Example: https://text2picto.ccl.kuleuven.be/arasaac/26626.png

-- sense_wolf_correct: at least a correct WOLF synset identifier ("fre-30-" + synset id of WOLF), related to the first sentence example (sentence1), several can be correct, separated by "_" (non-exhaustive list)

For example: fre-30-07884567-n

-- synset_lemma_correct: at least a correct WOLF synset lemma, related to the sense_wolf_correct (synonyms, hyperonyms, hyponyms, eng_derivatives) of the first sentence example (sentenceBabelDr1), separated by "," (non-exhaustive list), 'lemma', in square brackets []

For example: ['boisson_alcoolisée', 'boisson', 'breuvage', 'drogue', 'apéritif', 'cordial', 'eau-de-vie', 'esprit', 'gnole', 'gnôle', 'kava', 'kava-kava', 'kawa', 'kumiz', 'liqueur', 'perry', 'poiré', 'pulque', 'ratafia', 'saké', 'spiritueux', 'vin', 'alcoolique', 'alcoolisé', 'intoxiquer']

-- sense1_AZ: (sense1)/filename|idpicto|wolfID_AZ: WOLF sense of the pictograph translation given by the Text-to-Picto system**, results sorted alphabetically (AZ)

For example: désinfectant/alcool|2984|fre-30-14708720-n

-- sense2_ZA: (sense2)/filename|idpicto|wolfID_ZA: WOLF sense of the pictograph translation given by the Text-to-Picto system**, results sorted non-alphabetically (ZA)

For example: boisson/alcool_2|26626|fre-30-07884567-n

-- sense3: (sense3)/filename|idpicto|wolfID: other possible sense (non-exhaustive list)
-- sense4: (sense4)/filename|idpicto|wolfID: other possible sense (non-exhaustive list)

Arasaac pictoID and wolfID got from French Arasaac filename with:
select idpicto,synset from arasaac where lemma='{senseX}' and synset in (select id from lexunits where lemma='{wordToDisambiguate}');

For example: select idpicto,synset from arasaac where lemma='alcool' and synset in (select id from lexunits where lemma='alcool');
select idpicto,synset from arasaac where lemma='alcool_2' and synset in (select id from lexunits where lemma='alcool');

-- sentence2 / sentence2_lemma: a second sentence example from BabelDr, in lowercase

For example: votre consommation d'alcool a-t-elle augmenté ? / consommation,alcool,avoir,augmenter

-- sentence3 / sentence3_lemma: a third example sentence from BabelDr, in lowercase

For example: combien de verres d'alcool buvez-vous par jour ? / combien,verre,alcool,boire,jour

-- sentence4 / sentence4_lemma: a fourth example sentence from BabelDr, in lowercase
-- sentence5 / sentence5_lemma: a fifth example sentence from BabelDr, in lowercase
-- sentence6 / sentence6_lemma: a sixth example sentence from BabelDr, in lowercase

The correct Arasaac pictographs of this corpus can be displayed at the following link: https://text2picto.ccl.kuleuven.be/text2picto_french/web/french/wsd_arasaac.php 

* The pictographs used are property of the Aragon Government and have been created by Sergio Palao to Arasaac (https://arasaac.org). Aragon Government distributes them under Creative Commons License.

** Arasaac pictograph filenames used in the Text-to-Picto system (Norré et al. 2022), v. 2.1. Without xpos relation. Parameters: oov_3, wrongnum_4, nonum_9, hyper_15, xpos_8, anto_10, penal_9, dict_2.

References:

Magali Norré, Vincent Vandeghinste, Pierrette Bouillon, and Thomas François. (2021). « Extending a Text-to-Pictograph system to French and to Arasaac ». In Proceedings of the International Conference on Recent Advances in Natural Language Processing (RANLP 2021), Varna, Bulgarie, pages 1050-1059.

Quentin Pradet, Gaël De Chalendar, and Jeanne Baguenier Desormeaux. (2014). « WoNeF, an improved, expanded and evaluated automatic French translation of WordNet ». In Proceedings of the Seventh Global Wordnet Conference, pages 32–39.

Benoît Sagot, and Darja Fišer. (2008). « Building a free French WordNet from multilingual resources ». In OntoLex, Marrakech, Morocco.
