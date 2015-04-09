#!/usr/bin/env bash

set -e 

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
