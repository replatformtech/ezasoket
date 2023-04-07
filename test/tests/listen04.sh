

./bin$1/listen04 2>&1  >/tmp/listen04.txt 2>&1 &
sleep 1
./bin$1/writev04 2>&1  >/tmp/writev04.txt 2>&1

sleep 1

echo "-----------------" |cat   /tmp/writev04.txt - /tmp/listen04.txt
rm -f /tmp/writev04.txt /tmp/listen04.txt

