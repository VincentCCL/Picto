# French Word Sense Disambiguation (WSD)

- Project: French Text-to-Picto for communication between doctors and patients with an intellectual disability in hospitals
- Funded by UCLouvain, FSR (2020-2021, 2022-2024)
- Date: 23.07.2023
- Version: 1.0
- Author: Magali Norré, Catholic University of Louvain (UCLouvain-Cental) & University of Geneva (UNIGE-FTI)
- Contact: magali.norre@uclouvain.be

## File listing:

- model_clear folder: Word2Vec and fastText models that we trained on the CLEAR corpus (see below) + word2vec/fasttext_clear_train.py: scripts used for model training
- polysemous_words.tsv: evaluation corpus for WSD, including French polysemous words used in medical dialogues, translated into Arasaac pictographs (not Sclera/Beta) and synsets of the French WordNet, i.e. WOLF ; used by wsd(2).py
- polysemous_words_logs.html: example of output html (Arasaac, Sclera, and Beta pictographs) for wsd.py (model 1b, option 2)
- polysemous_words_logs.tsv: example of output tsv (Arasaac, Sclera, and Beta pictographs) for wsd.py (model 1b, option 2) ; used by wsd_evaluation.py
- polysemous_words_readme.txt: more information on the evaluation corpus
- polysemous_words_results.txt: example of output txt for wsd_evaluation.py (model 1b, option 2)
- wsd_arasaac.html: evaluation corpus for WSD, see also [here](https://text2picto.ccl.kuleuven.be/text2picto_french/web/french/wsd_arasaac.php)
- wsd.py: main script for WSD (with decreasing cosine similarity, rank > 1)
- wsd2.py: alternative version of main script for WSD (with maximum cosine similarity, rank 1)
- wsd_evaluation.py: script for evaluating the WSD on the evaluation corpus (only Arasaac pictograph results, not precision/fscore for Sclera/Beta because no corpus for these sets)

wsd.py and wsd2.py require to create "fre30" (WOLF), "wonef30c" (WoNeF coverage), "wonef30f" (WoNeF f-score) and/or "wonef30p" (WoNeF precision) databases of the French Text-to-Picto, but don't require the Perl files (TextToPicto.pl, etc.)

## Reference:

Magali Norré, Rémi Cardon, Vincent Vandeghinste, and Thomas François. (2023). « Word Sense Disambiguation for Automatic Translation of Medical Dialogues into Pictographs ». In Proceedings of the International Conference on Recent Advances in Natural Language Processing (RANLP 2023), Varna, Bulgaria

## Resources:

Require to create folders, download (and rename some) French pre-trained models used in wsd.py and wsd2.py:
- [Word2Vec frWac2Vec & frWiki2Vec](https://fauconnier.github.io) (folder: model_frwac2vec-frwiki2vec, options of wsd(2).py: 1-5)
- [fastText Common Crawl + Wikipedia](https://fasttext.cc/docs/en/crawl-vectors.html) (French bin, cc.fr.300.bin, folder: model_cc-fr, 6-10)
- [CLEAR corpus](http://natalia.grabar.free.fr/resources.php#clear) (folder: model_clear, 4-5 and 7-10)
- [CamemBERT](https://camembert-model.fr) (11)
- [FlauBERT](https://github.com/getalp/Flaubert) (12)
- [DrBERT](https://drbert.univ-avignon.fr) (13)
- [CamemBERT-bio](https://huggingface.co/almanach/camembert-bio-base) (14)
