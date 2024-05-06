FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
RUN git clone --depth=1 https://github.com/qosmio/openwrt-ipq.git -b 5.15-qsdk11 /src
WORKDIR /src
COPY ax6.config /src/ax6.config
# COPY buildroot /src/
COPY make.sh /src/make.sh
ENV FORCE_UNSAFE_CONFIGURE=1
RUN bash make.sh
FROM soft
COPY --from=git /src /src
# COPY --from=git /data /data
WORKDIR /src
ENV FORCE_UNSAFE_CONFIGURE=1
CMD bash