#!/bin/bash

set -x

BOSH_AGENT_SRC=$GOPATH/src/github.com/cloudfoundry/bosh-agent

STEMCELL_IAAS_IMAGE=artifact-stemcell/image
STEMCELL_MANIFEST=artifact-stemcell/stemcell.MF
STEMCELL_PACKAGE_LIST=artifact-stemcell/stemcell_dpkg_l.txt

STEMCELL_ARCHIVE=artifact-stemcell/scaleway-ubuntu-trusty-stemcell.tgz

VERSION="$(cat version/number)"

buildBoshAgent() {
	echo "Building Bosh Agent."

	go get -d github.com/cloudfoundry/bosh-agent
	go get code.google.com/p/go.tools/cmd/vet
	go get github.com/golang/lint/golint

	${BOSH_AGENT_SRC}/bin/build-linux-amd64

	if [ ! $? -eq 0 ]
	then
		echo "Bosh Agent build failed. Exiting" >&2
		exit 1
	fi
}

buildIaasImage() {
	echo "Building Scaleway Image."
    echo " src : ${BOSH_AGENT_SRC}"
    echo " "
	
	mkdir -p ${BOSH_AGENT_SRC}/out/release/usr/bin

	mv ${BOSH_AGENT_SRC}/out/bosh-agent ${BOSH_AGENT_SRC}/out/release/usr/bin/bosh-agent

	tar -czvf ${STEMCELL_IAAS_IMAGE}.tgz ${BOSH_AGENT_SRC}/out/release/ -C /usr/bin

	if [ ! $? -eq 0 ]
	then
		echo "Could not build Iaas Image. Exiting" >&2
		exit 1
	fi

    mv ${STEMCELL_IAAS_IMAGE}.tgz ${STEMCELL_IAAS_IMAGE}
}

buildManifest() {
	echo "Generating stemcell manifest."

	IMAGE_SHA1=$(sha1sum ${STEMCELL_IAAS_IMAGE})

	cat > ${STEMCELL_MANIFEST} <<EOF
---
name: bosh-scaleway-ubuntu-trusty-go_agent
operating_system: ubuntu-trusty
version: '${VERSION}'
sha1: ${IMAGE_SHA1}
bosh_protocol: 1
cloud_properties:
  name: bosh-scaleway-ubuntu-trusty-go_agent
  version: '${VERSION}'
  region: par1
EOF
}

buildPackageList() {
	echo "Generating OS packages list manifest."
	
	cp src-stemcell/ci/tasks/build-stemcell/stemcell_dpkg_l.txt $STEMCELL_PACKAGE_LIST
}

buildStemcellArchive() {
	echo "Building stemcell archive"

	tar -czvf ${STEMCELL_ARCHIVE} ${STEMCELL_IAAS_IMAGE} ${STEMCELL_MANIFEST} ${STEMCELL_PACKAGE_LIST} -C .
}

buildBoshAgent
buildIaasImage
buildManifest
buildPackageList
buildStemcellArchive