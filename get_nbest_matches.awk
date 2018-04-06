####### get_nbest_matches.awk ##########

# By Tom Vanallemeersch
# tallem@ccl.kuleuven.be
# Date: 15.10.2014

#---------------------------------------

# parameters: <file with matches> <nbest>?
#
# for each test item in <file with matches>, keep its exact matches and <nbest> matches with the highest fuzzy score, and add rank to the matches
#
# <file with matches> contains lines with format
# querypos<tab><line number of query sequence in file><tab>corppos<tab><line number of corpus sequence in file><tab>score<tab><score>...
# lines are sorted on field querypos
#
# if match NBEST in the list ranked on fuzzy scores has the same score as match NBEST + 1, keep all matches with that score, unless match NBEST*2 has the same score
# and the score is not the maximal fuzzy score (i.e. we always keep all matches with the
# maximal fuzzy score, and when keeping some lower score has the effect that NBEST is exceeded too much, we only keep matches with higher fuzzy scores)
#
# if NBEST is unspecified or 0, keep all matches
#
# output retained matches, ordered primarily on field querypos and secondarily on field score (high to low); format of output:
# ...<tab>score<tab><score><tab>rank<rank>...

#---------------------------------------

BEGIN { if (ARGC==3){ nbest=ARGV[2]; delete ARGV[2] }; if (!nbest) nbest=1000000; FS="\t" }
{
  if (previd && ($2!=previd))
  {
    retain_matches(matches,matchnum,nbest)
    matchnum=0
    delete matches # see asort
  }
  matches[++matchnum]=sprintf("%1.5f\t",1-$6) $0
  previd=$2
}
END { retain_matches(matches,matchnum,nbest) }

function retain_matches(matches,matchnum,nbest,
                        i,arr,numexact,minscore)
{
  asort(matches)

  # scores are inverted
  for (i=1;(i<=matchnum) && (matches[i] ~ /^[0.]+\t/);i++){}
  numexact=i-1;

  if (nbest && (matchnum>numexact+nbest))
  {
    split(matches[numexact+nbest],arr,"\t")
    minscore=1-arr[1] # is increased below if needed

    if (split(matches[numexact+nbest+1],arr,"\t") && (1-arr[1]==minscore))
    {
      if ((matchnum>=numexact+(nbest*2)) && split(matches[numexact+(nbest*2)],arr,"\t") && (1-arr[1]==minscore) && split(matches[numexact+1],arr,"\t") && (1-arr[1]>minscore))
      {
        for (i=numexact+nbest-1;(i>numexact+1) && split(matches[i],arr,"\t") && (1-arr[1]==minscore);i--){}
	split(matches[i],arr,"\t")
	minscore=1-arr[1];
      }
    }
  }
  else minscore=0

  for (i=1;(i<=matchnum) && split(matches[i],arr,"\t") && (1-arr[1]>=minscore);i++) print gensub("^[^\t]+\t(.*)\tscore\t([^\t]+)(\t.+)?$","\\1\tscore\t\\2\trank\t" i "\\3",1,matches[i])
}
