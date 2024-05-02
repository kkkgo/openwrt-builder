FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
RUN git clone --depth=1 https://github.com/padavanonly/immortalwrt-mt798x /src
WORKDIR /src

RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
RUN cp /src/defconfig/mt7986-ax6000-mtwifi-cfg.config /src/.config
RUN make download -j4

ENV FORCE_UNSAFE_CONFIGURE=1

CMD bash