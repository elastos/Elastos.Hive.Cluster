# IPFS Cluster


[![Made by](https://img.shields.io/badge/made%20by-Protocol%20Labs-blue.svg?style=flat-square)](https://protocol.ai)
[![Main project](https://img.shields.io/badge/project-ipfs-blue.svg?style=flat-square)](http://github.com/ipfs/ipfs)
[![IRC channel](https://img.shields.io/badge/freenode-%23ipfs--cluster-blue.svg?style=flat-square)](http://webchat.freenode.net/?channels=%23ipfs-cluster)
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![GoDoc](https://godoc.org/github.com/ipfs/ipfs-cluster?status.svg)](https://godoc.org/github.com/ipfs/ipfs-cluster)
[![Go Report Card](https://goreportcard.com/badge/github.com/ipfs/ipfs-cluster)](https://goreportcard.com/report/github.com/ipfs/ipfs-cluster)
[![Build Status](https://travis-ci.com/ipfs/ipfs-cluster.svg?branch=master)](https://travis-ci.com/ipfs/ipfs-cluster)
[![codecov](https://codecov.io/gh/ipfs/ipfs-cluster/branch/master/graph/badge.svg)](https://codecov.io/gh/ipfs/ipfs-cluster)

> Pinset orchestration for IPFS.

<p align="center">
<img src="https://cluster.ipfs.io/cluster/png/IPFS_Cluster_color_no_text.png" alt="logo" width="300" height="300" />
</p>

IPFS Cluster is a stand-alone application and a CLI client that allocates, replicates, and tracks pins across a cluster of IPFS daemons.

It provides:

* A cluster peer application: `ipfs-cluster-service`, to be run along with `go-ipfs`.
* A client CLI application: `ipfs-cluster-ctl`, which allows easily interacting with the peer's HTTP API.

---

### Are you using IPFS Cluster?

Please participate in the [IPFS Cluster user registry](https://docs.google.com/forms/d/e/1FAIpQLSdWF5aXNXrAK_sCyu1eVv2obTaKVO3Ac5dfgl2r5_IWcizGRg/viewform).

---

## Table of Contents

- [Documentation](#documentation)
- [News & Roadmap](#news--roadmap)
- [Install](#install)
- [Docker image](#Building Image)
- [Usage](#usage)
- [Contribute](#contribute)
- [License](#license)


## Documentation

Please visit https://cluster.ipfs.io/documentation/ to access user documentation, guides and any other resources, including detailed **download** and **usage** instructions.

## News & Roadmap

We regularly post project updates to https://cluster.ipfs.io/news/ .

The most up-to-date *Roadmap* is available at https://cluster.ipfs.io/roadmap/ .

## Install

Instructions for different installation methods (including from source) are available at https://cluster.ipfs.io/download .

##Docker image

The following requirements apply to the building the docker image:

- Go 1.12+
- Git
- docker 18+

Run
```sh
git clone https://github.com/elastos/Elastos.NET.Hive.Cluster  -b improvement-0.1

cd ipfs-cluster

docker build . -t hive
```

Change logs 
```
1 ENV GOPROXY=https://goproxy.cn

2 same CLUSTER_SECRET
CLUSTER_SECRET="d2b0fb2c1efc772e5720c0f659bffa0fb800efcdebc8c7e9b94c183f2a285546"

3 swarm.key  
file  in Elastos.NET.Hive.Cluster\shell
```

###Save images 

show docker images：
```sh
docker images
```
```
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
hive                latest              90b2ef439b40         1 hours ago         63.2MB
```
save images：
```sh
docker save -o path name:tag
```
example:
```sh
docker save -o ./hive.tar hive:latest 
```
load images:
```sh
docker load --input ./hive.tar
```
copy hive.tar form in other node


###Run images
```sh
docker run -p 4001:4001 -p 5001:5001 -p 8080:8080 -p 8081:8081 -p 9094:9094 -p 9095:9095 -p 9096:9096  -it hive:latest daemon --bootstrap XXX
```
example:
```sh
docker run -p 4001:4001 -p 5001:5001 -p 8080:8080 -p 8081:8081 -p 9094:9094 -p 9095:9095 -p 9096:9096  -it hive:latest daemon --bootstrap /ip4/10.10.156.160/tcp/9096/p2p/12D3KooWFG2K54RPcbTMdeN5di57NeEbMM3shb3txnBTGfP6kqMD
```


## Usage

Extensive usage information is provided at https://cluster.ipfs.io/documentation/ , including:

* [Docs for `ipfs-cluster-service`](https://cluster.ipfs.io/documentation/ipfs-cluster-service/)
* [Docs for `ipfs-cluster-ctl`](https://cluster.ipfs.io/documentation/ipfs-cluster-ctl/)

## Contribute

PRs accepted. As part of the IPFS project, we have some [contribution guidelines](https://cluster.ipfs.io/developer/contribute).

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

This library is dual-licensed under Apache 2.0 and MIT terms.

© 2019. Protocol Labs, Inc.
