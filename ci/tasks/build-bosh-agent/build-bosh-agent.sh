#!/bin/bash

BOSH_AGENT_SRC=$GOPATH/src/github.com/cloudfoundry/bosh-agent
STEMCELL_ARCHIVE=artifact-stemcell/
STEMCELL_IAAS_IMAGE=artifact-stemcell/image
STEMCELL_MANIFEST=artifact-stemcell/stemcell.MF
STEMCELL_PACKAGE_LIST=artifact-stemcell/stemcell_dpkg_l.txt

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
	
	mkdir -p ${BOSH_AGENT_SRC}/out/release/usr/bin

	mv ${BOSH_AGENT_SRC}/out/bosh-agent ${BOSH_AGENT_SRC}/out/release/usr/bin/bosh-agent

	tar -czvf ${IAAS_IMAGE} --directory=${BOSH_AGENT_SRC}/out/release/ /usr/bin

	if [ ! $? -eq 0 ]
	then
		echo "Could not build Iaas Image. Exiting" >&2
		exit 1
	fi
}

buildManifest() {
	echo "Generating stemcell manifest."

	IMAGE_SHA1=$(sha1 ${IAAS_IMAGE})

	cat > ${STEMCELL_MANIFEST} <<EOF
---
name: bosh-scaleway-ubuntu-trusty-go_agent
operating_system: ubuntu-trusty
version: '3033'
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
	
	cp src-stemcell/ci/tasks/stemcell_dpkg_l.txt	$STEMCELL_PACKAGE_LIST
}

buildBoshAgent
buildIaasImage
buildManifest
buildPackageList