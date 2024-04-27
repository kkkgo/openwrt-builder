FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/padavanonly/immortalwrt-mt798x.git /src
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
COPY .config .config
ENV FORCE_UNSAFE_CONFIGURE=1
RUN make download

FROM git
WORKDIR /src
COPY build.sh /src/build.sh
COPY buildroot /src/
RUN make -j4 V=s
CMD bash /src/build.sh