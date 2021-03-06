#!/bin/sh

# Downloads and unpacks Abitti (www.abitti.fi) disk images.
#
# This script is public domain.
#
# This script is not supported by Matriculation Examination Board of
# Finland. The download URLs may change without any notice. For
# supported tools see www.abitti.fi.

FLAVOUR=prod

report_error() {
	echo -------Error---------------------------------
	echo $1 >&2
	echo ---------------------------------------------
	exit 1
}

report_warning() {
    MESSAGE=$1
    echo -------Warning-------------------------------
    echo $1
    echo ---------------------------------------------
}

download_and_check() {
	TAG=$1
	
	wget -c http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip.md5
	if [ $? -ne 0 ]; then
		report_error "Failed to download image '${TAG}' MD5: $?"
	fi
	
	wget -c http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip
	if [ $? -ne 0 ]; then
		report_error "Failed to download image '${TAG}': $?"
	fi
	
	cat ${TAG}.zip.md5 | md5sum --check --status
	if [ $? -ne 0 ]; then
		report_error "Failed to verify image '${TAG}': $?"
	fi
	
	unzip ${TAG}.zip
	if [ $? -ne 0 ]; then
		report_error "Failed to unzip image '${TAG}': $?"
	fi
	
	# Remove temporary files
	rm ${TAG}.zip
	rm ${TAG}.zip.md5
}


VERSION=`wget http://static.abitti.fi/usbimg/${FLAVOUR}/latest.txt -q -O-`

if [ "${VERSION}" = "" ]; then
	report_error "Could not get latest Abitti version for flavour '${FLAVOUR}'"
fi

echo "Latest Abitti version: ${VERSION}"

DEST=abitti_v${VERSION}

if [ -d ${DEST} ]; then
	report_error "Directory ${DEST} already exists"
fi

mkdir ${DEST}
cd ${DEST}

download_and_check ktp
download_and_check koe

# Normal termination
exit 0
