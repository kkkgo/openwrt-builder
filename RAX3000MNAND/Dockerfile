FROM sliamb/opbuilder:6088
COPY .config /src/.config
COPY make.sh /src/make.sh
WORKDIR /src
RUN sh /src/make.sh
CMD bash