FROM alpine as builder
ADD https://github.com/justinfrankel/ninjam/archive/refs/heads/master.zip /tmp/ninjam-master.zip
RUN apk add --no-cache unzip make libgcc g++ libstdc++ sed && \
    mkdir /usr/src && \
    cd /usr/src && \
    unzip /tmp/ninjam-master.zip && \
    cd /usr/src/ninjam-master/ninjam/server && \
    make && \
    cp /usr/src/ninjam-master/ninjam/server/example.cfg /tmp/ninjamsrv.cfg && \
    sed -i 's/deny/allow/g' /tmp/ninjamsrv.cfg && \
    sed -i 's/AnonymousUsers no/AnonymousUsers yes/g' /tmp/ninjamsrv.cfg

FROM alpine
COPY --from=builder /usr/src/ninjam-master/ninjam/server/ninjamsrv /opt/ninjam/bin/
COPY --from=builder /usr/src/ninjam-master/ninjam/server/example.cfg /usr/share/ninjam/
COPY --from=builder /usr/src/ninjam-master/ninjam/server/cclicense.txt /opt/ninjam/
COPY --from=builder /tmp/ninjamsrv.cfg /opt/ninjam/etc/ninjamsrv.cfg
COPY --from=builder /lib/libc.musl-x86_64.so.1 /lib/
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/
COPY --from=builder /usr/lib/libstdc++.so.6	/usr/lib/
EXPOSE 2049
WORKDIR /opt/ninjam
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ninjam/bin
RUN mkdir -p /opt/ninjam/var
ENTRYPOINT ["ninjamsrv"]
CMD ["/opt/ninjam/etc/ninjamsrv.cfg"]
