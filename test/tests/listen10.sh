

./bin$1/listen10 2>&1  >/tmp/listen10.txt 2>&1 &
sleep 1
./bin$1/send0010 2>&1  >/tmp/send0010.txt 2>&1

sleep 1

echo "-----------------" |cat   /tmp/send0010.txt - /tmp/listen10.txt
rm -f /tmp/send0010.txt /tmp/listen10.txt

