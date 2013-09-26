#!/bin/sh

SETUPTOOLS=`grep "setuptools\s*\=\s*" versions.cfg | sed 's/ *$//g' | sed 's/=$//g' | sed 's/\s*=\s*/==/g'`
ZCBUILDOUT=`grep "zc\.buildout\s*=\s*" versions.cfg | sed 's/\s*=\s*/==/g'`

if [ -z "$SETUPTOOLS" ]; then
  SETUPTOOLS="setuptools"
fi

if [ -z "$ZCBUILDOUT" ]; then
  ZCBUILDOUT="zc.buildout"
fi

if [ -s "bin/activate" ]; then
  echo "Updating setuptools: ./bin/easy_install" $SETUPTOOLS
  ./bin/easy_install $SETUPTOOLS

  echo "Updating zc.buildout: ./bin/easy_install" $ZCBUILDOUT
  ./bin/easy_install $ZCBUILDOUT

  echo ""
  echo "============================================================="
  echo "Buildout is already installed."
  echo "Please remove bin/activate if you want to re-run this script."
  echo "============================================================="
  echo ""

  exit 0
fi

echo "Installing virtualenv"
wget --no-check-certificate "http://raw.github.com/pypa/virtualenv/1.9.X/virtualenv.py" -O "/tmp/virtualenv.py"

echo "Running: python2.6 /tmp/virtualenv.py --clear ."
python2.6 "/tmp/virtualenv.py" --clear --setuptools  .

rm /tmp/virtualenv.py*

echo "Installing zc.buildout: $ ./bin/easy_install" $ZCBUILDOUT
./bin/easy_install $ZCBUILDOUT

echo "Disabling the SSL CERTIFICATION for git"
git config --global http.sslVerify false

# Copy templates from .core master
TMP_CHECKOUT="/tmp/eea.plonebuildout.core"
git clone https://github.com/eea/eea.plonebuildout.core.git $TMP_CHECKOUT
mkdir -p ./buildout-configs/templates
cp -r $TMP_CHECKOUT/buildout-configs/templates ./buildout-configs/
rm -rf $TMP_CHECKOUT

# Fix permissions
echo "Fixing permissions"
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
chmod g+rw -R ./lib/python2.6
IFS=$SAVEIFS

echo ""
echo "==========================================================="
echo "All set. Now you can run ./bin/buildout or ./bin/develop rb"
echo "==========================================================="
echo ""
