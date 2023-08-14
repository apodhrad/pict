#  ____        _ _     _           
# | __ ) _   _(_) | __| | ___ _ __ 
# |  _ \| | | | | |/ _` |/ _ \ '__|
# | |_) | |_| | | | (_| |  __/ |   
# |____/ \__,_|_|_|\__,_|\___|_|   
#                                  
FROM registry.access.redhat.com/ubi9/toolbox:9.2 as builder

RUN dnf install -y cmake g++ && \
    mkdir /tmp/pict

COPY ./ /tmp/pict/

RUN cd /tmp/pict/ && \
    cmake -DCMAKE_BUILD_TYPE=Release -S . -B build && \
    cmake --build build

# Following steps are used in ubi-micro

RUN dnf --installroot=/tmp/ubi-micro \
        --nodocs --setopt=install_weak_deps=False \
        install -y \
        g++ shadow-utils && \
    dnf --installroot=/tmp/ubi-micro \
        clean all

RUN cp /tmp/pict/build/cli/pict /tmp/ubi-micro/usr/local/bin/

#  __  __       _       
# |  \/  | __ _(_)_ __  
# | |\/| |/ _` | | '_ \ 
# | |  | | (_| | | | | |
# |_|  |_|\__,_|_|_| |_|
#
FROM registry.access.redhat.com/ubi9/ubi-micro:9.2

COPY --from=builder /tmp/ubi-micro/ /

VOLUME /var/pict

WORKDIR /var/pict

RUN useradd -M pict

USER pict

ENTRYPOINT ["pict"]
