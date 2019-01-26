
TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BIN_DIR := $(TOP_DIR)/deb/usr/bin
GIT_VERSION := $(shell git rev-parse --short HEAD)
TARGET := hive-cluster-${GIT_VERSION}.deb

all: pack

pack:
	[ -d "${BIN_DIR}" ] || mkdir -p "${BIN_DIR}" || true
	@install "${GOPATH}/bin/ipfs" 			"${BIN_DIR}"
	@install "${GOPATH}/bin/ipfs-cluster-ctl" 	"${BIN_DIR}"
	@install "${GOPATH}/bin/ipfs-cluster-service" 	"${BIN_DIR}"
	@fakeroot dpkg-deb --build ${TOP_DIR}/deb 	"${TOP_DIR}/${TARGET}"

clean:
	@rm -rf "${BIN_DIR}"
	@rm -f "${TOP_DIR}/${TARGET}"

.PHONY: all pack
