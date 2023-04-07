

./bin$1/listen12 2>&1  >/tmp/listen12.txt 2>&1 &
sleep 1
./bin$1/write012 2>&1  >/tmp/write012.txt 2>&1

sleep 1

echo "---------------------" |cat   /tmp/write012.txt - /tmp/listen12.txt
rm -f /tmp/write012.txt /tmp/listen12.txt

