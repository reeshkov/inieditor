#!/bin/bash
set +e

PRECINI=prec.ini
TESTINI=test.ini

##### GET #####
desc="Get wild key"
cat <<EOF > "$TESTINI"
;wildkey = commented
wildkey = keywild
;[G1]
[G1]
;wildkey = comment G1
wildkey = http://keyG1
;[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -G wildkey)
OK=$?
if [ 0 -eq $OK ] && [ "keywild" == "$value" ]; then
  echo -e "OK   $desc. Value = $value"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get exist group"
value=$(./iniedit.sh "$TESTINI" -v -G [G1])
OK=$?
if [ 0 -eq $OK ] && [ "[G1]" == "$value" ]; then
  echo -e "OK   $desc. Value = $value"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from group key"
value=$(./iniedit.sh "$TESTINI" -v -G [G1] wildkey)
OK=$?
if [ 0 -eq $OK ] && [ "http://keyG1" == "$value" ]; then
  echo -e "OK   $desc. Value = $value"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get not existing key"
value=$(./iniedit.sh "$TESTINI" -v -G nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get not existing group"
value=$(./iniedit.sh "$TESTINI" -v -G "[G2]")
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from not existing group, not existing key"
value=$(./iniedit.sh "$TESTINI" -v -G "[G2]" nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from not existing group, existing key"
value=$(./iniedit.sh "$TESTINI" -v -G "[G2]" wildkey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from existing group, not existing key"
value=$(./iniedit.sh "$TESTINI" -v -G "[G1]" nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

##### SET #####
desc="Set exist wild key"
cat <<EOF > "$TESTINI"
;wildkey = commented
wildkey = keywild
;[G1]
[G1]
;wildkey = comment G1
wildkey = http://keyG1
;[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -S wildkey wildkeyvalue/set)
OK=$?
cat <<EOF > "$PRECINI"
;wildkey = commented
wildkey = wildkeyvalue/set
;[G1]
[G1]
;wildkey = comment G1
wildkey = http://keyG1
;[G2]
EOF
if diff -waB "$TESTINI" "$PRECINI"; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK" && exit $OK
fi

desc="Set exist group"
value=$(./iniedit.sh "$TESTINI" -v -w -S [G1])
OK=$?
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set exist key in exist group"
cat <<EOF > "$TESTINI"
;G2 = commented
G2 = keywild
;[G1]
[G1]
;G2 = comment G1
G2 = http://keyG2
;[G2]
[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -S "[G1]" G2 "key/G1\new")
OK=$?
cat <<EOF > "$PRECINI"
;G2 = commented
G2 = keywild
;[G1]
[G1]
;G2 = comment G1
G2 = key/G1\new
;[G2]
[G2]
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new wild key"
cat <<EOF > "$TESTINI"
;newwildkey = newwildvalue
;wildkey = commented
wildkey = wildkeyvalue/set
;[G1]
[G1]
;wildkey = comment G1
wildkey = key/G1\new
;[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -S newwildkey newwildvalue)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
;newwildkey = newwildvalue
;wildkey = commented
wildkey = wildkeyvalue/set
;[G1]
[G1]
;wildkey = comment G1
wildkey = key/G1\new
;[G2]
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new group"
cat <<EOF > "$TESTINI"
G2 = wildkeyG2
;[G1]
[G1]
;G2 = comment G1
G2 = key/G1\new
;[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -S G2)
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G1]
[G1]
;G2 = comment G1
G2 = key/G1\new
;[G2]
[G2]
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new key in exist empty group"
value=$(./iniedit.sh "$TESTINI" -v -w -S "[G2]" NGkey keyNG)
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G1]
[G1]
;G2 = comment G1
G2 = key/G1\new
;[G2]
[G2]
NGkey= keyNG
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new key in new group"
cat <<EOF > "$TESTINI"
G2 = wildkeyG2
;[G1]
[G1]
;G2 = comment G1
G2 = key/G1\new
;[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -S "[G2]" G2 keyG2)
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G1]
[G1]
;G2 = comment G1
G2 = key/G1\new
;[G2]
[G2]
G2= keyG2
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### DEL #####
desc="Del key in group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [G1] G2)
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G1]
[G1]
;G2 = comment G1
;[G2]
[G2]
G2= keyG2
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del not exist key in group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [G1] G2)
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del empty group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [G1])
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G1]
[G2]
G2= keyG2
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del not exist group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [G1])
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del key from not exist group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [G3] G2)
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del group"
value=$(./iniedit.sh "$TESTINI" -v -w -D "[G2]")
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G1]
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del wild key"
cat <<EOF > "$TESTINI"
G2 = wildkeyG2
;[G2]
[G2]
;G2 = comment G1
G2 = key/G1\new
;[G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -D G2)
OK=$?
cat <<EOF > "$PRECINI"
;[G2]
[G2]
;G2 = comment G1
G2 = key/G1\new
;[G2]
EOF
#echo "raise error" >> "$PRECINI"
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del splitted name group"
cat <<EOF > "$TESTINI"
G2 = wildkeyG2
;[G2 G2]
[G2 G2]
;G2 = comment G1
G2 = key/G1\new
;[G2 G2]
EOF
value=$(./iniedit.sh "$TESTINI" -v -w -D "[G2 G2]")
OK=$?
cat <<EOF > "$PRECINI"
G2 = wildkeyG2
;[G2 G2]
EOF
#echo "raise error" >> "$PRECINI"
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi
