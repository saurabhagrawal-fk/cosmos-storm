#!/bin/sh
PACKAGE=pe-cosmos-storm
PACKAGE_ROOT="./cosmos-storm-pkg"
VERSION=$GO_PIPELINE_LABEL
ARCH=all

echo "Removing old temp directory ${PACKAGE_ROOT} ..."
rm -rf $PACKAGE_ROOT

echo "Creating temp packaging directory ${PACKAGE_ROOT} ..."
mkdir -p $PACKAGE_ROOT
mkdir -p $PACKAGE_ROOT/DEBIAN
mkdir -p $PACKAGE_ROOT/var/lib/$PACKAGE
mkdir -p $PACKAGE_ROOT/etc/$PACKAGE
#mkdir -p $PACKAGE_ROOT/etc/init.d
mkdir -p $PACKAGE_ROOT/etc/cron.d
mkdir -p $PACKAGE_ROOT/etc/confd/templates
mkdir -p $PACKAGE_ROOT/etc/confd/conf.d/

echo "Copying debian files to ${PACKAGE_ROOT} ..."
cp pkg/deb/$PACKAGE.control $PACKAGE_ROOT/DEBIAN/control
cp pkg/deb/$PACKAGE.postinst $PACKAGE_ROOT/DEBIAN/postinst
cp pkg/deb/$PACKAGE.postrm $PACKAGE_ROOT/DEBIAN/postrm
cp pkg/deb/$PACKAGE.preinst $PACKAGE_ROOT/DEBIAN/preinst
cp pkg/deb/$PACKAGE.prerm $PACKAGE_ROOT/DEBIAN/prerm
#cp pkg/deb/$PACKAGE-init $PACKAGE_ROOT/etc/init.d/$PACKAGE

echo "Updating version in control file ..."
sed -e "s/VERSION/${VERSION}/" -i $PACKAGE_ROOT/DEBIAN/control

echo "Pip - Fetching dependencies ..."
pip install -r pkg/requirements.txt -t $PACKAGE_ROOT/var/lib/$PACKAGE/libs

echo "Copying python script to ${PACKAGE_ROOT} ..."
cp src/cosmos-storm.py $PACKAGE_ROOT/var/lib/$PACKAGE/

cp src/cosmos-storm $PACKAGE_ROOT/etc/cron.d/

echo "Building debian ..."
dpkg-deb -b $PACKAGE_ROOT

echo "Removing older debians ..."
rm -f pkg/*.deb

echo "Renaming debian ..."
mv $PACKAGE_ROOT.deb pkg/${PACKAGE}_${VERSION}_${ARCH}.deb

echo "Removing temp directory ${PACKAGE_ROOT} ..."
rm -r $PACKAGE_ROOT

echo "Done."
