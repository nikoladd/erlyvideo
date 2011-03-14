#/bin/sh
#update from repo
git pull

#clean old build
make clean
/bin/rm -r debian/erlyvideo

#build
make

#create installation files
make install

#install the files
cd debian/erlyvideo/

/bin/cp  -r usr/* /usr/

if [ "$1" -eq "initial"]
then
  /bin/cp -r etc/erlyvideo/ /etc/
  /bin/cp etc/init.d/erlyvideo /etc/init.d/erlyvideo
  
  /bin/cp -r var/ /var/ 
fi

cd ../..

