#!/bin/bash

OAUTH=$(cat ~/.pull_all_repos_from_org.oauth)

function pre_check() {
    local res=0
    local tools="jq curl git hub"
    for tool in $tools; do
        which -s $tool; let res=$res+$?
    done
    if (($res)); then
      echo "Missing $res tool(s) of ${tools}."
        exit -2
    fi
}

function pull_all_repos_from_org() {
  local typ=$1
  local entity=$2
  local repo_type=${3:-all}
  case $typ in
    "org")
      repos=$(repos_of orgs/$entity $repo_type)
      ;;
    "user")
      repos=$(repos_of users/$entity $repo_type)
      ;;
    *)
      repos=""
  esac
  for repo in ${repos}; do
    pull_repo $repo
  done
}

function repos_of() {
  local entity=$1
  local repo_type=$2
  echo $(curl -s -u ${OAUTH} "https://api.github.com/${entity}/repos?per_page=300&type=${repo_type}" | jq '.[] | select(.fork == false) | .full_name ' | tr '\n"' '  ')
  echo ""
}

function pull_repo() {
  local orgrepo=$1
  local repo=$(echo $orgrepo | tr '/' ' ' | awk '{ print $2 }')

  if [ ! -d $repo ]; then
    echo "Cloning $orgrepo"
    clone_repo $repo
  else
    echo "Pulling $orgrepo"
    pull_repo_in_dir "pull --rebase" "$repo"
  fi
}

function clone_repo() {
    hub clone $orgrepo &> /dev/null
}

function pull_repo_in_dir() {
  command="$1"
  path="$2"
  if [ -d $path ]; then
    cd "$path"
    git $command &> /dev/null
    ret=$?
    cd ..
    return $ret
  fi
  return -1
}

pre_check
pull_all_repos_from_org $@

