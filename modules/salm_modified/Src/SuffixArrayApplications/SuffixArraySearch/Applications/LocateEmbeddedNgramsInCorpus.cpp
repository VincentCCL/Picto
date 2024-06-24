#include "stdio.h"
#include "stdlib.h"
#include <vector>
#include <iostream>
#include <tr1/unordered_map>
#include "_SuffixArraySearchApplicationBase.h"

using namespace std;


/**
* Return locations of all the embedded n-grams of a sentence in the indexed corpus
*
* Revison $Rev: 3794 $
* Last modified: $LastChangedDate: 2007-06-29 02:17:32 -0400 (Fri, 29 Jun 2007) $
**/
int main(int argc, char * argv[]){

	//-----------------------------------------------------------------------------
	//check arguments
	if(argc<2){		
		fprintf(stderr,"\n\nOutput locations of all the matched embedded n-grams of a sentence in an indexed corpus\n");
		fprintf(stderr,"\nUsage:\n");
		fprintf(stderr,"\n%s corpusFileNameStem [highestFreq maxRet smallestUnit longestUnit [minApproxCovScore nBest]? ] < list of sentences\n\n",argv[0]);
		fprintf(stderr,"\nIf minApproxCovScore > 0, fuzzy match modus is activated: print sentences with their ID, approximate coverage, queryDown flag and matching part positions\n");
		
		exit(-1);
	}
	

    int highFreq;
    int maxRet;
    int smallestUnit;
    int longestUnit;
    double minApproxCovScore=0;
    unsigned int nBest=0; // unlimited by default

	C_SuffixArraySearchApplicationBase saObj;

	saObj.loadData_forSearch(argv[1], false, false);

	if(argc>=6){	//if argument of highestFreq, maxRet, smallestUnits are set
		highFreq = atoi(argv[2]);
		maxRet = atoi(argv[3]);
		smallestUnit = atoi(argv[4]);
		longestUnit = atoi(argv[5]);

		saObj.setParam_highestFreqThresholdForReport(highFreq);
		saObj.setParam_reportMaxOccurrenceOfOneNgram(maxRet);
		saObj.setParam_shortestUnitToReport(smallestUnit);
                saObj.setParam_longestUnitToReport(longestUnit);
	}
        if (argc>6){
	{
          minApproxCovScore=strtod(argv[6],NULL);
	  nBest=atoi(argv[7]);
	}

	cerr<<"Input sentences:\n";

	char sentence[10000];

        vector<fuzzyCovSent> bestFuzzySents;
	
	while(!cin.eof()){
		cin.getline(sentence,10000,'\n');
		if(strlen(sentence)>0){

			vector<C_String> sentAsCStringVector = saObj.convertCharStringToCStringVector(sentence);	//for later display purpose
			
			
			vector<S_phraseLocationElement> locations;
			bestFuzzySents.clear();
			locations = saObj.findPhrasesInASentence(sentence,minApproxCovScore,nBest,bestFuzzySents);
		  
			if(locations.size()==0){
				cout<<"Nothing can be found in the corpus.\n";
                                if (minApproxCovScore>0){
                                  cout << "0 " << sentence << endl;
				}
			}
			else{
				for(unsigned int i=0;i<locations.size(); i++){
					cout<<"N-gram ["<<(int)locations[i].posStartInSrcSent<<", "<<(int)locations[i].posEndInSrcSent<<"]: ";
					for(int j=locations[i].posStartInSrcSent; j<=locations[i].posEndInSrcSent; j++){
						cout<<sentAsCStringVector[j-1].toString()<<" ";
					}
					cout<<" found in corpus: ";
					cout<<"SentId="<<locations[i].sentIdInCorpus<<" Pos="<<(int)locations[i].posInSentInCorpus<<endl;
				}

                                // format: <sentence ID><tab><sentence><tab><approx. coverage score><tab><queryDown flag><tab><start position of first matching part><space><end pos.>[<space><start ...>]+
				// positions are 1-based
                                // if sentence is query sentence, only the two first fields are listed (<sentence ID> being 0)
                                if (minApproxCovScore > 0){
                                  cout << "0 " << sentence <<endl;
				  for (std::vector<fuzzyCovSent>::iterator it=bestFuzzySents.begin(); it!=bestFuzzySents.end();it++){
                                    cout << (*it).sentId << "\t" << (*it).sent << "\t" << (*it).approxCovScore << "\t" << (*it).queryDown;
				    for (unsigned char i=0;i<(*it).partNum;i++){
				      cout << ((i==0) ? "\t" : " ") << (*it).begParts[i]+1 << " " << (*it).endParts[i]+1;
				    }
				    cout << endl;
 				  }
				}
			}
		  }
		  cout<<endl;
	  }
	}



	return 0;
}
