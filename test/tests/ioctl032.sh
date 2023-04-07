

./bin$1/ioctl032 2>&1  >/tmp/ioctl032.txt 2>&1 &
sleep 1
./bin$1/send0032 2>&1  >/tmp/send0032.txt 2>&1

sleep 1

echo "----------------" |cat   /tmp/send0032.txt - /tmp/ioctl032.txt
rm -f /tmp/send0032.txt /tmp/ioctl032.txt

