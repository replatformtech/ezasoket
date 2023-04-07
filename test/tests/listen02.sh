

./bin$1/listen02 2>&1  >/tmp/listen02.txt 2>&1 &
sleep 1
./bin$1/write002 2>&1  >/tmp/write002.txt 2>&1
sleep 1

netstat -an |grep 5678
ps -ef |grep listen

echo "----------------" |cat   /tmp/write002.txt - /tmp/listen02.txt
rm -f /tmp/write002.txt /tmp/listen02.txt

