

./bin$1/ioctl031 2>&1  >/tmp/ioctl031.txt 2>&1 &
sleep 1
./bin$1/send0031 2>&1  >/tmp/send0031.txt 2>&1

sleep 3

echo "---------------" |cat   /tmp/send0031.txt - /tmp/ioctl031.txt
rm -f /tmp/send0031.txt /tmp/ioctl031.txt

