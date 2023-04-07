

./bin$1/listen13 2>&1  >/tmp/listen13.txt 2>&1 &
sleep 1
./bin$1/write013 2>&1  >/tmp/write013.txt 2>&1

sleep 1

echo "-------------------" |cat   /tmp/write013.txt - /tmp/listen13.txt
rm -f /tmp/write013.txt /tmp/listen13.txt

