PWD := $(shell pwd)
LOCAL_BIN ?= $(PWD)/bin

# ENVTEST_K8S_VERSION refers to the version of kubebuilder assets to be downloaded by envtest binary.
ENVTEST_K8S_VERSION = 1.29.x

# Keep an existing GOPATH, make a private one if it is undefined
GOPATH_DEFAULT := $(PWD)/.go
export GOPATH ?= $(GOPATH_DEFAULT)
GOBIN_DEFAULT := $(GOPATH)/bin
export GOBIN ?= $(GOBIN_DEFAULT)
export PATH := $(LOCAL_BIN):$(GOBIN):$(PATH)

include build/common/Makefile.common.mk

############################################################
# clean section
############################################################

.PHONY: clean
clean:
	-rm bin/*
	-rm -r vendor/
	-rm build/_output/*
	-rm kubeconfig_$(CLUSTER_NAME)_e2e
	kind delete cluster --name test-$(CLUSTER_NAME)

############################################################
# build section
############################################################
BUILD_DIR := $(PWD)/build/_output
BINARY_DIR ?= $(PWD)/cmd/*
BINARY_NAME := policytools
CONTAINER_ENGINE ?= podman
# Parse the version using git, with fallbacks as follows:
# - git describe (i.e. vX.Y.Z-<extra_commits>-<sha>)
# - <branch>-<sha>
# - <sha>-dev
# - Go BuildInfo version
# - Unversioned binary
GIT_VERSION := $(shell git describe --dirty 2>/dev/null)
ifndef GIT_VERSION
  GIT_BRANCH := $(shell git branch --show-current)
  GIT_SHA := $(shell git rev-parse --short HEAD)
  ifdef GIT_BRANCH
    GIT_VERSION := $(GIT_BRANCH)-$(GIT_SHA)
  else ifdef GIT_SHA
    GIT_VERSION := $(GIT_SHA)-dev
  endif
endif
GO_LDFLAGS ?= -X 'main.Version=$(GIT_VERSION)'

.PHONY: build-all
build-all:
	# Building binaries with output to $(subst $(PWD),.,$(BUILD_DIR))
	@for binary in $(BINARY_DIR); do \
		echo "Building $$(basename $${binary}) ...";\
		go build -o $(BUILD_DIR)/$$(basename $${binary}) $${binary}; \
	done

.PHONY: build
build: BINARY_DIR = ./cmd/$(BINARY_NAME)
build: build-all

.PHONY: build-release
build-release:
	@if [ $(shell git status --porcelain | wc -l) -gt 0 ]; then \
			echo "There are local modifications in the repo" > /dev/stderr; \
			exit 1; \
	fi
	GOOS=linux CGO_ENABLED=0 GOARCH=amd64 go build -ldflags="$(GO_LDFLAGS)" -o ${BUILD_DIR}/linux-amd64-$(BINARY_NAME) ./cmd/$(BINARY_NAME)
	GOOS=darwin CGO_ENABLED=0 GOARCH=amd64 go build -ldflags="$(GO_LDFLAGS)" -o ${BUILD_DIR}/darwin-amd64-$(BINARY_NAME) ./cmd/$(BINARY_NAME)
	GOOS=windows CGO_ENABLED=0 GOARCH=amd64 go build -ldflags="$(GO_LDFLAGS)" -o ${BUILD_DIR}/windows-amd64-$(BINARY_NAME).exe ./cmd/$(BINARY_NAME)

.PHONY: build-oc-plugin
build-oc-plugin: build
	# Installing oc plugin
	cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/oc-$(BINARY_NAME)

############################################################
# lint section
############################################################

.PHONY: fmt
fmt:

.PHONY: lint
lint:

############################################################
# test section
############################################################

.PHONY: test
test: envtest
	KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) -p path)" go test $(TESTARGS) ./...

.PHONY: test-coverage
test-coverage: TESTARGS = -v -json -cover -covermode=atomic -coverprofile=coverage.out
test-coverage: test

.PHONY: gosec-scan
gosec-scan:
