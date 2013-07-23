#!/bin/sh

DISTRIBUTE=`grep "distribute\s*\=\s*" versions.cfg | sed 's/ *$//g' | sed 's/=$//g' | sed 's/\s*=\s*/==/g'`
ZCBUILDOUT=`grep "zc\.buildout\s*=\s*" versions.cfg | sed 's/\s*=\s*/==/g'`

if [ -z "$DISTRIBUTE" ]; then
  DISTRIBUTE="distribute"
fi

if [ -z "$ZCBUILDOUT" ]; then
  ZCBUILDOUT="zc.buildout"
fi

if [ -s "bin/activate" ]; then
  echo "Updating distribute: ./bin/easy_install" $SETUPTOOLS
  ./bin/easy_install $DISTRIBUTE

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
wget --no-check-certificate "https://raw.github.com/pypa/virtualenv/master/virtualenv.py" -O "/tmp/virtualenv.py"

echo "Running: python2.7 /tmp/virtualenv.py --clear ."
python2.7 "/tmp/virtualenv.py" --clear --distribute  .
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

# fix permissions
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for i in `cat afterinstallsh.txt`; do
 chmod g+rw $i;
done
IFS=$SAVEIFS


echo ""
echo "==========================================================="
echo "All set. Now you can run ./bin/buildout or ./bin/develop rb"
echo "==========================================================="
echo ""
