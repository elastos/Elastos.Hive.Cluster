FROM golang:1.12-stretch AS builder
MAINTAINER Hector Sanjuan <hector@protocol.ai>

# This dockerfile builds and runs ipfs-cluster-service.

ENV GOPATH     /go
ENV SRC_PATH   $GOPATH/src/github.com/ipfs/ipfs-cluster
ENV GO111MODULE on
ENV GOPROXY=https://goproxy.cn
#ENV GOPROXY=https://proxy.golang.org

COPY . $SRC_PATH
WORKDIR $SRC_PATH
RUN make install

ENV SUEXEC_VERSION v0.2
ENV TINI_VERSION v0.16.1
RUN set -x \
  && cd /tmp \
  && git clone https://github.com/ncopa/su-exec.git \
  && cd su-exec \
  && git checkout -q $SUEXEC_VERSION \
  && make \
  && cd /tmp \
  && wget -q -O tini https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini \
  && chmod +x tini

# Get the TLS CA certificates, they're not provided by busybox.
RUN apt-get update && apt-get install -y ca-certificates

#------------------------------------------------------
FROM busybox:1-glibc
MAINTAINER Hector Sanjuan <hector@protocol.ai>

# This is the container which just puts the previously
# built binaries on the go-ipfs-container.

ENV GOPATH     /go
ENV SRC_PATH   /go/src/github.com/ipfs/ipfs-cluster
ENV IPFS_PATH /data/ipfs
ENV IPFS_CLUSTER_PATH /data/ipfs/cluster
ENV IPFS_CLUSTER_CONSENSUS crdt

# Swarm TCP; should be exposed to the public
EXPOSE 4001
# Daemon API; must not be exposed publicly but to client services under you control
EXPOSE 5001
# Web Gateway; can be exposed publicly with a proxy, e.g. as https://ipfs.example.org
EXPOSE 8080
# Swarm Websockets; must be exposed publicly when the node is listening using the websocket transport (/ipX/.../tcp/8081/ws).
EXPOSE 8081

EXPOSE 9094
EXPOSE 9095
EXPOSE 9096

COPY --from=builder $GOPATH/bin/ipfs-cluster-service /usr/local/bin/ipfs-cluster-service
COPY --from=builder $GOPATH/bin/ipfs-cluster-ctl /usr/local/bin/ipfs-cluster-ctl
COPY --from=builder $SRC_PATH/docker/start-daemons.sh /usr/local/bin/start-daemons.sh
COPY --from=builder /tmp/su-exec/su-exec /sbin/su-exec
COPY --from=builder /tmp/tini /sbin/tini
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

#for ipfs
COPY --from=builder $SRC_PATH/shell/ipfs /usr/local/bin/ipfs
COPY --from=builder $SRC_PATH/shell/swarm.key /usr/local/bin/swarm.key

# This shared lib (part of glibc) doesn't seem to be included with busybox.
COPY --from=0 /lib/x86_64-linux-gnu/libdl-2.24.so /lib/libdl.so.2

#for ipfs
RUN mkdir -p $IPFS_PATH && \
    adduser -D -h $IPFS_PATH -u 1000 -G users ipfs && \
    chown ipfs:users $IPFS_PATH

VOLUME $IPFS_PATH

RUN mkdir -p $IPFS_CLUSTER_PATH && \
    #adduser -D -h $IPFS_PATH -u 1000 -G users ipfs && \
    chown ipfs:users $IPFS_CLUSTER_PATH

RUN chmod 777 /usr/local/bin/ipfs
RUN chmod 777 /usr/local/bin/ipfs-cluster-service

VOLUME $IPFS_CLUSTER_PATH

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start-daemons.sh"]

# Defaults for ipfs-cluster-service go here
CMD ["daemon"]
