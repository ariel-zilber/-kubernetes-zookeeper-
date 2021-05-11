FROM ubuntu:20.04
ENV ZK_USER=zookeeper \
ZK_DATA_DIR=/var/lib/zookeeper/data \
ZK_DATA_LOG_DIR=/var/lib/zookeeper/log \
ZK_LOG_DIR=/var/log/zookeeper \
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ARG GPG_KEY=C823E3E5B12AF29C67F81976F5CECB3CB5E9BD2D
ARG ZK_DIST=zookeeper-3.7.0
RUN set -x
RUN apt-get update
RUN apt-get install -y openjdk-8-jre-headless wget netcat-openbsd gnupg
RUN wget -q "http://downloads.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz"
RUN wget -q "https://downloads.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz.asc"
RUN export GNUPGHOME="$(mktemp -d)" 
RUN  gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" 
#RUN  gpg --batch --verify "apache-zookeeper-3.7.0-bin.tar.gz" "apache-zookeeper-3.7.0-bin.tar.gz.asc" # \
RUN    tar -xzf "apache-zookeeper-3.7.0-bin.tar.gz" -C /opt 
RUN    rm -r  "apache-zookeeper-3.7.0-bin.tar.gz" "apache-zookeeper-3.7.0-bin.tar.gz.asc" 
RUN    ln -s /opt/$ZK_DIST /opt/zookeeper 
RUN     rm -rf /opt/zookeeper/CHANGES.txt \
    /opt/zookeeper/README.txt \
    /opt/zookeeper/NOTICE.txt \
    /opt/zookeeper/CHANGES.txt \
    /opt/zookeeper/README_packaging.txt \
    /opt/zookeeper/build.xml \
    /opt/zookeeper/config \
    /opt/zookeeper/contrib \
    /opt/zookeeper/dist-maven \
    /opt/zookeeper/docs \
    /opt/zookeeper/ivy.xml \
    /opt/zookeeper/ivysettings.xml \
    /opt/zookeeper/recipes \
    /opt/zookeeper/src \
    /opt/zookeeper/$ZK_DIST.jar.asc \
    /opt/zookeeper/$ZK_DIST.jar.md5 \
    /opt/zookeeper/$ZK_DIST.jar.sha1 \
#	&& apt-get autoremove -y wget \
#	&& rm -rf /var/lib/apt/lists/*

#Copy configuration generator script to bin
COPY scripts /opt/zookeeper/bin/

# Create a user for the zookeeper process and configure file system ownership 
# for nessecary directories and symlink the distribution as a user executable
RUN set -x 
RUN useradd $ZK_USER 
RUN     [ `id -u $ZK_USER` -eq 1000 ]     && [ `id -g $ZK_USER` -eq 1000 ] 
RUN     mkdir -p $ZK_DATA_DIR $ZK_DATA_LOG_DIR $ZK_LOG_DIR /usr/share/zookeeper /tmp/zookeeper /usr/etc/ 
RUN	 chown -R "$ZK_USER:$ZK_USER" /opt/zookeeper $ZK_DATA_DIR $ZK_LOG_DIR $ZK_DATA_LOG_DIR /tmp/zookeeper 
RUN	 ln -s /opt/zookeeper/conf/ /usr/etc/zookeeper 
RUN	 ln -s /opt/zookeeper/bin/* /usr/bin 
RUN	 ln -s /opt/zookeeper/$ZK_DIST.jar /usr/share/zookeeper/ 
RUN	 ln -s /opt/zookeeper/lib/* /usr/share/zookeeper 
