FROM alpine:latest AS builder
RUN apk add --no-cache python3 python3-dev gcc g++ make libffi-dev openssl-dev git && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install pycrypto && \
    rm -r /root/.cache
WORKDIR /opt
RUN git clone https://github.com/opensvc/opensvc.git
WORKDIR opensvc
RUN VERSION=$(git describe --tags --abbrev=0) && \
    RELEASE=$(git describe --tags|cut -d- -f2) && \
    echo "version = \"$VERSION-$RELEASE\"" | tee /opt/opensvc/lib/version.py
RUN rm -rf .git* .codecov* .travis* *.cmd test*

FROM alpine:latest
ENV ADDR=${ADDR:-0.0.0.0}
ENV PORT=${PORT:-1214}
RUN apk add --no-cache python3 && ln -sf /usr/bin/python3 /usr/bin/python
COPY --from=builder /usr/lib/python3.6/site-packages/Crypto /usr/lib/python3.6/site-packages/Crypto
COPY --from=builder /usr/lib/python3.6/site-packages/pycrypto-2.6.1-py3.6.egg-info /usr/lib/python3.6/site-packages/pycrypto-2.6.1-py3.6.egg-info
RUN echo -e "OSVC_ROOT_PATH=/opt/opensvc\\nOSVC_PYTHON=/usr/bin/python" > /etc/conf.d/opensvc
COPY --from=builder /opt/opensvc /opt/opensvc
RUN /usr/bin/python /opt/opensvc/bin/postinstall
ENV PATH /opt/opensvc/bin:$PATH
EXPOSE ${PORT}/tcp
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["relay"]
