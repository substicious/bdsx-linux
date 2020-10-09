#################### DEVELOPMENT ####################
FROM alpine:latest as builder

# CONFIGURE SERVER
ENV SERVER_HOME="/mcpe" \
    SERVER_PATH="/mcpe/server" \
    SCRIPT_PATH="/mcpe/script" \
    DEFAULT_CONFIG_PATH="/mcpe/default-config" \
    DATA_PATH="/data" \
    BDS="/root/.bds"

RUN mkdir -p $SERVER_PATH && \
    mkdir -p $DATA_PATH/configs && \
    mkdir -p $DEFAULT_CONFIG_PATH

RUN apk add wget tar

RUN wget --progress=bar https://github.com/karikera/bdsx/releases/download/1.3.35/bdsx-1.3.35-linux.tar.gz && \
    cp bdsx-1.3.35-linux.tar.gz $SERVER_PATH

RUN tar -xzf $SERVER_PATH/bdsx-1.3.35-linux.tar.gz -C $SERVER_PATH && \
    rm -rf bdsx-1.3.35-linux.tar.gz $SERVER_PATH/bdsx-1.3.35-linux.tar.gz

RUN apk del wget tar

COPY ./configs $DEFAULT_CONFIG_PATH

COPY ./script $SCRIPT_PATH

#################### PRODUCTION ####################
FROM ubuntu:latest as production

# ARCH is only set to avoid repetition in Dockerfile since the binary download only supports amd64
ARG ARCH=amd64

# CONFIGURE TIMEZONE TO UTC
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar && \
    echo 'APT::Color "1";' > /etc/apt/apt.conf.d/99progressbar && \
    chmod 644 /etc/apt/apt.conf.d/99progressbar

# INSTALL PACKAGES
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    curl \
    libcurl4 \
    nano \
    nodejs \
    npm \
    screen \
    tar \
    unzip \
    wine && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# INSTALL NPM PACKAGES
RUN npm install dateformat fs -g   

# CONFIGURE SERVER
ENV SERVER_HOME="/mcpe" \
    SERVER_PATH="/mcpe/server" \
    SCRIPT_PATH="/mcpe/script" \
    DEFAULT_CONFIG_PATH="/mcpe/default-config" \
    DATA_PATH="/data" \
    BDS="/root/.bds"

VOLUME $DATA_PATH

COPY --from=builder $SERVER_HOME $SERVER_HOME

ARG EASY_ADD_VERSION=0.7.0
ADD https://github.com/itzg/easy-add/releases/download/${EASY_ADD_VERSION}/easy-add_linux_${ARCH} /usr/local/bin/easy-add
RUN chmod +x /usr/local/bin/easy-add

RUN chmod +x $SCRIPT_PATH/docker-entrypoint.sh

RUN mkdir -p $BDS 

RUN easy-add --var version=0.2.1 --var app=entrypoint-demoter --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

RUN easy-add --var version=0.1.1 --var app=set-property --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

RUN easy-add --var version=1.2.0 --var app=restify --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

RUN easy-add --var version=0.5.0 --var app=mc-monitor --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

WORKDIR $SERVER_PATH

EXPOSE  19132/udp \
        19133/udp 

EXPOSE  19132/tcp \
        19133/tcp \
        80/tcp
        
ENV VERSION=LATEST \
    SERVER_PORT=19132

HEALTHCHECK --start-period=1m CMD /usr/local/bin/mc-monitor status-bedrock --host 127.0.0.1 --port $SERVER_PORT

RUN chmod +X bdsx.sh

ENTRYPOINT $SCRIPT_PATH/docker-entrypoint.sh