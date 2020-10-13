ARG BUILD_NUMBER 
ARG BUILD_DATE

FROM chemaxon/chemlocator-java:$BUILD_NUMBER

ARG BUILD_NUMBER
ARG BUILD_DATE

RUN mkdir /tmp/gocr; \
    mkdir /tmp/OSRA;
    
COPY gocr-0.50pre-patched.tgz /tmp/gocr/gocr-0.50pre-patched.tgz
COPY osra-2.1.1.tgz /tmp/OSRA/osra-2.1.1.tgz

RUN echo "7f067f4c6e8323f1d7c383eace1637e6f2950d5e /tmp/gocr/gocr-0.50pre-patched.tgz" | sha1sum -c -
RUN echo "47d3876545b71ac45731a58de061fde063f0dde7  /tmp/OSRA/osra-2.1.1.tgz" | sha1sum -c -
    
RUN apt-get update \
    && apt-get install -y \
        g++ \
        make \
        graphicsmagick \
        graphicsmagick-libmagick-dev-compat \
        potrace \
        libpotrace-dev \
        ocrad \
        libocrad-dev\ 
        libtclap-dev \
        poppler-utils \
        libpoppler-dev \
        libpoppler-cpp-dev \
        openbabel \
        libopenbabel-dev \
        tesseract-ocr \
        libtesseract-dev

RUN cd /tmp/gocr \
    && tar -zxvf gocr-0.50pre-patched.tgz \
    && cd /tmp/gocr/gocr-0.50pre-patched \
    && ./configure \
    && make libs\
    && make install

RUN cd /tmp/OSRA \
    && tar -zxvf osra-2.1.1.tgz \
    && cd /tmp/OSRA/osra-2.1.1 \
    && ./configure --with-tesseract --with-potrace-lib --with-openbabel-include="/usr/include/openbabel3" --with-openbabel-lib="/usr/lib/openbabel/3.0.0"\
    && make all \
    && make install
    
RUN cd && rm -rf /tmp/OSRA && rm -rf /tmp/gocr
RUN cp -rs /usr/lib/openbabel/3.0.0/* /usr/local/bin
RUN cp -rs /usr/lib/GraphicsMagick-1.3.35/config/* /usr/local/bin

LABEL com.chemaxon.version=$BUILD_NUMBER \
      com.chemaxon.date=$BUILD_DATE \
      com.chemaxon.application="chemlocator" \
      com.chemaxon.application.service="chemlocator-java-osra" \
      maintainer="chemlocator-support@chemaxon.com" 

WORKDIR /app
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD ["/app/start.sh"]
