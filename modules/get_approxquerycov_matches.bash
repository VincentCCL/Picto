#!/bin/bash

####### get_approxquerycov_matches.bash ##########

# By Tom Vanallemeersch
# tallem@ccl.kuleuven.be
# Date: 15.10.2014

#---------------------------------------

# usage: get_approxquerycov_matches.bash [-m] [-t <temporary directory>] [-n <minimum ngram length> ]
#        <query sequence file> <corpus sequence file> <minimal approximate coverage score> <nbest> <output file>
#
# for each sequence in <query sequence file>, find out the sequences in <corpus sequence file> which share at least one ngram of length (order) <minimum ngram length>
# with the query sequence and have a match score of at least <minimum approximate coverage score>; max. <nbest> matches are kept (if <nbest> is 0, this restriction is not applied)
#
# long sequences are removed from the two sequence sets (see below); the subsets are written to files <... sequence file>_nolong; a suffix array is created using SALM toolkit:
# 4 files with prefix <corpus sequence file>_nolong; if ..._nolong files exist, they are reused
#
# switch -m: include corpus sequences with marked shared subsequences in output
#
# output contains lines of format
# querypos<tab><line number of query sequence in file><tab>corppos<tab><line number of corpus sequence in file><tab>score<tab><score><tab>rank<tab><rank>
# <tab>links<tab><links><tab>queryDown<tab><queryDown value>
# [<tab>queryseq<tab><query sequence><tab>corpmark<tab><corpus sequence with marked subsequences>]?
#
# <rank> is the rank of the match within the set of matches for the query sequence
#
# <links> has format "?"<space><start position in corpus sequence>-<end position in corpus sequence>[<space>"?"...]*
# (the query sequence part of links is unknown)
#
# notes:
# - sequences of more than 254 elements are left out from suffix array and set of query sequences (SALM toolkit does not allow indexing or querying such sequences);
#   this is likely to affect character sequences most, and prufer sequences to a lesser extent; it leads very long query sequences not to have any match, and the other sequences
#   to be matched to less corpus sequences, which may affect the match quality
# - if query sequences are a subset of the corpus sequences (cfr. -f switch in match_testset_tm.bash), we have an exact match for each query sequence; this may lead the score
#   to be higher than if there is no overlap between query and corpus sequences (it may happen that queryDown is 0 in the former case and 1 in the latter)
# - <minimal approximate coverage score> should be larger than 0: matches of score 0 cannot be produced
# - if no match satifies <minimal approximate coverage score>, <output file> is not created

#---------------------------------------

debug=0

# arguments: <file name> <type> <variable name for absolute path>
# if <type> is "read", check whether file exists, if it is "write" check whether file can be created
# upon sucess, $<variable name absolute path> is set
# e.g. abspath_or_exit $1 read abspath
# note: this function does not check on read / write permissions

function abspath_or_exit()
{
  local __resultvar=$3
  local abspath=`readlink -f $1`
  if [ $2 == "read" ]
  then if [ -z $abspath ] || [ ! -f $abspath ]
       then echo "$1 does not exist" > /dev/stderr
            exit
       fi
  elif [ $2 == "write" ]
  then if [ -z $abspath ]
       then echo "$1 cannot be created" > /dev/stderr
            exit
       fi
  else echo "type $2 is unknown" > /dev/stderr
       exit
  fi
  eval $__resultvar="'$abspath'"
}

homedir=..
scriptsdir=`readlink -f $0`
scriptsdir=`dirname $scriptsdir`
starttime=`date '+%Y%m%d_%H%M%S_%9N'`

tmpdir=$homedir/tmp/getapproxquery
withmarkedsubseqs=0
minngramlen=2
while getopts ":mt:n:p:" opt;
do
    case $opt in
    m) withmarkedsubseqs=1;;
    t) tmpdir=$OPTARG;;
    n) minngramlen=$OPTARG;;
    p) ngramfrequency=$OPTARG;;
    *)
      echo "Invalid option: $OPTARG" >&2
      exit 4;;
    esac
done

shift $(($OPTIND - 1))

tmpfile=$tmpdir/_approxquerycov_${starttime}

abspath_or_exit $1 read queryseqfile
abspath_or_exit $2 read corpseqfile
minscore=$3
nbest=$4
abspath_or_exit $5 write outfile

# debugging
if [ $debug -eq 1 ]
then
     echo "scriptsdir:" $scriptsdir
     echo "tmpfile:" $tmpfile
     echo "withmarkedsubseqs:" $withmarkedsubseqs
     echo "minngramlen:" $minngramlen
     echo "queryseqfile:" $queryseqfile
     echo "corpseqfile:" $corpseqfile
     echo "minscore:" $minscore
     echo "nbest:" $nbest
     echo "ngramfrequency:" $ngramfrequency
     echo "outfile:" $outfile
fi

rm -f $outfile

# replace sequences with too many elements by a dummy sequence so the number of lines remains identical (important for finding out TU ID after matching)
# make sure the dummies in query file are different from those in corpus file in order to avoid a match

if [ ! -f ${queryseqfile}_nolong ]
then gawk '{ print ((NF > 254) ? "_nonequery_" : $0) }' $queryseqfile > ${queryseqfile}_nolong
fi
if [ ! -f ${corpseqfile}_nolong.sa_corpus ]
then gawk '{ print ((NF > 254) ? "_nonecorp_" : $0) }' $corpseqfile > ${corpseqfile}_nolong
     $scriptsdir/salm_modified/Bin/Linux/Index/IndexSA.O64 ${corpseqfile}_nolong
fi

# perform matching
#
# output has the following format:
#
# N-gram ...
# N-gram ...
# ...
# 0<tab><query sequence>
# <line number in query sequence file><tab><sequence><tab><score><tab><queryDown flag><tab><start position of first matching part><space><end pos.>[<space><start ...>]+
# <line ...>...
# <empty line>
# N-gram
# ...
# <empty line>
# Nothing can be found in the corpus.
# 0<tab><query sequence>
# <empty line>

cat ${queryseqfile}_nolong | $scriptsdir/salm_modified/Bin/Linux/Search/LocateEmbeddedNgramsInCorpus.O64 ${corpseqfile}_nolong $ngramfrequency 100000000 $minngramlen 10000000 $minscore $nbest > $tmpfile

# add field names
# sort the matches of a query sequence by score and add the rank (as we applied nbest above, the number of matches is already correct; therefore, nbest is not specified below)

gawk -v withmarkedsubseqs=$withmarkedsubseqs \
     'BEGIN { FS="\t" }; \
      { if ($0 ~ /^0 /){ querypos++; queryseq=substr($1,3) } \
        else if ($1 ~ /^[0-9]+$/){ \
          split($5,linkarr," "); split($2,seqarr," "); \
          for (i=1;(i in linkarr);i+=2) links=((i==1) ? "" : links " ") "? " linkarr[i] "-" linkarr[i+1]; j=1; \
          for (i=1;(i in seqarr);i++) { \
            corpmark=((i==1) ? "" : corpmark " ")\
            (((j%2==1) && (linkarr[j]==i) && ++j) ? "<<<" (j/2) " " : "") seqarr[i] (((j%2==0) && (linkarr[j]==i) && ++j) ? " " (j-1)/2 ">>>" : "") }; \
          print "querypos\t" querypos "\tcorppos\t" $1 "\tsequence\t" $2 "\tscore\t" $3 "\tlinks\t" links "\tqueryDown\t" $4 (withmarkedsubseqs ? "\tqueryseq\t" queryseq "\tcorpmark\t" corpmark : "") } }' \
     $tmpfile | gawk -f $scriptsdir/get_nbest_matches.awk - > $outfile

#rm -f $tmpfile
