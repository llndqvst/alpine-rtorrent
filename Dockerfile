FROM alpine

LABEL maintainer="Lukas Lindqvist" mail="lukas.lndqvst@gmail.com"
LABEL description="rTorrent on Alpine Linux, with a better Docker integration."
LABEL website="https://gitlab.com/llindqvist/alpine-rtorrent"
LABEL version="2.0"

ENV RTUID 2000
ENV RTGID 2000
ENV RTHOME /home/rtorrent

RUN addgroup \
    -S -g "$RTGID" \
    rtorrent && \
    adduser \
    -S -H -D \
    -h "$RTHOME" \
    -s /bin/bash \
    -u "$RTUID" \
    -G rtorrent \
    rtorrent && \
    mkdir -p "$RTHOME" && \
    chown -R rtorrent:rtorrent "$RTHOME"

# Install rtorrent and su-exec
# Create necessary folders
# Forward Info & Error logs to std{out,err} (à la nginx)

RUN apk add --no-cache \
      rtorrent \
      setpriv && \
      ln -sf /dev/stdout /var/log/rtorrent-info.log && \
      ln -sf /dev/stderr /var/log/rtorrent-error.log

COPY docker-entrypoint.sh /usr/local/bin/
COPY .rtorrent.rc /config/
COPY config.d /config/config.d

ENV RTBASE /
ENV RTSESSION /session
ENV RTWATCH /watch
ENV RTCONFIG /config
ENV RTDOWNLOAD /download

ENV RTDIRS "$RTSESSION $RTWATCH $RTDOWNLOAD"

RUN mkdir -p $RTDIRS && \
    chown -R rtorrent:rtorrent $RTDIRS

VOLUME ["/session", "/watch", "/config", "/download"]

EXPOSE 16891
EXPOSE 50000
EXPOSE 50000/udp

USER rtorrent

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["rtorrent", "-n", "-o", "import=/config/.rtorrent.rc"]
