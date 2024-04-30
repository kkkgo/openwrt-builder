FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
RUN git clone --depth=1 https://github.com/immortalwrt/immortalwrt.git /src
WORKDIR /src
ENV FORCE_UNSAFE_CONFIGURE=1
COPY buildroot /src/
COPY make.sh /src/make.sh
COPY ax6.config /src/ax6.config
COPY 6088.config /src/6088.config
RUN bash make.sh
RUN cp /size_check_pass /root/
FROM soft
COPY --from=git /src /src
CMD bash