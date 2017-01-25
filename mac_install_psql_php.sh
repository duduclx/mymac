#!/bin/bash
# Install PostgreSQL PHP extensions on Mac OS X
# You need to install Postgres.app first

# Install HomeBrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Xcode Command Line Tools first (required)
xcode-select --install

# Check PHP version `php --version`
PHP_VER=$(php -v | head -1 | awk '{ print $2 }')

# Extensions directory (default: empty string)
EXT_DIR=""

# Postgres.app < 9.3.5.0
#PG_APP="/Applications/Postgres.app/Contents/MacOS"
# Postgres.app >= 9.3.5.0 (check currently installed version first!)
PG_VER="9.6"
PG_APP="/Applications/Postgres.app/Contents/Versions/$PG_VER"

# El Capitan / Sierra workaround
if [ $(uname -r | head -c2) > 14 ]; then
  EXT_DIR=/usr/local/lib/php/extensions/
  mkdir -p $EXT_DIR
fi

# Check if extension exists first
php -m | grep pgsql
 
# Update brew and install requirements
brew update
brew install autoconf
 
# Download PHP source and extract
mkdir -p ~/src && cd ~/src
curl -O http://php.net/distributions/php-$PHP_VER.tar.bz2
tar -xjf php-$PHP_VER.tar.bz2

# Go to extension dir and phpize
cd ~/src/php-$PHP_VER/ext/pdo_pgsql/
phpize
 
# Configure for Postgress.app or just use `./configure` for the brew version
./configure --with-pdo-pgsql=$PG_APP
make

# El Capitan / Sierra workaround
if [ $(uname -r | head -c2) > 14 ]; then
  cp ./modules/pdo_pgsql.so $EXT_DIR
else
  sudo make install
fi
echo "extension=${EXT_DIR}pdo_pgsql.so" | sudo tee -a /private/etc/php.ini

# Go to extension dir and phpize
cd ~/src/php-$PHP_VER/ext/pgsql/
phpize
 
# Configure for Postgress.app or just use `./configure` for the brew version
./configure --with-pgsql=$PG_APP
make

# El Capitan / Sierra workaround
if [ $(uname -r | head -c2) > 14 ]; then
  cp ./modules/pgsql.so $EXT_DIR
else
  sudo make install
fi
echo "extension=${EXT_DIR}pgsql.so" | sudo tee -a /private/etc/php.ini

# Check if extension exists, again
php -m | grep pgsql

# Cleanup
rm -rf ~/src/php-$PHP_VER/
