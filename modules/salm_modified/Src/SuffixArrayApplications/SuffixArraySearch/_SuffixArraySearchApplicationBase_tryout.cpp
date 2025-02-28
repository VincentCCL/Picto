/**
* Revision $Rev: 3794 $
* Last Modified $LastChangedDate: 2007-06-29 02:17:32 -0400 (Fri, 29 Jun 2007) $
**/

#include "_SuffixArraySearchApplicationBase.h"
#include <iostream>
#include <sstream>
#include <tr1/unordered_map>
#include <bitset>

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

// if showSents is true, uniqSents2Ids maps unique sentences in matches to ID(s), for reference
//
// if fuzzyMaxDiffLongest is not -1, do not memorize ngrams containing less than fuzzyMaxDiffLongest words than the longest ngram found in the suffix array for the sentence,
// only consider one sentence ID per unique sentence (that ID will also be the first one to appear in the mapped value in uniqSents2Ids) and
// ignore the corpus sentences that will theoretically be the least interesting when determining subsets of ngrams shared between query sentence and corpus sentence
// (the larger the part of the corpus sentence that is covered by all the ngram matches in that sentence, the more likely its usefulness for fuzzy matching; after ranking
// unique sentences according to their coverage, we set a minimal coverage such that keeping all sentences with at least that coverage does not lead to more than
// a set of maxKeepSentIds sentences; if we have more than maxKeepSentIds sentences with maximal coverage, we keep an arbitrary part of them)
vector<S_phraseLocationElement> C_SuffixArraySearchApplicationBase::findPhrasesInASentence(vector<IndexType> & srcSentAsVocIDs,bool & showSents,tr1::unordered_map<string,string> *uniqSents2Ids,int & fuzzyMaxDiffLongest,int & maxKeepSentIds)
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

    tr1::unordered_map<unsigned int,bool> uniqSentIds; // given a group of sentence IDs with same sentence, map the first ID encountered to "true", the others to false
    uniqSents2Ids->clear();

    typedef bitset<255> wordsCovered;

    // for each sentence ID mapped to "true" in uniqSentIds, use a bit string to keep track of the words in the sentence covered by matches
    // additionally, use key 0 for storing the coverage of the query sentence
    tr1::unordered_map<unsigned int,wordsCovered> uniqSentIdsCoverage;
    // for each sentence ID, the length of the longest ngram shared with the query sentence
    tr1::unordered_map<unsigned int,char> uniqSentIdsMaxSharedLen;

    uniqSentIdsCoverage[0]=wordsCovered(); // all bits are set to 0
    int lenLongest=0;
    for(unsigned char r = longestUnitToReportForThisSent - 1; r>= this->shortestUnitToReport-1; r--){
        // cout<<lenLongest<<" "<<fuzzyMaxDiffLongest<<" "<<(int)r<<" "<<longestUnitToReportForThisSent<<" "<<this->shortestUnitToReport<<" "<<(int)sentLen<<endl;
        //if ((lenLongest>0) && (fuzzyMaxDiffLongest!=-1) && (r+1<lenLongest-fuzzyMaxDiffLongest)){
	//  break;
        //}

        int firstPosInRow = r*sentLen;
        for(unsigned char c=0; c<= (sentLen - 1 - r); c++){
            if(table[firstPosInRow + c].found){ //at this position the ngram was found
		for (unsigned char p=c;p<=r+c;p++){
		  uniqSentIdsCoverage[0].set(p+1);
		}
	        //if (lenLongest==0){
		//  lenLongest=r+1;
		//}
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
                                   
                    if((this->reportMaxOccurrenceOfOneNgram > 0) && ( (endPosInSA - startPosInSA +1) > this->reportMaxOccurrenceOfOneNgram) ){
                        //and for each n-gram, report only a limited amount of occurrences
                        endPosInSA = startPosInSA + this->reportMaxOccurrenceOfOneNgram - 1;
                    }

                    unsigned int sentId;
                    unsigned char posInSent;
                    for(TextLenType iterator =startPosInSA; iterator <=endPosInSA; iterator++ ){
                        this->locateSendIdFromPos(this->suffix_list[iterator], sentId, posInSent);
                        tmpNode.sentIdInCorpus = sentId;
                        tmpNode.posInSentInCorpus = posInSent;

                        if (showSents || (fuzzyMaxDiffLongest!=-1)){
			  // only check for sentence corresponding to ID if needed (i.e. if we did not store ID in uniqSentIds yet)
			  tr1::unordered_map<unsigned int,bool>::const_iterator gotId = uniqSentIds.find(sentId);
			  if (gotId == uniqSentIds.end()){
			    stringstream sentStream;
			    stringstream sentIdStream;
			    bool startStream=true;
			    for (IndexType i=this->suffix_list[iterator]-posInSent+1;
				 (this->corpus_list[i]!=this->vocIdForSentEnd) && (this->corpus_list[i]!=this->vocIdForCorpusEnd);
				 i++){
			      sentStream << (startStream ? "" : " ") << this->voc->getText(this->corpus_list[i]).toString();
			      startStream=false;
			    }
			    sentIdStream << " " << sentId;
			    tr1::unordered_map<string,string>::const_iterator gotSent = uniqSents2Ids->find(sentStream.str());
			    uniqSentIds[sentId]=(gotSent == uniqSents2Ids->end());
			    (*uniqSents2Ids)[sentStream.str()].append(sentIdStream.str());
                            if ((fuzzyMaxDiffLongest!=-1) && uniqSentIds[sentId]){ // check whether we are looking for fuzzy matches
			      uniqSentIdsCoverage[sentId]=wordsCovered();
			      uniqSentIdsMaxSharedLen[sentId]=0;
			    }
			  }
			}

                        if (fuzzyMaxDiffLongest==-1){
			  allFoundNgrams.push_back(tmpNode);
			}
			else if (uniqSentIds[sentId]){
			  if (uniqSentIdsMaxSharedLen[sentId]==0){
			    uniqSentIdsMaxSharedLen[sentId]=r+1;
			  }
			  else if (uniqSentIdsMaxSharedLen[sentId]-r-1>fuzzyMaxDiffLongest){
			    continue;
			  }
			  allFoundNgrams.push_back(tmpNode);
			  for (unsigned char p=0;p<=r;p++){
			    uniqSentIdsCoverage[sentId].set(tmpNode.posInSentInCorpus+p);
			  }
			}
		    }           
                }
            }
        }
    }
    
    free(table);

    if (fuzzyMaxDiffLongest==-1){
      return allFoundNgrams;
    }

    // find out how much unique corpus sentences have a potential match coverage of X words (the coverage can never be higher than the coverage of the query sentence:
    // we may have a shared ngram which occurs multiple times in a corpus sentence but only once in the query sentence)
    // loop from the highest match coverage down to the match coverage MINCOV for which the set of sentences with this coverage or higher <= maxKeepSentIds
    // ignore sentences with a match coverage below MINCOV; if there are more than maxKeepSentIds maximum-coverage sentences, set MINCOV to their coverage and
    // ignore a part of the sentences
    //
    //  example 1:
    //
    //  maxKeepSentIds = 1000
    //
    //  number of sents with coverage 12  (change to coverage 10)              10
    //                       coverage 11  (change to coverage 10)              15
    //                       coverage 10  (= coverage of query sentence)       34           -> 10 + 15 + 34 = 59 sentences with potential match coverage of 10
    //                       coverage 9                                        251          -> 59 + 251 = 310 sentences with potential match coverage of 9
    //                       coverage 8                                        270          -> 310 + 270 = 580 sentences with potential match coverage of 8
    //                       coverage 7                                        588          -> ignore sentences with this coverage (580 + 588 > maxKeepSentIds) 
    //                       coverage 6                                        1214         -> ignore
    //
    //  -> MINCOV is 8
    //
    //  example 2:
    //
    //  maxKeepSentIds = 50
    //  -> given the coverage numbers above, we set MINCOV to 10 and ignore an arbitrary 9 of the 59 sentences with that coverage

    // get the frequencies of the coverages, after changing coverages to that of query sentence if necessary
    tr1::unordered_map<unsigned int,wordsCovered>::const_iterator itr;
    int covFreq[256]={0};
    for (itr = uniqSentIdsCoverage.begin(); itr != uniqSentIdsCoverage.end(); itr++){
      if ((*itr).first==0) continue; // skip the coverage of the query sentence itself
      covFreq[min(uniqSentIdsCoverage[(*itr).first].count(),uniqSentIdsCoverage[0].count())]++;
      // cout << "Sentence " << (*itr).first << ": " << uniqSentIdsCoverage[(*itr).first].count() << " " << uniqSentIdsCoverage[0].count() << endl;
    }

    // find out MINCOV
    int numRetainedIds=0;
    int minCov,maxCov=0;
    for (minCov=255;
         (minCov>0) && ((numRetainedIds==0) || ((minCov>=(int)(maxCov/2)) && (numRetainedIds+covFreq[minCov]<=maxKeepSentIds)));
	 numRetainedIds+=covFreq[minCov],minCov--){
      if ((maxCov==0) && (covFreq[minCov]>0)) maxCov=minCov;
      // cout << minCov << ": " << numRetainedIds << endl;
    }
    minCov++;
    // cout << "minCov: " << minCov << " " << covFreq[minCov-1] << " " << numRetainedIds << " " << endl;
    
    // there are more than maxKeepSentIds maximum-coverage sentences:
    // set coverage of some sentences to none, so they will be erased from allFoundNgrams and uniqSents2Ids later on
    if (numRetainedIds > maxKeepSentIds){
      numRetainedIds=0;
      for (itr = uniqSentIdsCoverage.begin(); itr != uniqSentIdsCoverage.end(); itr++){
        // >= minCov: frequency is that before changing to query sentence coverage
	if (((*itr).first>0) && (uniqSentIdsCoverage[(*itr).first].count()>=minCov) && (++numRetainedIds>maxKeepSentIds)){
	  uniqSentIdsCoverage[(*itr).first]=wordsCovered();
	}
      }
    }
      
    // keep shared ngrams of all relevant sentences
    vector<S_phraseLocationElement> retainedNgrams;
    for (int i=0;i<allFoundNgrams.size();i++){
      if (uniqSentIdsCoverage[allFoundNgrams[i].sentIdInCorpus].count()>=minCov){
        retainedNgrams.push_back(allFoundNgrams[i]);
      }
      // else cout << "We ignore sentence " << allFoundNgrams[i].sentIdInCorpus << ": coverage is " uniqSentIdsCoverage[allFoundNgrams[i].sentIdInCorpus].count() << endl;
    }

    // keep all relevant sentences and their sentence ID(s)
    tr1::unordered_map<string,string>::const_iterator itr2;
    for (itr2 = uniqSents2Ids->begin(); itr2 != uniqSents2Ids->end();){
      string sentIds=(*uniqSents2Ids)[(*itr2).first];
      // cout << sentIds << ": " << sentIds.substr(1,min(sentIds.find(" ",1),sentIds.length()-1)).c_str() << endl;
      if (uniqSentIdsCoverage[atoi(sentIds.substr(1,min(sentIds.find(" ",1),sentIds.length()-1)).c_str())].count()<minCov){ // skip the string-initial space
	itr2=(*uniqSents2Ids).erase(itr2);
      }
      else itr2++;
    }

    return retainedNgrams;
}

vector<S_phraseLocationElement> C_SuffixArraySearchApplicationBase::findPhrasesInASentence(const char * srcSent,bool & showSents,tr1::unordered_map<string,string> *uniqSents2Ids,int & fuzzyMaxDiffLongest,int & maxKeepSentIds)
{
    //use the vocabulary associated with this corpus to convert words to vocIDs
    vector<IndexType> srcSentAsVocIDs = this->convertStringToVocId(srcSent);

    return this->findPhrasesInASentence(srcSentAsVocIDs,showSents,uniqSents2Ids,fuzzyMaxDiffLongest,maxKeepSentIds);
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

