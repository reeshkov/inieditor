#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

function get(){
  [ 1 -gt $# ] && echo "get: Too few parameters $# $@" && exit 1
  local OK=1
  local value=
  if [ 1 -eq $# ] ;then
    if [ "$1" != "${1#[}" ]; then
        local targetsection=$(echo "$1" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
        value=$(sed -n "/$targetsection/p" $inputfile)
        OK=$?
    else
        local targetkey=$(echo "$1" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
        value=$(sed -n "1,/\[/ s|${targetkey}.*= *||p" $inputfile)
        OK=$?
    fi
  else
    if [ "$1" != "${1#[}" ]; then
        local targetsection=$1
    else
        local targetsection='['$1']'
    fi
    targetsection=$(echo "$targetsection" | sed "s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
    local targetkey=$(echo "$2" | sed "s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
    value=$(sed -n '/'$targetsection'/!b;:x;n;s|'$targetkey'.*=||p;/\[/b;bx' $inputfile)
    OK=$?
  fi
  [ -n "$value" ] && echo "$value" && exit $OK
  return 1
}

function del(){
  [ 1 -gt $# ] && echo "del: Too few parameters $# $@" && exit 1
  local OK=1
  exec < $inputfile
  if [ 1 -eq $# ]; then
    if [ "$1" != "${1#[}" ]; then
        local targetsection=$(echo "$1" | sed "s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
        sed "/$targetsection/ {s|.*||; :get; n; \$ b; /\[/b; s|.*||; b get;}" $inputfile
        #[ $? ] && sed ":a;N;\$!ba;s|$targetsection||g" $inputfile
        #sed -n '/\[testgroup\]/ {h; :get; n; $ b end; /\[/b end; H; b get; :end; x; p}' test.ini
        #sed '/\[testgroup\]/ {s|.*||; :get; n; $ b; /\[/b; s|.*||; b get;}' test.ini
        OK=$?
    else
        local targetkey=$(echo "$1" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
        sed "1,/^\[/ s|^ *${targetkey} *=.*$||" $inputfile
        OK=$?
    fi
  else
    local targetsection=$(echo "$1" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
    local targetkey=$(echo "$2" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
    sed "/$targetsection/,/^\[/ s|^ *${targetkey} *=.*$||" $inputfile
    OK=$?
  fi
  return $OK
}

function set(){
  [ 1 -gt $# ] && echo "set: Too few parameters $# $@" && exit 1
  local OK=1
  if [ 1 -eq $# ]; then
    if [ "$1" != "${1#[}" ]; then
      if ! $self $inputfile -G "$1"; then
        sed "$ s|$|\n$1\n|" $inputfile
        OK=$?
      else
        OK=0
      fi
    else
      echo "Expected [section]"
    fi
    return $OK
  elif [ 2 -eq $# ]; then
    [ "$1" != "${1#[}" ] && echo "Unexpected section" && return 1
    if $self $inputfile -G "$1"; then
      local targetkey=$(echo "$1" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
      local targetvalue="$2"
      sed "1,/^\[/ s|^${targetkey}.*$|$1=$2|" $inputfile
      OK=$?
    else
      sed "1 s|^|$1=$2\n|" $inputfile
      OK=$?
    fi
  elif [ 3 -le $# ]; then
    local targetsection=$(echo "$1" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
    if $self $inputfile -G "$1"; then # if section exist
      if $self $inputfile -G "$1 $2"; then # if key exist
        local targetkey=$(echo "$2" | sed "s|\\\\|\\\\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\\$|\\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g")
        local targetvalue="$3"
        sed "/$targetsection/!b;:x;n;s/$targetkey.*/$2=$3/;t;/\[/b;bx" $inputfile
        OK=$?
      else
        sed "/$targetsection/ s/$/\n$2=$3/" $inputfile
        OK=$?
      fi
    else
      sed -e "$ s|$|\n$1\n|" -e "/$targetsection/ s/$/$2=$3\n/" $inputfile
      OK=$?
    fi
  fi
  return $OK
}

if [ "$#" == "0" ] ; then
  echo "Configuration ini command editor"
  echo "Usage:"
  echo "\$0 [</path/to/file.ini> [-v] <-G|-S|-D> [group] <key> [value]]"
  echo " Without parameters - show this help"
  echo " -v|--verbose - print what doing"
  echo " -G|--get     - get value"
  echo " -S|--set     - set [group] or value, if not exist, append"
  echo " -D|--del  - delete [group] or value"
  exit 0
fi

self=$0
[ ! -f $1 ] && echo "File $1 not found" && exit 1
inputfile=$1
shift
verbose=0
write=0
OK=1
#until [ -z "\$1" ]; do
while (( "$#" )); do
  case "$1" in
    -v|--verbose)
    verbose=1
    ;;
    -w|--write)
    write=1
    ;;
    -G|--get)
        shift
        value=$(get $@)
        OK=$?
        break
    ;;
    -S|--set)
        shift
        value=$(set $@)
        OK=$?
        break
    ;;
    -D|--del)
        shift
        value="$(del $@)"
        OK=$?
        break
    ;;
  esac
  shift
done
[ 1 -le $verbose ] && echo -e "$OK\n$value"
[ $OK ] && [ 1 -eq $write ] && echo "$value" > $inputfile
exit $OK
