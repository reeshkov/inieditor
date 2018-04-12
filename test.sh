#!/bin/bash
set +e

PRECINI=prec.ini
TESTINI=test.ini

cat <<EOF > "$TESTINI"
wildkey = keywild
[G1]
G1key = http://keyG1
[G2]
G2key = /key/G2
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
EOF


##### GET #####
desc="Get wild key"
value=$(./iniedit.sh "$TESTINI" -v -G wildkey)
OK=$?
if [ 0 -eq $OK ] && [ "keywild" == "$value" ]; then
  echo -e "OK   $desc. Value = $value"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get(check) group"
value=$(./iniedit.sh "$TESTINI" -v -G [G3])
OK=$?
if [ 0 -eq $OK ] && [ "[G3]" == "$value" ]; then
  echo -e "OK   $desc. Value = $value"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from group key"
value=$(./iniedit.sh "$TESTINI" -v -G [G2] G2key)
OK=$?
if [ 0 -eq $OK ] && [ "/key/G2" == "$value" ]; then
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
value=$(./iniedit.sh "$TESTINI" -v -G [nonegroup])
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from not existing group, not existing key"
value=$(./iniedit.sh "$TESTINI" -v -G [nonegroup] nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from not existing group, existing key"
value=$(./iniedit.sh "$TESTINI" -v -G [nonegroup] wildkey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

desc="Get value from existing group, not existing key"
value=$(./iniedit.sh "$TESTINI" -v -G [G2] nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "OK   $desc. Code=$OK"
else
  echo -e "FAIL $desc. Output:\n$value" && exit $OK
fi

##### SET #####
desc="Set exist wild key"
value=$(./iniedit.sh "$TESTINI" -v -w -S wildkey wildkeyvalue/set)
OK=$?
cat <<EOF > "$PRECINI"
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = /key/G2
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
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
value=$(./iniedit.sh "$TESTINI" -v -w -S [G2] G2key "key/G2\new")
OK=$?
cat <<EOF > "$PRECINI"
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new wild key"
value=$(./iniedit.sh "$TESTINI" -v -w -S newwildkey newwildvalue)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new group"
value=$(./iniedit.sh "$TESTINI" -v -w -S newgroup)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
[newgroup]
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new key in exist empty group"
value=$(./iniedit.sh "$TESTINI" -v -w -S [newgroup] NGkey keyNG)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
[newgroup]
NGkey = keyNG
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Set new key in new group"
value=$(./iniedit.sh "$TESTINI" -v -w -S [newgroup2] NG2key keyNG2)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
[newgroup]
NGkey = keyNG
[newgroup2]
NG2key=keyNG2
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
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup] NGkey)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
[newgroup]
[newgroup2]
NG2key=keyNG2
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del not exist key in group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup2] nonekey)
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del empty group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup])
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[G3/SG3]
SG3key = keySG3
[newgroup2]
NG2key=keyNG2
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del not exist group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup])
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del key from not exist group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup] newwildkey)
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del group"
value=$(./iniedit.sh "$TESTINI" -v -w -D [G3/SG3])
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
wildkey = wildkeyvalue/set
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[newgroup2]
NG2key=keyNG2
EOF
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

desc="Del wild key"
value=$(./iniedit.sh "$TESTINI" -v -w -D wildkey)
OK=$?
cat <<EOF > "$PRECINI"
newwildkey = newwildvalue
[G1]
G1key = http://keyG1
[G2]
G2key = key/G2\new
[G3]
G3key = keyG3
[newgroup2]
NG2key=keyNG2
EOF
#echo "raise error" >> "$PRECINI"
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "OK   $desc. Code = $OK"
else
  echo -e "FAIL $desc. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi
