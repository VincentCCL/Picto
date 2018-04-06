#!/bin/bash

####### parse_file.sh ##########

# By Tom Vanallemeersch for the SCATE project
# tallem@ccl.kuleuven.be
# Last modification: January 2016

#---------------------------------------

# invoke the Alpino parser (http://www.let.rug.nl/vannoord/alp/Alpino)
#
# usage: [ -i <Alpino installation directory> ] [-k <tokenize ?> ] [-s <directory with parser-independent scripts>] [-t <timeout in seconds>] [-f] [-d <node-specific temporary directory>]
#        <file with Dutch sentences> <output directory>
#
# create Alpino XML treebank
#
# if <output directory> exists, asks for confirmation before removing contents
# files created in directory: inputfile, variants of it, logging, parses in Alpino format at different stages, final file treebank.xml
#
# if <node-specific temporary directory> is specified (directory name, e.g. /home/localssd, or string starting with "env:", e.g. "env:VSC_SCRATCH_NODE/_parse_large_files_<start time>_<global chunk ID>"),
# all temporary files are written there, and the final compressed files are written to <output directory>
#
# if sentence exceeds timeout during parsing, we produce a parse of the word "_TIMEOUT_" and include the original sentence as a comment
#
# if -f is specified, option "-veryfast" is added to Alpino call
#
# the directory this script resides in has only one other script (for tokenization, see below); the Alpino installation is in another directory
#
# notes:
# - tokenization:
#   * we transferred the tokenizer from /home/suske/Scate/Scripts/AlpinoParserText.pl to script tokenize.pl in the directory the present script resides in; alternatively,
#     we may use the tokenizer distributed with Alpino (in <Alpino installation directory>/Tokenizer/...); test on small set leads to identical results as tokenize.pl
#   * we add tokenized sentence to <sentence> tag, and non-tokenized sentence as comment
# - node ID: <basename of file with Dutch sentences>.<sentence ID>.<node ID>; ID of alpino_ds: first three fields
# - input encoding is UTF-8
# - time and memory (wiske):
#   * loading time of parser: 9 sec
#   * time and memory per length range (1000 Europarl sentences)
#     - 1-10: 0.51 / sec, 0.5 GB mem
#     - 11-20: 1 / sec, 0.5 GB mem
#     - 21-30: 3.76 /s sec, 0.75 GB
#     - 31-40: 8.27, 1 GB
#     - 41-50: 14, 0.7 GB
#     - 51-60: 21.5, 0.8 GB 
#     - 61-70: 22.5, 0.7 GB
#     - 71-80: 46, 0.6 GB
#     - 91-100: 61, 0.6 GB
#     - 101-110: 22, 0.5 GB
#     - any length: 4, 1GB
#   * Alpino does not allow to control memory; in order to comply with requirement of /home/suske/Scate/Scripts/parse_large_files.sh, -m <memory> is accepted as switch, but value is ignored
#   * on a small test, setting -f switch hardly makes a difference in speed, and makes no difference in memory
# - installation: SICSTUS Prolog, ...
# - this script is based on a.o. /home/suske/Scate/Scripts/BatchParseAlpino.pl, AlpinoParserText.pl; however, the functionality in it for
#   treating Europarl sentences with < ... > is not retained (independent from parser)
# - parser can create multiple parses using switch number_analyses, but not implemented yet in script

debug=1

# arguments: <file name> <type> <variable name for absolute path>
# if <type> is "read", check whether file exists, if it is "write" check whether file can be created
# upon success, $<variable name absolute path> is set
# e.g. abspath_or_exit $1 read abspath
# note:
# - can also be applied if first name is directory and <type> is "write"
# - these functions do not check on read / write permissions

#---------------------------------------

function abspath_or_exit()
{
  local __resultvar=$3
  local abspath=`readlink -f $1`
  if [ $2 == "read" ]
  then if [ -z $abspath ] || [ ! -f $abspath ]
       then echo "$1 does not exist" >&2
            exit
       fi
  elif [ $2 == "write" ]
  then if [ -z $abspath ]
       then echo "$1 cannot be created" >&2
            exit
       fi
  else echo "type $2 is unknown" >&2
       exit
  fi
  eval $__resultvar="'$abspath'"
}

# for logging
scriptcall=$0
for i in "$@"
do
    if [[ $i =~ [[:space:]] ]]
    then i=\"$i\"
    fi
    scriptcall="$scriptcall $i"
done

tokenize=1
scriptsdir=../scripts
alpinoinstdir=../Alpino
timeout=20
while getopts ":m:k:s:t:fd:i:" opt;
do
   case $opt in
     m)  ;; # ignore
     k)  tokenize=$OPTARG;;
     s)  scriptsdir=$OPTARG;;
     t)  timeout=$OPTARG;;
     f)  speedswitch="-veryfast";;
     d)  nodetmpdir=$OPTARG;;
     i)  alpinoinstdir=$OPTARG;;
     *)  echo "Invalid option: $OPTARG" >&2
         exit 4;;
   esac
done

if [[ "$nodetmpdir" =~ ^env: ]]
then nodetmpdir=`set | gawk -v dir=$nodetmpdir 'BEGIN { var=gensub("^env:([^/]+)(/.*)?$","\\\\1",1,dir); FS="=" }; ($1==var){ print $2 substr(dir,5+length(var)); exit }'`
     # check whether we found a value for variable
     if [ ! -z $nodetmpdir ]
     then nodetmpdir=`readlink -f $nodetmpdir`
     fi
fi

shift $(($OPTIND - 1))

abspath_or_exit $1 read inputfile
abspath_or_exit $2 write outdir

#if [ -d $outdir ]
##then if [ ! -f $outdir/auxfiles.tar.bz2 ]
#     then echo "Output directory was not made by this script."
#          exit
#     fi
     #echo -n ""
     #read answer
     #if [ "$answer" != "y" ]
#     exit
     #fi
#fi

rm -rf $outdir
mkdir $outdir

if [ ! -z $nodetmpdir ]
then origoutdir=$outdir
     outdir=$nodetmpdir
     rm -rf $outdir
     mkdir $outdir
fi

if [ $debug -eq 1 ]
then
     echo "script call:" $scriptcall > $outdir/logging
     echo -e "\nsettings:" >> $outdir/logging
     echo "tokenize" $tokenize >> $outdir/logging
     echo "scriptsdir" $scriptsdir >> $outdir/logging
     echo "timeout" $timeout >> $outdir/logging
     echo "speedswitch:" $speedswitch >> $outdir/logging
     echo "nodetmpdir:" $nodetmpdir >> $outdir/logging
     echo "alpinoinstdir:" $alpinoinstdir >> $outdir/logging
     echo "inputfile:" $inputfile >> $outdir/logging
     if [ -z $origoutdir ]
     then echo "outdir:" $outdir >> $outdir/logging
     else echo "outdir:" $origoutdir >> $outdir/logging
     fi
fi

starttime=$(date +%s)
echo -e "\nstarted parsing at" `date` "\n" >> $outdir/logging

export ALPINO_HOME=$alpinoinstdir
export PATH=$PATH:$alpinoinstdir/bin

cp $inputfile $outdir/inputfile

## preprocess sentences
echo "start preprocessing" >> $outdir/logging

if [ $tokenize -eq 0 ]
then filetoparse=$outdir/inputfile
else echo "perl `dirname $0`/tokenize.pl $outdir/inputfile $outdir/inputfile.tok" >> $outdir/logging
     perl `dirname $0`/tokenize.pl $outdir/inputfile $outdir/inputfile.tok >> $outdir/logging 2>&1
     filetoparse=$outdir/inputfile.tok
fi

# * we add a key sent-<zero-indented sentence ID> to each sentence (<key>|<sentence>), to make sure that
#   the files produced by Alpino are ordered correctly and to make sure that we can use AddIds.pl
# * sent-<zero-indented sentence ID>|<sentence>|<number>|<number>|<some penalty> will be added as comment; as we do not need it, will remove it after AddIds.pl
# * protect special characters:
#   * we ensure correct treatment of square brackets (which are used for syntactic annotation of input) by adding a backslash to them
#   * characters % and | are treated correctly already, through the fact that we added <key>, which makes occurrence of | unambiguous, and ensures that % is not considered to be
#     the start of a comment (only full lines can be commented out)
echo "adding zero-indented sentence IDs and dealing with special characters" >> $outdir/logging
gawk '{ gsub(/\[/,"\\["); gsub(/\]/,"\\]"); print sprintf("sent-%05d",++i) "|" $0 }' $filetoparse > $filetoparse.chpro

## parse sentences

echo "start Alpino" >> $outdir/logging

# create an Alpino XML file for each sentence
timeout_msec=$[$timeout*1000]
mkdir $outdir/xmlfiles
# notk: do not use the graphical user interface
# end_hook=xml produce XML file for each sentence
echo "cat $filetoparse.chpro" \| "$ALPINO_HOME/bin/Alpino -notk $speedswitch -end_hook=xml -flag treebank $outdir/xmlfiles user_max=$timeout_msec assume_input_is_tokenized=on $speedswitch -parse" >> $outdir/logging
cat $filetoparse.chpro | $ALPINO_HOME/bin/Alpino -notk $speedswitch -end_hook=xml -flag treebank $outdir/xmlfiles user_max=$timeout_msec assume_input_is_tokenized=on $speedswitch -parse >> $outdir/logging 2>&1

# for each sentence that exceeded timeout during parsing, create a parse of a dummy token
# if a parse file is corrupt for some reason (e.g. empty), remove it and treat it as the result of a timeout
echo "checking whether some sentences exceeded timeout" >> $outdir/logging
dummytoken="_TIMEOUT_"
sentnum=`cat $inputfile | wc -l`
for ((i=1;i<=$sentnum;i++))
do
    indentcount=`gawk "BEGIN { printf(\"%05d\",$i) }"`
    if [ ! -f $outdir/xmlfiles/sent-$indentcount.xml ]
    then echo "sent-$indentcount|$dummytoken" >> $outdir/timeoutsents
    elif [ `grep -c "</alpino_ds" $outdir/xmlfiles/sent-$indentcount.xml` -eq 0 ]
    then rm -f $outdir/xmlfiles/sent-$indentcount.xml
     	 echo "sent-$indentcount|$dummytoken" >> $outdir/timeoutsents
    fi
done

if [ -f $outdir/timeoutsents ]
then echo "found some; replaced them with dummy token; parsing them" >> $outdir/logging
cat $outdir/timeoutsents | $ALPINO_HOME/bin/Alpino -notk $speedswitch -end_hook=xml -flag treebank $outdir/xmlfiles user_max=$timeout_msec assume_input_is_tokenized=on $speedswitch -parse >> $outdir/logging 2>&1
fi
    
## postprocessing parses

echo "start postprocessing" >> $outdir/logging

echo "perl $scriptsdir/CatAlpinoParses_with_twig.pl $outdir/xmlfiles" >> $outdir/logging
perl $scriptsdir/CatAlpinoParses_with_twig.pl $outdir/xmlfiles >> $outdir/logging 2>&1
rm -rf $outdir/xmlfiles
mv -f $outdir/xmlfiles.xml $outdir/treebank.sents.xml

echo "perl $scriptsdir/AddIds.pl $outdir/treebank.sents.xml" >> $outdir/logging
perl $scriptsdir/AddIds.pl $outdir/treebank.sents.xml > $outdir/loggingpart 2>&1
sed 's/\r/_DEL_\n/g' $outdir/loggingpart | egrep -v "_DEL_$" >> $outdir/logging # remove lines "Tree nr. ..." ending in carriage return
rm -f $outdir/loggingpart
basenameinput=`basename $inputfile`
echo -e "\nremove comments with sentence ID and sentence added by Alpino, add filenames in IDs of nodes and alpino_ds, remove zero indentation from sentence IDs" >> $outdir/logging
egrep -v "^ *</?comment" $outdir/treebank.sents.ids.xml | sed -r "s/(id=.)sent-0+/\1$basenameinput./" > $outdir/treebank.sents.ids.modname.xml

# if we tokenized input, we add non-tokenized sentence as comment to sentences
# otherwise, in sentences with timeout, we also use AddNonTok ... to add tokenized sentence as comment
if [ $tokenize -eq 1 ] || [ -f $outdir/timeoutsents ]
then echo -e "\nperl $scriptsdir/AddNonTok2Alpino.pl $outdir/treebank.sents.ids.modname.xml $inputfile $outdir/treebank.sents.ids.modname.sentcmt.xml" >> $outdir/logging
     perl $scriptsdir/AddNonTok2Alpino.pl $outdir/treebank.sents.ids.modname.xml $inputfile $outdir/treebank.sents.ids.modname.sentcmt.xml >> $outdir/logging 2>&1
     if [ $tokenize -eq 0 ]
     then # if a sentence has no timeout, comment is redundant (sentence in comment is equal to comment in sentence tag)
          # otherwise, remove "non-" from start of comment tag (AddNonTok... always adds "non-tokenized")
          gawk "{ if (\$0 ~ /<sentence>$dummytoken</){ dm=1 } else if (\$0 ~ /<alpino_ds/){ dm=0 } \
                  else if ((\$0 ~ /<comment>/) && dm){ sub(/>non-/,\">\") } else if ((\$0 ~ /<\\/?comment/) && !dm) next; \
                  print \$0 }" \
               $outdir/treebank.sents.ids.modname.sentcmt.xml > $outdir/treebank.xml
	  rm -f $outdir/treebank.sents.ids.modname.sentcmt.xml
     else mv -f $outdir/treebank.sents.ids.modname.sentcmt.xml $outdir/treebank.xml
     fi
else mv -f $outdir/treebank.sents.ids.modname.xml $outdir/treebank.xml
fi

#tar --remove-files -cvf $outdir/inputfile* $outdir/treebank.sents.* &> /dev/null
#bzip2 $outdir/auxfiles.tar $outdir/treebank.xml

# time for pre- and postprocessing is neglectible wrt running parser itself, so we measure time across all steps
endtime=$(date +%s)
echo -e "\nended parsing at" `date` >> $outdir/logging
echo "parsing took $(($endtime - $starttime)) seconds" >> $outdir/logging

if [ ! -z $origoutdir ]
then cp -r $outdir/* $origoutdir
     rm -rf $outdir
fi
