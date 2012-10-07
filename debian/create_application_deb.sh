#!/bin/bash
#
# /usr/local/bin/debcut
#
# This script makes debian packages out of the latest Aegis baseline
# and copies them to a central repository. 
# This script was written around 2002 so probably very outdated now


if [[ -z "$FAKEROOTKEY" ]]
then
  echo "This script must run under fakeroot!" >&2
  exit 1
fi

cd /tmp
mkdir cut_tmp
mkdir cut_tmp/cut
cd cut_tmp
umask 022


if [[ ! -x ./cut ]]
then
  echo "Something bad has happened!" >&2
  exit 1
fi

function cleanup () {
  rm -rf modules
  rm -rf shop
  rm -rf bin
}

function cleanup_after () {
  cd /tmp
  rm -rf cut_tmp
}

function makedirs () {
  mkdir -p modules/DEBIAN
  mkdir -p modules/usr/local/lib/
  mkdir -p app/DEBIAN
  mkdir -p app/www/
  mkdir -p bin/DEBIAN
  mkdir -p bin/usr/local/
}

function makecontrol () {
  local package=$1
  local version=$2
  local depends="perl"
  if [[ "$3" ]]
  then
    depends="app-modules (>= $version)"
  fi
  cat > "$package/DEBIAN/control" <<EOT
Package: app-$package
Version: $version
Architecture: all
Maintainer: Stephen McCullough <me@swm.cc>
Depends: $depends
Description: app $package
EOT
}

# what is the latest project?
export AEGIS_PROJECT=`aegis -list p -ter | egrep '^app(\.[[:digit:]]+){2}$' | sort -t . -n -k 2,2 -k 3,3 | tail -1`

echo "Aegis project => "
echo $AEGIS_PROJECT

branch=${AEGIS_PROJECT#app.}

# what is the latest delta on this project?
delta=`aegis -list ph -ter | tail -1`

version="$branch.$delta"

echo "Cutting for $version"

cleanup
makedirs

(cd modules/usr/local/lib/; aegis -copy -ind site_perl)
(cd app/www/; aegis -copy -ind shop)
(cd bin/usr/local/; aegis -copy -ind bin)

makecontrol modules $version
makecontrol app $version y
makecontrol bin $version y

(
  cd modules/usr/local/lib/
  aegis -copy -ind site_perl
)
(
  cd app/www/
  aegis -copy -ind shop
)
(
  cd bin/usr/local/
  aegis -copy -ind bin
)

chmod -R ug=rwX,o=rX modules
chmod -R ug=rwx,o=rx app bin
chgrp -R apu modules app bin
dpkg --build modules .
dpkg --build app .
dpkg --build bin .

# now, mv the lot to /var/www/deb and scan the packages
mv /var/www/deb/*.deb /var/www/deb.old
rm -f /var/www/deb/*.deb
mv *.deb /var/www/deb
cd /var/www/deb
dpkg-scanpackages . override | gzip -c >| Packages.gz

cleanup_after

echo -e "\nNew packages may be found in /var/www/deb"
echo "Old packages may be found in /var/www/deb.old"

