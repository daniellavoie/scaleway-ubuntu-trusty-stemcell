#!/bin/bash
go get -d github.com/cloudfoundry/bosh-agent
go get code.google.com/p/go.tools/cmd/vet
go get github.com/golang/lint/golint

$GOPATH/src/github.com/cloudfoundry/bosh-agent/bin/build-linux-amd64

mkdir -p $GOPATH/src/github.com/cloudfoundry/bosh-agent/out/release/usr/bin

mv $GOPATH/src/github.com/cloudfoundry/bosh-agent/out/bosh-agent $GOPATH/src/github.com/cloudfoundry/bosh-agent/out/release/usr/bin/bosh-agent

tar -czvf artifact-stemcell/scaleway-ubuntu-trusty-stemcell.tgz --directory=$GOPATH/src/github.com/cloudfoundry/bosh-agent/out/release/ .

ls artifact-stemcell/