

./bin$1/listen20 2>&1  >/tmp/listen20.txt 2>&1 &
sleep 1
./bin$1/error020 2>&1  >/tmp/error020.txt 2>&1

sleep 1

echo "-----------------" |cat   /tmp/error020.txt - /tmp/listen20.txt
rm -f /tmp/error020.txt /tmp/listen20.txt
