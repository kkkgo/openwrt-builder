FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
ENV FORCE_UNSAFE_CONFIGURE=1
COPY buildroot /src/
COPY make.sh /src/make.sh
COPY ax6.config /src/ax6.config
COPY 6088.config /src/6088.config
RUN bash make.sh
RUN if [ $(du -sm /src/dl | awk '{print $1}') -gt 1000 ]; then echo "Size check passed."; else cp /size_check_error /root/ && exit 1; fi
FROM soft
COPY --from=git /src /src
CMD bash