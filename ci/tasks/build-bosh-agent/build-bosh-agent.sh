#!/bin/bash
go get -d github.com/cloudfoundry/bosh-agent
go get code.google.com/p/go.tools/cmd/vet
go get github.com/golang/lint/golint

$GOPATH/src/github.com/cloudfoundry/bosh-agent/bin/build-linux-amd64

tar czvf artifact-stemcell/scaleway-ubuntu-trusty-stemcell.tgz $GOPATH/src/github.com/cloudfoundry/bosh-agent/out -C /usr/bin

ls artifact-stemcell/