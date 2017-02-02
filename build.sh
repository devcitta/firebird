#!/bin/bash
set -e
CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)

apt-get update
apt-get install -qy --no-install-recommends \
    libicu52 \
    libtommath0
apt-get install -qy --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    gcc \
    libicu-dev \
    libncurses5-dev \
    libtommath-dev \
    make \
    zlib1g-dev
mkdir -p /home/firebird
cd /home/firebird
curl -o firebird-source.tar.bz2 -L \
    "${FBURL}"
tar --strip=1 -xf firebird-source.tar.bz2
./configure \
    --prefix=${PREFIX}/ --with-fbbin=${PREFIX}/bin/ --with-fbsbin=${PREFIX}/bin/ --with-fblib=${PREFIX}/lib/ \
    --with-fbinclude=${PREFIX}/include/ --with-fbdoc=${PREFIX}/doc/ --with-fbudf=${PREFIX}/UDF/ \
    --with-fbsample=${PREFIX}/examples/ --with-fbsample-db=${PREFIX}/examples/empbuild/ --with-fbhelp=${PREFIX}/help/ \
    --with-fbintl=${PREFIX}/intl/ --with-fbmisc=${PREFIX}/misc/ --with-fbplugins=${PREFIX}/ \
    --with-fbconf=/var/firebird/etc/ --with-fbmsg=${PREFIX}/ \
    --with-fblog=/var/firebird/log/ --with-fbglock=/var/firebird/run/ \
    --with-fbsecure-db=/var/firebird/system --with-system-icu
make -j${CPUC}
make silent_install
cd /
rm -rf /home/firebird
find ${PREFIX} -name .debug -prune -exec rm -rf {} \;
apt-get purge -qy --auto-remove \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    gcc \
    libicu-dev \
    libncurses5-dev \
    libtommath-dev \
    make \
    zlib1g-dev
rm -rf /var/lib/apt/lists/*

${PREFIX}/bin/isql -user sysdba employee <<EOL
create user SYSDBA password 'masterkey';
commit;
quit;
EOL

cat > /var/firebird/etc/SYSDBA.password <<EOL
# Firebird generated password for user SYSDBA is:
#
ISC_USER=sysdba
ISC_PASSWORD=masterkey
#
# Also set legacy variable though it can't be exported directly
#
ISC_PASSWD=masterkey
#
# generated on 33842653d6db at time Wed Feb  1 18:49:55 UTC 2017
#
# Your password can be changed to a more suitable one using
# SQL operator ALTER USER.
#

EOL
