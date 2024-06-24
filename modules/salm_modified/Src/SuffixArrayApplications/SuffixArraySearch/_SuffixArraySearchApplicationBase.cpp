/**
* Revision $Rev: 3794 $
* Last Modified $LastChangedDate: 2007-06-29 02:17:32 -0400 (Fri, 29 Jun 2007) $
**/

#include "_SuffixArraySearchApplicationBase.h"
#include <iostream>
#include <sstream>
#include <tr1/unordered_map>

using namespace std;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

C_SuffixArraySearchApplicationBase::C_SuffixArraySearchApplicationBase()
{

    this->reportMaxOccurrenceOfOneNgram = -1;    
	this->highestFreqThresholdForReport = -1;
	this->shortestUnitToReport = 1;
    this->longestUnitToReport = -1; //no constraint

    this->level1Buckets = NULL;
	this->noLevel1Bucket = false;	//by default, build level1 bucket

    this->noOffset = false; //by default, load offset    
}

C_SuffixArraySearchApplicationBase::~C_SuffixArraySearchApplicationBase()
{

}

/**
* When function findPhrasesInASentence(char * sentence, ...) is called to return the locations of all the embedded n-grams in sentence
* parameter highestFreqThresholdForReport is set so that very high frequent n-grams such as unigram "the" is skipped
* high frequent n-grams occur too often in the corpus and their statistics can often be estimated offline.
* Default value = -1 (no effective threshold)
**/
void C_SuffixArraySearchApplicationBase::setParam_highestFreqThresholdForReport(int highestFreqThresholdForReport)
{
    this->highestFreqThresholdForReport = highestFreqThresholdForReport;
}

/**
* When function findPhrasesInASentence(char * sentence, ...) is called to return the locations of all the embedded n-grams in sentence
* parameter shortestUnitToReport is set so that short n-grams can be skipped to speed up the process
* Default value = 1 (no effective constraint)
**/
void C_SuffixArraySearchApplicationBase::setParam_shortestUnitToReport(int shortestUnitToReport)
{
    this->shortestUnitToReport = shortestUnitToReport;
}

/**
* When function findPhrasesInASentence(char * sentence, ...) is called to return the locations of all the embedded n-grams in sentence
* parameter longestUnitToReport is set to skip long n-gram matches
*
* Default value = -1 (no effective limit, output all the matched n-grams no matter how long they are)
**/
void C_SuffixArraySearchApplicationBase::setParam_longestUnitToReport(int longestUnitToReport)
{
    this->longestUnitToReport = longestUnitToReport;
}

/**
* When function findPhrasesInASentence(char * sentence, ...) is called to return the locations of all the embedded n-grams in sentence
* parameter reportMaxOccurrenceOfOneNgram is set to output information of only the "first" few occurrences of the matched n-gram
* Since the order is based on the order of the corresponding suffices in the corpus,
* the output occurrences are usually not the first few occurrences of the n-gram in the corpus
**/
void C_SuffixArraySearchApplicationBase::setParam_reportMaxOccurrenceOfOneNgram(int reportMaxOccurrenceOfOneNgram)
{
    this->reportMaxOccurrenceOfOneNgram = reportMaxOccurrenceOfOneNgram;
}



/**
* Load the indexed corpus, suffix array, offset and vocabulary into memory
* Note: if C_SuffixArraySearchApplicationBase will be used in the application to return the sentenceId/offset in sentence for the matched n-gram
* then noOffset needs to be set to be false (to load the offset)
**/
void C_SuffixArraySearchApplicationBase::loadData_forSearch(const char * filename, bool noVoc, bool noOffset)
{

	this->loadData(filename, noVoc, noOffset, false);	//call the constructor of the super class, load data and build level1Bucket

	if(! this->noOffset){
        TextLenType lastSentId;
        unsigned char tmpOffset;
        this->locateSendIdFromPos(this->corpusSize - 3, lastSentId, tmpOffset);
        this->totalSentNum = lastSentId;
    }
    else{
        //we do not have offset information, simply travel to the sentence head
        TextLenType pos = this->corpusSize-3;
        while(this->corpus_list[pos]<this->sentIdStart){    //still actual words
            pos--;
        }
        //at this position, it should be the <sentId> for the last sentence
        this->totalSentNum = this->corpus_list[pos] - this->sentIdStart +1;
    }
    cerr<<"Total: "<<this->totalSentNum<<" sentences loaded.\n";

}


///return 0 if w = text
///return 1 if w < text
///return 2 if w > text
///given that the prefix of lcp words are the same
char C_SuffixArraySearchApplicationBase::comparePhraseWithTextWithLCP(IndexType vocInWord, int lcp, TextLenType posInText)
{   

    IndexType vocInText = this->corpus_list[posInText+lcp];

    if(vocInWord == vocInText){
        return 0;
    }
    
    if(vocInWord < vocInText){
        return 1;
    }

    return 2;
}

/** Utility function
* Convert an input sentence as char string into a vector of C_String objects
**/
vector<C_String> C_SuffixArraySearchApplicationBase::convertCharStringToCStringVector(const char * sentText)
{
	vector<C_String> sentAsStringVector;

	char tmpToken[MAX_TOKEN_LEN];
    memset(tmpToken,0,MAX_TOKEN_LEN);

    int pos = 0;

    int inputLen = strlen(sentText);

	for(int posInInput = 0; posInInput<inputLen; posInInput++){
        char thisChar = sentText[posInInput];

        if((thisChar==' ')||(thisChar=='\t')){  //delimiters
            if(strlen(tmpToken)>0){
                tmpToken[pos] = '\0';               
                sentAsStringVector.push_back(C_String(tmpToken));
                pos=0;
                tmpToken[pos] = '\0';
            }
        }
        else{
            tmpToken[pos] = thisChar;
            pos++;
            if(pos>=MAX_TOKEN_LEN){ //we can handle it
                fprintf(stderr,"Can't read tokens that exceed length limit %d. Quit.\n", MAX_TOKEN_LEN);
                exit(0);
            }
        }
    }

    tmpToken[pos] = '\0';
    if(strlen(tmpToken)>0){     
        sentAsStringVector.push_back(C_String(tmpToken));
    }

	return sentAsStringVector;

}

/**
* Utility function: convert a sentence as a vector of C_String to a vector of vocIDs
**/
vector<IndexType> C_SuffixArraySearchApplicationBase::convertCStringVectorToVocIdVector(vector<C_String> & sentAsStringVector)
{
	if(this->noVocabulary){
        cerr<<"Vocabulary not available!\n";
        exit(-1);
    }

	vector<IndexType> sentAsVocIdVector;

	for(int i=0;i<sentAsStringVector.size();i++){
		sentAsVocIdVector.push_back(this->voc->returnId(sentAsStringVector[i]));	
	}
	return sentAsVocIdVector;
}


/**
* Utility function:
* Convert a sentence as character string to a vector of vocIDs
**/
vector<IndexType> C_SuffixArraySearchApplicationBase::convertStringToVocId(const char * sentText)
{
	vector<C_String> sentAsCStringVector = this->convertCharStringToCStringVector(sentText);
	return this->convertCStringVectorToVocIdVector(sentAsCStringVector);
}


/**
* If know the range where the phrase is, search in this range for it
* position here are all positions in SA, not the positions in the textstring
* 
* LCP indicates that all the suffixes in the range has the same prefix with LCP length with the proposed n-gram phrase
* only need to compare the "nextWord" at LCP+1 position
*
* return true if such phrase can be found inside the range, false if not
**/
bool C_SuffixArraySearchApplicationBase::searchPhraseGivenRangeWithLCP(IndexType nextWord, int lcp, TextLenType rangeStartPos, TextLenType rangeEndPos, TextLenType &resultStartPos, TextLenType &resultEndPos)
{
    TextLenType leftPos, rightPos, middlePos;

    //in case the phrase to be searched is beyond the bucket although the first LCP word is the same as this bucket
    //e.g. range correspondes to [ab, ad], but we are searching for (aa)
    //so first step is to make sure the lcp+next word is still in this range
    if(this->comparePhraseWithTextWithLCP(nextWord, lcp, this->suffix_list[rangeStartPos])==1){
        //phrase+next word < text corresponding rangeStart, we could not find it inside this range
        return false;
    }

    if(this->comparePhraseWithTextWithLCP(nextWord, lcp, this->suffix_list[rangeEndPos])==2){
        //phrase+next word > text corresponding to rangeEnd
        return false;
    }
    
    //now we are sure that text(SA[rangeStart]) <= phrase <= text(SA[rangeEnd])


    //search for left bound ( the pos in text which is the min(text>=w))
    //at any time, Left<w<=Right (actually Left<=w<=Right)
    leftPos = rangeStartPos;
    rightPos = rangeEndPos; 
    while( rightPos > (leftPos+1)){ //at the time when right = left +1, we should stop

        middlePos = (TextLenType)((leftPos + rightPos) / 2);
        if(((leftPos + rightPos) % 2) != 0){            
            middlePos++; //bias towards right
        }

        if(this->comparePhraseWithTextWithLCP(nextWord, lcp, this->suffix_list[middlePos]) != 2 ){ 
            // phrase <= middlePos in Text, go left
            rightPos = middlePos;
        }
        else{
            leftPos = middlePos;    //word > middle, go right
        }

    }
    //in previous implementation, we can gurantee that Left<w, because we take rangeStartPos-- from original range
    //here we can only guarantee that Left<=w, so need to check if Left==w at lcp
    if(this->comparePhraseWithTextWithLCP(nextWord, lcp, this->suffix_list[leftPos])==0){
        resultStartPos = leftPos;
    }
    else{
        resultStartPos = rightPos;
    }

    //search for right bound ( the value which is the max(text<=w))
    //at any time, Left<w<=Right (actually Left<=w<=Right)
    leftPos = rangeStartPos;
    rightPos = rangeEndPos;         
    while( rightPos > (leftPos+1)){ //stop when right = left + 1
        middlePos = (TextLenType) ((leftPos + rightPos) / 2 );  //bias towards left
        
        if(this->comparePhraseWithTextWithLCP(nextWord, lcp, this->suffix_list[middlePos]) != 1 ){ // phrase >= middlePos in Text, go right
            leftPos = middlePos;
        }
        else{
            rightPos = middlePos;   // ==1, phrase < middlePos
        }
    }
    //in previous implementation, we can gurantee that w<Right, because we take rangeEndPos++ from original range
    //here we can only guarantee that w<=Right, so need to check if Right==w at lcp
    if(this->comparePhraseWithTextWithLCP(nextWord, lcp, this->suffix_list[rightPos])==0){
        resultEndPos = rightPos;
    }
    else{
        resultEndPos = leftPos;
    }

    if(resultEndPos>=resultStartPos){
        return true;
    }

    return false;   //could not find this phrase
}

///memory allocated here, remember to free the memory when the table is not needed any more in the 
///calling function
S_sentSearchTableElement * C_SuffixArraySearchApplicationBase::constructNgramSearchTable4SentWithLCP(const char * sentText, int & sentLen)
{
	vector<IndexType> sentInVocId = this->convertStringToVocId(sentText);
	sentLen = sentInVocId.size();

	return this->constructNgramSearchTable4SentWithLCP(sentInVocId);
}


///constructing the n-gram search table
///memory allocated here, remember to free the memory when the table is not needed any more in the 
///calling function
///
///faster than constructNgramSearchTable4Sent because the suffixes in the range given by n-1 gram can 
///guaranteed to have the first n-1 words to be the same as the n-1 gram
///only needs to compare the following one word 
///
/// for a sentence as:w1, w2,....
/// cell [i,j] in the table is for n-gram from w_(j-1)...w_(j+i-1), that is a 
/// (i+1)-gram starting at position j+1 in sentence
S_sentSearchTableElement * C_SuffixArraySearchApplicationBase::constructNgramSearchTable4SentWithLCP( vector<IndexType> & sentInVocId)
{
    int sentLen = sentInVocId.size();
    S_sentSearchTableElement * table = (S_sentSearchTableElement *) malloc( sentLen * sentLen * sizeof(S_sentSearchTableElement));
    
    //for consistency, initialize all cells
    for(int c=0;c<(sentLen*sentLen);c++){
        table[c].found = false;
        table[c].startPosInSA = 0;
        table[c].endingPosInSA = 0;
    }
    
    TextLenType startPos, endPos;

    //initialize word level elements
    for(int i=0;i<sentLen;i++){
        IndexType vocId = sentInVocId[i];
        //cout<<vocId<<" ";
        if((vocId==0)||(vocId>=this->sentIdStart)){ //vocId ==0 means this word is OOV <unk>, if vocId>=sentIdStart means for this corpus, we don't know this word
            table[i].found = false;
        }
        else{
            table[i].startPosInSA = this->level1Buckets[vocId].first;
            table[i].endingPosInSA = this->level1Buckets[vocId].last;

            if(table[i].startPosInSA<=table[i].endingPosInSA){
                table[i].found = true;
            }
            else{   //because vocabulary is built on top of an existing voc, this corpus may not have all the occurrences of all the words in the voc
                table[i].found = false;
            }
        }
    }
    

    //filling in the cells in the table row by row
    //basically this means we start by looking for smaller units first
    //if they are found, search for longer n-grams
    for(int n=1;n<sentLen;n++){ //finding n+1 gram. when n=sentLen-1, we are search for the occurrence of the whole sent
        int levelN_1_0 = (n - 1) * sentLen; //map from two dimensional position to one-dimension
        int levelN_0 = n * sentLen;
        for(int j=0;j<= (sentLen - 1 - n); j++){    //possible starting point for n+1 gram
            //necessary conditions that this n+1 gram exist are:
            //the two sub n-gram all exist in the corpus            
            if( table[levelN_1_0 + j].found && table[levelN_1_0 + j +1].found){
                IndexType nextWord = sentInVocId[j+n]; //the last word of the n+1 gram                              

                //n+1 gram has to be in the range of the n-gram in SA
                startPos = table[levelN_1_0 + j].startPosInSA;
                endPos = table[levelN_1_0 + j].endingPosInSA;

                TextLenType foundPosStart = 0;
                TextLenType foundPosEnd = 0;

                //the prefix of n words of all suffixes between [startPos, endPos] is the same as the
                //prefix of the n words in the proposed n+1 gram, no need to compare
                //only need to compare the n+1 word, which is "nextWord" here
                if(this->searchPhraseGivenRangeWithLCP(nextWord, n, startPos, endPos, foundPosStart, foundPosEnd)){                 
                    table[levelN_0 + j].found = true;
                    table[levelN_0 + j].startPosInSA =  foundPosStart;
                    table[levelN_0 + j].endingPosInSA = foundPosEnd;
                }
                else{
                    table[levelN_0 + j].found = false;
                }

            }
            else{
                table[levelN_0 + j].found = false;
            }
        }
    }
    return table;
}

void C_SuffixArraySearchApplicationBase::displayNgramMatchingFreq4Sent(const char * sent)
{
    vector<IndexType> sentInVocId = this->convertStringToVocId(sent);
    this->displayNgramMatchingFreq4Sent(sentInVocId);
}

void C_SuffixArraySearchApplicationBase::displayNgramMatchingFreq4Sent(vector<IndexType> & sentInVocId)
{
    int sentLen = sentInVocId.size();
    
    int i,j;

    //construct the n-gram search table    
    S_sentSearchTableElement * table = constructNgramSearchTable4SentWithLCP(sentInVocId);
  
    //show sentence
    cout<<"\t";
    for(i=0;i<sentLen;i++){
        cout<<this->voc->getText(sentInVocId[i]).toString()<<"\t";
    }
    cout<<endl;

    //show frequency of each n-gram
    i=0;
    bool stillMatch = true;
    while(stillMatch &&( i<sentLen)){
        cout<<i+1<<"\t";
        int startForRow = i*sentLen;
        bool anyGood = false;
        for(j=0;j<= (sentLen - 1 - i); j++){
            if(table[startForRow+j].found){
                //this is for regular case              
                if(table[startForRow+j].endingPosInSA>=table[startForRow+j].startPosInSA){  //more than one occurrence
                    cout<<table[startForRow+j].endingPosInSA-table[startForRow+j].startPosInSA + 1;
                    anyGood = true;
                }
                else{
                    cout<<"0";
                }
    
            }
            else{
                cout<<"0";
            }
            cout<<"\t";
        }

        stillMatch = anyGood;
        cout<<endl;
        i++;
    }
    
    free(table);
}

///given the pos of a word in corpus, return its offset in the sentence
///and the sentence ID
///offset has to be loaded
///we do not check it here for efficicency purposes
void C_SuffixArraySearchApplicationBase::locateSendIdFromPos(TextLenType pos, TextLenType & sentId, unsigned char & offset)
{
    offset = this->offset_list[pos];
    sentId = this->corpus_list[pos-offset] - this->sentIdStart + 1;

    offset--;   //because <s> is considered in the corpus when indexing the SA, but there is no <s> in the real corpus
}

void C_SuffixArraySearchApplicationBase::locateSendIdFromPos(TextLenType pos, TextLenType & sentId, unsigned char & offset, unsigned char & sentLen)
{
    offset = this->offset_list[pos];
    sentLen = this->offset_list[pos-offset];
    sentId = this->corpus_list[pos-offset] - this->sentIdStart + 1;

    offset--;   //because <s> is considered in the corpus when indexing the SA, but there is no <s> in the real corpus
}

// if minApproxCovScore is 0, returned shared ngrams
//
// if minApproxCovScore is bigger than 0, we are in fuzzy modus:
// - if the approximate coverage score of a sentence is smaller than minApproxCovScore, ignore the sentence
// - if nBest is not 0, ignore all but the exact matches and the nBest sentences with the highest fuzzy score; if sentence nBest in the ranked list of fuzzy scores has the same score as sentence nBest + 1, keep all sentences
//   with that score, unless sentence nBest*2 has the same score and the score is not the maximal fuzzy score (i.e. we always keep all sentences with the maximal fuzzy score, and when keeping some lower score has the effect that
//   nBest is being exceeded too much, we only keep sentences with higher fuzzy scores)
// - store sentences, their ID, their approximate coverage score, the start and end positions of their matching parts and the queryDown flag (see below) in bestFuzzySents;
//   sentences are ranked according to approximate coverage score, from low to high
// - we keep track of all words W in the query sentence which are present in some ngram shared with some sentence; if there are less words W than words in the matching parts in a sentence S,
//   we are sure that the actual coverage of S is smaller than the number of words in the matching parts (e.g. S contains some ngram twice, while query sentence contains it only once);
//   in that case, the approximate coverage score is based on W rather than on the number of words in matching parts in S, and the queryDown flag is set to 1 (flag is purely informative)
//   e.g. query sentence is "the house is black"
//        sentence 1 is "the house was red and the house was small"
//        sentence 2 is "the house looked black"
//        sentence 3 is "a cat"
//        -> if shortestUnitToReport is 2, there are two shared ngrams in sentence 1 ("the house" and "the house"), hence approximate coverage score of 4/9; 3 words in query sentence are part of
//           shared ngrams ("the", "house", "black"); therefore, approximate coverage score of 4/9 is reduced to 3/9
// - return shared ngrams for the sentences in bestFuzzySents
vector<S_phraseLocationElement> C_SuffixArraySearchApplicationBase::findPhrasesInASentence(vector<IndexType> & srcSentAsVocIDs,double minApproxCovScore,unsigned int nBest,vector<fuzzyCovSent> & bestFuzzySents)
{
    if(srcSentAsVocIDs.size()>255){
        cerr<<"Sorry, I prefer to handle sentences with less than 255 words. Please cut the sentence short and try it again.\n";
        exit(0);
    }

    unsigned char sentLen = (unsigned char) srcSentAsVocIDs.size();

    //construct the n-gram search table 
    S_sentSearchTableElement * table = constructNgramSearchTable4SentWithLCP(srcSentAsVocIDs);

    //Now, we know all the n-grams we are looking for
    //output the results
    vector<S_phraseLocationElement> allFoundNgrams;
    S_phraseLocationElement tmpNode;    

    int longestUnitToReportForThisSent = sentLen;
    if(this->longestUnitToReport!=-1){
        //and if longestUnitToReport is shorter than sentLen
        if(this->longestUnitToReport<sentLen){
            longestUnitToReportForThisSent = this->longestUnitToReport;
        }
    }

    tr1::unordered_map<unsigned int,fuzzyCovSent> fuzzyCovSents; // we also store sentence ID inside fuzzyCovSent, because the fuzzyCovSent structures will end up in vector (bestFuzzySents)

    // store info on query sentence, merely for checking coverage
    fuzzyCovSents[0].numWords=sentLen;
    fuzzyCovSents[0].coverage=wordsCovered(); // all bits are set to 0

    // look for shared ngrams
    //
    // in fuzzy modus, add sentences, their ID and approximate coverage to fuzzyCovSents; longestUnitToReportForThisSent should be extremely high, and shortestUnitToReport reasonably high
    unsigned int fuzzyCovSentNum=0; // we do not count the query sentence
    for(unsigned char r = longestUnitToReportForThisSent - 1; r>= this->shortestUnitToReport-1; r--){ // we go from long ngrams to shorter ones, as we may add some heuristics for fuzzy modus later on
        int firstPosInRow = r*sentLen;
        for(unsigned char c=0; c<= (sentLen - 1 - r); c++){
            if(table[firstPosInRow + c].found){ //at this position the ngram was found
		for (unsigned char p=c;p<=r+c;p++){
		  fuzzyCovSents[0].coverage.set(p);
		}
                tmpNode.posStartInSrcSent = c + 1;  //position starts from 1
                tmpNode.posEndInSrcSent = r + c + 1;

                //now for all ocurrences, find their sentId and realative positions
                TextLenType startPosInSA = table[firstPosInRow + c].startPosInSA;
                TextLenType endPosInSA = table[firstPosInRow + c].endingPosInSA;

                if( (this->highestFreqThresholdForReport <= 0) ||    //no limit
                    ( (this->highestFreqThresholdForReport > 0 ) && ( (endPosInSA - startPosInSA) < this->highestFreqThresholdForReport ))
                ){  
                    // we don't want to retrieve high-freq n-gram which is very time consuming
                    //and meaningless for translation, such as 1M occurrences of "of the" in the corpus
		    // in case of fuzzy modus, there should be no limit
                    if((this->reportMaxOccurrenceOfOneNgram > 0) && ( (endPosInSA - startPosInSA +1) > this->reportMaxOccurrenceOfOneNgram) ){
                        //and for each n-gram, report only a limited amount of occurrences
		        // do not use this in case of fuzzy modus
                        endPosInSA = startPosInSA + this->reportMaxOccurrenceOfOneNgram - 1;
                    }

                    unsigned int sentId;
                    unsigned char posInSent;
                    for(TextLenType iterator =startPosInSA; iterator <=endPosInSA; iterator++ ){
                        this->locateSendIdFromPos(this->suffix_list[iterator], sentId, posInSent);
                        tmpNode.sentIdInCorpus = sentId;
                        tmpNode.posInSentInCorpus = posInSent;
                        allFoundNgrams.push_back(tmpNode);

                        if (minApproxCovScore>0){
			  tr1::unordered_map<unsigned int,fuzzyCovSent>::const_iterator gotId = fuzzyCovSents.find(sentId);
			  if (gotId==fuzzyCovSents.end()){
                            fuzzyCovSentNum++;
			    stringstream sentStream;
			    bool startStream=true;
			    for (IndexType pos=this->suffix_list[iterator]-posInSent+1;
				 (this->corpus_list[pos]!=this->vocIdForSentEnd) && (this->corpus_list[pos]!=this->vocIdForCorpusEnd);
				 pos++){
			      sentStream << (startStream ? "" : " ") << this->voc->getText(this->corpus_list[pos]).toString();
			      startStream=false;
			    }
			    fuzzyCovSents[sentId].sentId=sentId;
                            fuzzyCovSents[sentId].sent=sentStream.str();
			    fuzzyCovSents[sentId].numWords=convertStringToVocId(sentStream.str().c_str()).size();
			    fuzzyCovSents[sentId].coverage=wordsCovered();
         		  }
			  for (unsigned char p=0;p<=r;p++){
			    fuzzyCovSents[sentId].coverage.set(tmpNode.posInSentInCorpus+p-1);
			  }
			}
                    }
                }
            }
        }
    }
    
    free(table);

    if (minApproxCovScore==0){ return allFoundNgrams; }

    // if approximate coverage score of sentence is at least minApproxCovScore, add score to fuzzyCovSents, add queryDown flag to it and memorize score in approxCovScores
    tr1::unordered_map<unsigned int,fuzzyCovSent>::const_iterator itr;
    double approxCovScores[fuzzyCovSentNum];
    double approxCovScore;
    unsigned int retainedScoreCount=0;
    unsigned int sentId;
    for (itr = fuzzyCovSents.begin(); itr != fuzzyCovSents.end(); itr++){
      if ((sentId=(*itr).first)==0) continue; // skip the query sentence
      approxCovScore=double(min(fuzzyCovSents[sentId].coverage.count(),fuzzyCovSents[0].coverage.count()))/max(fuzzyCovSents[sentId].numWords,fuzzyCovSents[0].numWords);
      if (approxCovScore<minApproxCovScore) continue;
      fuzzyCovSents[sentId].approxCovScore=approxCovScore;
      fuzzyCovSents[sentId].queryDown=(fuzzyCovSents[sentId].coverage.count()>fuzzyCovSents[0].coverage.count());
      approxCovScores[retainedScoreCount++]=approxCovScore;
    }

    // cout << retainedScoreCount << " of the " << fuzzyCovSentNum << " scores are high enough" << endl;

    if (retainedScoreCount==0){
      allFoundNgrams.clear();
      return allFoundNgrams;
    }

    // increase minApproxCovScore if nBest requires so
    sort(approxCovScores,approxCovScores+retainedScoreCount,std::greater<double>());
    // for (unsigned int i=0;i<retainedScoreCount;i++){ cout << i << " " << approxCovScores[i] << endl; }
    unsigned int i;
    for (i=0;(i<retainedScoreCount) && (approxCovScores[i]==1);i++){};
    unsigned int numExact=i;
    if ((nBest>0) && (retainedScoreCount>numExact+nBest)){
      minApproxCovScore=approxCovScores[numExact+nBest-1];
      if (approxCovScores[numExact+nBest]==minApproxCovScore){
	if ((retainedScoreCount>=numExact+(nBest*2)) && (approxCovScores[numExact+(nBest*2)-1]==minApproxCovScore) && (approxCovScores[numExact]>minApproxCovScore)){
	  for (i=numExact+nBest-2;(i>numExact) && (approxCovScores[i]==minApproxCovScore);i--){}
	  minApproxCovScore=approxCovScores[i];
	}
      }
    }
    
    // cout << "minApproxCovScore, possibly updated: " << minApproxCovScore << endl;

    // keep shared ngrams of all relevant sentences
    vector<S_phraseLocationElement> retainedNgrams;
    for (i=0;i<allFoundNgrams.size();i++){
      if (fuzzyCovSents[allFoundNgrams[i].sentIdInCorpus].approxCovScore>=minApproxCovScore){
        retainedNgrams.push_back(allFoundNgrams[i]); // we add to new vector rather than erase from old as erasing elements from vector is inefficient
      }
      // else cout << "We ignore sentence " << allFoundNgrams[i].sentIdInCorpus << ": approximate coverage score is " << fuzzyCovSents[allFoundNgrams[i].sentIdInCorpus].approxCovScore << endl;
    }

    // keep the relevant sentences and determine their matching parts
    for (itr = fuzzyCovSents.begin(); itr != fuzzyCovSents.end(); itr++){
      if ((sentId=(*itr).first)==0) continue; // skip the query sentence
      if (fuzzyCovSents[sentId].approxCovScore>=minApproxCovScore){
	fuzzyCovSents[sentId].partNum=0;
	for (unsigned char p=0;p<255;p++){
          if (fuzzyCovSents[sentId].coverage[p]){
	    if ((p==0) || !fuzzyCovSents[sentId].coverage[p-1]){ fuzzyCovSents[sentId].begParts[(++fuzzyCovSents[sentId].partNum)-1]=p; }
  	    if ((p==254) || !fuzzyCovSents[sentId].coverage[p+1]){ fuzzyCovSents[sentId].endParts[fuzzyCovSents[sentId].partNum-1]=p; }
	  }
	}
	bestFuzzySents.push_back(fuzzyCovSents[sentId]);
      }
    }

    sort(bestFuzzySents.begin(),bestFuzzySents.end());

    return retainedNgrams;
}

vector<S_phraseLocationElement> C_SuffixArraySearchApplicationBase::findPhrasesInASentence(const char * srcSent,double minApproxCovScore,unsigned int nBest,vector<fuzzyCovSent> & bestFuzzySents)
{
    //use the vocabulary associated with this corpus to convert words to vocIDs
    vector<IndexType> srcSentAsVocIDs = this->convertStringToVocId(srcSent);

    return this->findPhrasesInASentence(srcSentAsVocIDs,minApproxCovScore,nBest,bestFuzzySents);
}

bool C_SuffixArraySearchApplicationBase::locateSAPositionRangeForExactPhraseMatch(vector<IndexType> & phrase, TextLenType & rangeStart, TextLenType & rangeEnd)
{
    int phraseLen = phrase.size();

    //first check if there are any <unk> in the phrase
    for(int i=0;i<phrase.size();i++){
        if((phrase[i]==0)||(phrase[i]>=this->sentIdStart)){
            return false;   //return empty matching result
        }
    }

    TextLenType currentRangeStart, currentRangeEnd;
    TextLenType narrowedRangeStart, narrowedRangeEnd;
    IndexType vocId;

    //for word 1
    vocId = phrase[0];
    currentRangeStart = this->level1Buckets[vocId].first;
    currentRangeEnd = this->level1Buckets[vocId].last;

    if(currentRangeStart>currentRangeEnd){
        return false;   //even this 1-gram does not exist
    }

    int posInPhrase = 1;    
    while( posInPhrase<phraseLen ){
        vocId = phrase[posInPhrase];
        bool stillExist = this->searchPhraseGivenRangeWithLCP(vocId, posInPhrase, currentRangeStart, currentRangeEnd, narrowedRangeStart, narrowedRangeEnd);

        if(! stillExist){
            return false;
        }
        
        currentRangeStart = narrowedRangeStart;
        currentRangeEnd = narrowedRangeEnd;

        posInPhrase++;
    }

    //we find the range of matching phrase, now get the sentId
    rangeStart = currentRangeStart;
    rangeEnd = currentRangeEnd;

    return true;
}

///similar to construct the freq table
///but only search for the exact phrase matching
///Important: because locateSentIdFromPos is called which requires the offset information
///Suffix array has to be initialized with offset loaded
///i.e. initilized with loadData_forSearch(corpusName, bool noVoc, noOffset=fase)
///otherwise the program will have segmentation fault
///SALM does not check if offset has been loaded already for efficiency reasons because locateSendIdFromPos() is called frequently
vector<S_SimplePhraseLocationElement> C_SuffixArraySearchApplicationBase::locateExactPhraseInCorpus(vector<IndexType> & phrase)
{
    vector<S_SimplePhraseLocationElement> matchingResult;

    TextLenType rangeStart, rangeEnd;

    if(this->locateSAPositionRangeForExactPhraseMatch(phrase, rangeStart, rangeEnd)){
        //we find some match
        S_SimplePhraseLocationElement tmpNode;
        for(TextLenType saPos = rangeStart; saPos <= rangeEnd; saPos++){
            this->locateSendIdFromPos(this->suffix_list[saPos], tmpNode.sentIdInCorpus, tmpNode.posInSentInCorpus);
            matchingResult.push_back(tmpNode);
        }
    }

    return matchingResult;
}

vector<S_SimplePhraseLocationElement> C_SuffixArraySearchApplicationBase::locateExactPhraseInCorpus(const char *phrase)
{
    //use the vocabulary associated with this corpus to convert words to vocIds
    vector<IndexType> phraseAsVocIDs = this->convertStringToVocId(phrase);

    return this->locateExactPhraseInCorpus(phraseAsVocIDs);
}


TextLenType C_SuffixArraySearchApplicationBase::freqOfExactPhraseMatch(vector<IndexType> & phrase)
{
    TextLenType rangeStart, rangeEnd;

    if(this->locateSAPositionRangeForExactPhraseMatch(phrase, rangeStart, rangeEnd)){
        return rangeEnd - rangeStart + 1;
    }

    return 0;
}

TextLenType C_SuffixArraySearchApplicationBase::freqOfExactPhraseMatch(const char *phrase)
{
    //use the vocabulary associated with this corpus to convert words to vocIds
    vector<IndexType> phraseAsVocIDs = this->convertStringToVocId(phrase);

    return this->freqOfExactPhraseMatch(phraseAsVocIDs);
}


TextLenType C_SuffixArraySearchApplicationBase::freqOfExactPhraseMatchAndFirstOccurrence(vector<IndexType> & phrase, TextLenType & startPosInSA, int & sentLen)
{
    TextLenType rangeStart, rangeEnd;
	
	sentLen = phrase.size();

    if(this->locateSAPositionRangeForExactPhraseMatch(phrase, rangeStart, rangeEnd)){
		startPosInSA = rangeStart;
        return rangeEnd - rangeStart + 1;
    }

    return 0;
}

TextLenType C_SuffixArraySearchApplicationBase::freqOfExactPhraseMatchAndFirstOccurrence(const char *phrase, TextLenType & startPosInSA, int & sentLen)
{
    //use the vocabulary associated with this corpus to convert words to vocIds
    vector<IndexType> phraseAsVocIDs = this->convertStringToVocId(phrase);

    return this->freqOfExactPhraseMatchAndFirstOccurrence(phraseAsVocIDs, startPosInSA, sentLen);
}


TextLenType C_SuffixArraySearchApplicationBase::returnTotalSentNumber()
{
    return this->totalSentNum;
}

///given src sentence length, convert the index in one-dimensional table to pair<startingPosInSrcSent, n>
///startingPosInSrcSent starts at 0, n is the n-gram length
void C_SuffixArraySearchApplicationBase::oneDimensionTableIndexToTwoDimension(unsigned int index, unsigned int sentLen, unsigned int &posInSrcSent, unsigned int &n)
{
    n = index / sentLen + 1;
    posInSrcSent = index % sentLen;
}

///given the starting position in src sentence and the length of the n-gram
///calculate the index in the table
///posInSent starts at 0, n is the actual len of n-gram, starts at 1
unsigned int C_SuffixArraySearchApplicationBase::twoDimensionIndexToOneDimensionTableIndex(unsigned int posInSent, unsigned int n, unsigned int sentLen)
{
    unsigned int indexInTable = (n-1)*sentLen + posInSent;

    return indexInTable;
}

///simple return how many n-grams are matched
unsigned int C_SuffixArraySearchApplicationBase::numberOfMatcedNgram(const char *srcSent)
{   
    vector<IndexType> sentInVocId = this->convertStringToVocId(srcSent);
    return this->numberOfMatcedNgram(sentInVocId);
}

///simply return how many n-grams are matched
unsigned int C_SuffixArraySearchApplicationBase::numberOfMatcedNgram(vector<IndexType> & sentInVocId)
{       
    int sentLen = sentInVocId.size();

    S_sentSearchTableElement * table = this->constructNgramSearchTable4SentWithLCP(sentInVocId);

    unsigned int totalMatched = 0;

    for(unsigned int i=0;i<(sentLen*sentLen);i++){      
        if(table[i].found){
            totalMatched++;
        }           
    }

    free(table);
    return totalMatched;
}


map<int, pair<int, unsigned long> > C_SuffixArraySearchApplicationBase::returnNGramMatchingStatForOneSent(const char * srcSent, int & sentLen)
{
	vector<IndexType> sentInVocId = this->convertStringToVocId(srcSent);
	return this->returnNGramMatchingStatForOneSent(sentInVocId, sentLen);
}

map<int, pair<int, unsigned long> > C_SuffixArraySearchApplicationBase::returnNGramMatchingStatForOneSent(vector<IndexType> & sentInVocId, int &sentLen)
{
	sentLen = sentInVocId.size();
	map<int, pair<int, unsigned long> > nGramMatched;
	map<int, pair<int, unsigned long> >::iterator iterNGramMatched;

	//construct the n-gram search table
	S_sentSearchTableElement * table = this->constructNgramSearchTable4SentWithLCP(sentInVocId);
  
	for(int n = 1; n <= sentLen; n++){		
		for(int startPos=0; startPos <= (sentLen - n); startPos++){
			int indexInTable = this->twoDimensionIndexToOneDimensionTableIndex(startPos, n, sentLen);

			if(table[indexInTable].found){
				
				unsigned long freqInTraining = table[indexInTable].endingPosInSA - table[indexInTable].startPosInSA + 1;
				iterNGramMatched = nGramMatched.find(n);
				if(iterNGramMatched==nGramMatched.end()){//has not seen this before
					nGramMatched.insert(make_pair(n, make_pair(1, freqInTraining) ));
				}
				else{
					iterNGramMatched->second.first++;
					iterNGramMatched->second.second+=freqInTraining;
				}
			}
		}
	}
	
	free(table);
  
	return nGramMatched;
}

