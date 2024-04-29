FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/immortalwrt/immortalwrt.git /src
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
ENV FORCE_UNSAFE_CONFIGURE=1
COPY buildroot /src/
COPY patch.sh /src/patch.sh
RUN bash patch.sh
COPY ax6.config /src/.config
RUN make download -j4
RUN make -j4
COPY 6088.config /src/.config
RUN make download -j4
RUN make -j4
CMD bash