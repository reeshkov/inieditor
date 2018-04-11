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


##### get existing #####
# key
value=$(./iniedit.sh "$TESTINI" -v -G wildkey)
OK=$?
if [ 0 -eq $OK ] && [ "keywild" == "$value" ]; then
  echo -e "Get wild key OK. Value = $value"
else
  echo -e "Get wild key FAIL. Output:\n$value" && exit $OK
fi
# group
value=$(./iniedit.sh "$TESTINI" -v -G [G3])
OK=$?
if [ 0 -eq $OK ] && [ "[G3]" == "$value" ]; then
  echo -e "Get(check) group OK. Value = $value"
else
  echo -e "Get(check) group FAIL. Output:\n$value" && exit $OK
fi
# key in group
value=$(./iniedit.sh "$TESTINI" -v -G [G2] G2key)
OK=$?
if [ 0 -eq $OK ] && [ "/key/G2" == "$value" ]; then
  echo -e "Get value from group key OK. Value = $value"
else
  echo -e "Get value from group key FAIL. Output:\n$value" && exit $OK
fi

##### get not existing #####
# key
value=$(./iniedit.sh "$TESTINI" -v -G nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "Get not existing key OK. Code=$OK"
else
  echo -e "Get not existing key FAIL. Output:\n$value" && exit $OK
fi
# group
value=$(./iniedit.sh "$TESTINI" -v -G [nonegroup])
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "Get not existing group OK. Code=$OK"
else
  echo -e "Get not existing group FAIL. Output:\n$value" && exit $OK
fi

# key in not existing group
value=$(./iniedit.sh "$TESTINI" -v -G [nonegroup] nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "Get value from not existing group, not existing key OK. Code=$OK"
else
  echo -e "Get value from not existing group, not existing key FAIL. Output:\n$value" && exit $OK
fi
# group's exist key
value=$(./iniedit.sh "$TESTINI" -v -G [nonegroup] wildkey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "Get value from not existing group, existing key OK. Code=$OK"
else
  echo -e "Get value from not existing group, existing key FAIL. Output:\n$value" && exit $OK
fi
# key in exist group
value=$(./iniedit.sh "$TESTINI" -v -G [G2] nonekey)
OK=$?
if [ 0 -ne $OK ]; then
  echo -e "Get value from existing group, not existing key OK. Code=$OK"
else
  echo -e "Get value from existing group, not existing key FAIL. Output:\n$value" && exit $OK
fi

##### change value (set exist key) #####
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
  echo -e "Set exist wild key OK. Code = $OK"
else
  echo -e "Set exist key FAIL. Output:\n$value\nCode=$OK" && exit $OK
fi

##### set exist group #####
value=$(./iniedit.sh "$TESTINI" -v -w -S [G1])
OK=$?
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "Set exist group OK. Code = $OK"
else
  echo -e "Set exist group. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### set exist key in exist group #####
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
  echo -e "Set exist key in exist group OK. Code = $OK"
else
  echo -e "Set exist key in exist group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### set new wild key #####
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
  echo -e "Set new wild key OK. Code = $OK"
else
  echo -e "Set new wild key FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### set new group #####
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
  echo -e "Set new group OK. Code = $OK"
else
  echo -e "Set new group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### set new key in exist empty group #####
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
  echo -e "Set new key in exist empty group OK. Code = $OK"
else
  echo -e "Set new key in exist empty group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi


##### set new key in new group #####
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
  echo -e "Set new key in new group OK. Code = $OK"
else
  echo -e "Set new key in new group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del key in group #####
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
  echo -e "Del key in group OK. Code = $OK"
else
  echo -e "Del key in group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del not exist key in group #####
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup2] nonekey)
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "Del not exist key in group OK. Code = $OK"
else
  echo -e "Del not exist key in group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del empty group #####
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
  echo -e "Del empty group OK. Code = $OK"
else
  echo -e "Del empty group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del not exist group #####
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup])
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "Del not exist group OK. Code = $OK"
else
  echo -e "Del not exist group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del key from not exist group #####
value=$(./iniedit.sh "$TESTINI" -v -w -D [newgroup] newwildkey)
OK=$?
if [ 0 -eq $OK ]; then
  echo -e "Del key from not exist group OK. Code = $OK"
else
  echo -e "Del key from not exist group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi


##### del group #####
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
  echo -e "Del group OK. Code = $OK"
else
  echo -e "Del group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del group #####
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
  echo -e "Del group OK. Code = $OK"
else
  echo -e "Del group FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi

##### del wild key #####
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
err=$(diff -waB "$TESTINI" "$PRECINI")
dOK=$?
if [ 0 -eq $dOK ]; then
  echo -e "Del wild key OK. Code = $OK"
else
  echo -e "Del wild key FAIL. Output:\n$value\nCode=$OK\nError=$err" && exit $OK
fi
