

./bin$1/listen03 2>&1  >/tmp/listen03.txt 2>&1 &
sleep 1
./bin$1/send0003 2>&1  >/tmp/send0003.txt 2>&1

sleep 1

echo "-----------------" |cat   /tmp/send0003.txt - /tmp/listen03.txt
rm -f /tmp/send0003.txt /tmp/listen03.txt

