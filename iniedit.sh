#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
trap 'echo "Edit ini error"' 1 2 3 15

function get(){
  [ 1 -gt $# ] && echo "get: Too few parameters $# : $@" && exit 1
  local OK=1
  local value=
  if [ 1 -eq $# ] ;then
    local target=$(echo "$1" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    if [ "$1" != "${1#[}" ]; then
        # get section
        value=$(sed -n "/$target/ s| *||g p" "$inputfile")
        OK=$?
    else
        # get value
        value=$(sed -n '1,/\[/ s|^'${target}'.*= *||p' $inputfile)
        OK=$?
    fi
  else
    # get value from section
    if [ "$1" != "${1#[}" ]; then
      local targetsection="$1"
    else
      local targetsection='['$1']'
    fi
    targetsection=$(echo "$targetsection" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    local targetkey=$(echo "$2" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    #key=b0; echo -e "[A]\a=\n[B]\nb0=\nb1=b1\n[C]\nc=c" | sed -n '/\[B\]/! b; :next; n; /\[/ b; /^'$key'.*= */ {s|^'$key'.*= *||; s|^$|empty| ; p;} $ b; b next;'
    value=$(sed -n '/'$targetsection'/! b; :next; n; /\[/ b; /^'$targetkey'.*= */ {s|^'$targetkey'.*= *||; s|^$| | ; p;} $ b; b next;' $inputfile)
    OK=$?
  fi
  [ -n "$value" ] && echo "$value" && exit $OK
  return 1
}

function del(){
  [ 1 -gt $# ] && echo "del: Too few parameters $# $@" && exit 1
  local OK=1
  if [ 1 -eq $# ]; then
    local target=$(echo "$1" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    if [ "$1" != "${1#[}" ]; then
        sed -e "/$target/ {s|.*||; :next; n; \$ b last; /\[/ b; s|.*||; b next; :last; s|.*||;}" -e '/^$/d' $inputfile
        OK=$?
    else
        sed -e "1,/^\[/ s|^ *${target} *=.*$||" -e '/^$/d' $inputfile
        OK=$?
    fi
  else
    local targetsection=$(echo "$1" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    local targetkey=$(echo "$2" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    sed -e "/$targetsection/,/^\[/ s|${targetkey} *=.*$||" -e '/^$/d' $inputfile
    OK=$?
  fi
  return $OK
}

function set(){
  [ 1 -gt $# ] && echo "set: Too few parameters $# $@" && exit 1
  local OK=1
  if [ 1 -eq $# ]; then
    if [ "$1" != "${1#[}" ]; then
      local value=$($self "'$inputfile' -G '$1'")
      OK=$?
      if [ 0 -ne $OK ]; then
        sed "$ s|$|\n$1\n|" "$inputfile"
        OK=$?
      else
        sed '' "$inputfile"
        OK=0
      fi
    else
      echo "Expected [section]"
    fi
    return $OK
  elif [ 2 -eq $# ]; then
    [ "$1" != "${1#[}" ] && echo "Unexpected argument: $1, expected <key> <value> pair" && return 1
    if $self $inputfile -G "$1"; then
      local targetkey=$(echo "$1" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
      local targetvalue="$2"
      sed "1,/^\[/ s|^${targetkey}.*$|$1=$2|" $inputfile
      OK=$?
    else
      sed "1 s|^|$1=$2\n|" $inputfile
      OK=$?
    fi
  elif [ 3 -le $# ]; then
    local targetsection=$(echo "$1" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    local targetkey=$(echo "$2" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    local targetvalue=$(echo "$3" | sed 's|\\|\\\\|g;s|\[|\\\[|g;s|\]|\\\]|g;s|\/|\\\/|g;s|\.|\\\.|g;s|\$|\\\$|g;s|\^|\\\^|g;s|\*|\\\*|g')
    if $self $inputfile -G "$1"; then # if section exist
      if $self $inputfile -G "$1 $2"; then # if key exist
        sed '/'$targetsection'/! b; :next; n; /'$targetkey'/! b next; s|'$targetkey'.*|'$2' ='$3'|' $inputfile
        OK=$?
      else
        sed "/$targetsection/ s|\$|\n$2= $3|" $inputfile
        OK=$?
      fi
    else
      sed -e "\$ s|\$|\n$targetsection\n$2 = $3\n|" $inputfile
      OK=$?
    fi
  fi
  return $OK
}

if [ "$#" == "0" ] ; then
  echo "Configuration command editor"
  echo "Usage:"
  echo "$0 [</path/to/file.ini> [-v,-w] <-G [group] <key> |-D [group] <key> |-S [group] <key> <value>> ]"
  echo " Without parameters - show this help"
  echo " -v|--verbose - print result"
  echo " -w|--write   - write result to file"
  echo " -G|--get     - get value"
  echo " -S|--set     - set [group] or value, if not exist, append"
  echo " -D|--del     - delete [group] or value"
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
        verbose+=1
    ;;
    -vv)
        verbose=2
    ;;
    -w|--write)
        write=1
    ;;
    -G|--get)
        shift
        value=$(get $@)
        OK=$?
        break
        #exit $OK
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

if [ 2 -le $verbose ]; then
  echo -e "$OK\n$value"
elif [ 1 -le $verbose ]; then
  echo "$value"
fi
[ $OK ] && [ 1 -eq $write ] && echo "$value" > $inputfile
exit $OK
