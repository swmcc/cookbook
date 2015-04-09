#!/usr/bin/env bash -e

#----------------------------------------------------------------------
# Script gives you the following information for a git repo:
# 
#  [no of lines commited] [hash] [commit meesages]
#
#     ➜  git git:(master) ✗ ./repo-stats.sh 
#     68 1919a47 added python directory and the csv to json script
#     94 e5dd322 Added repo-stats.sh
#     97 588e404 Added in regex argument but not sure if it is working correctly
#     97 50b2b3c Amended some stupid indentation
#
# You can add in a regex to give you information. So if you wanted to # see all 
# commits that were for ruby files then use '.rb' or tests then 'tests'
#
#     ➜  git git:(master) ✗ ./repo-stats.sh '.sh' 
#     0 1919a47 added python directory and the csv to json script
#     26 e5dd322 Added repo-stats.sh
#     29 588e404 Added in regex argument but not sure if it is working correctly
#     29 50b2b3c Amended some stupid indentation
#---------------------------------------------------------------------- 

pattern=$1

function main {
     for rev in `get_revisions`; do
          echo "`number_of_lines` `commit_information`"
     done
}

function get_revisions {
     git rev-list --reverse HEAD 
}

function commit_information {
     git log --oneline -1 $rev;
}

function number_of_lines {
     git ls-tree -r $rev | 
     grep "$pattern" |
     awk '{print $3}' | 
     xargs git show | 
     wc -l 
}

main
