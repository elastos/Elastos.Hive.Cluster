
TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BIN_DIR := $(TOP_DIR)/deb/usr/local/bin
GIT_VERSION := $(shell git rev-parse --short HEAD)
TARGET := hive-dist-${GIT_VERSION}.deb

all: pack

pack:
	[ -d "${BIN_DIR}" ] || mkdir -p "${BIN_DIR}"
	@cp "${GOPATH}/bin/ipfs" 			"${BIN_DIR}"
	@cp "${GOPATH}/bin/ipfs-cluster-ctl" 		"${BIN_DIR}"
	@cp "${GOPATH}/bin/ipfs-cluster-service" 	"${BIN_DIR}"
	@dpkg-deb --build ${TOP_DIR}/deb 		"${TOP_DIR}/${TARGET}"

clean:
	@echo "Clean up ..."
	[ -d "${BIN_DIR}" ] && rm -rf "${BIN_DIR}"
	[ -f "${TOP_DIR}/${TARGET}" ] && rm -f "${TOP_DIR}/${TARGET}"

.PHONY: all pack
