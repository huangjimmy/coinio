
FROM cpsio/cpsbuild as builder

FROM ubuntu:16.04
LABEL version="0.1.1" \
  description="This is an cpsio/cps image"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/lib/* /usr/local/lib/
COPY --from=builder /opt/cps/bin /opt/cps/bin
COPY --from=builder /tmp/build/contracts /contracts
COPY --from=builder /coinio/Docker/config.ini /coinio/genesis.json /
COPY start_cpsd.sh /opt/cps/bin/start_cpsd.sh
RUN chmod +x /opt/cps/bin/start_cpsd.sh
ENV LD_LIBRARY_PATH /usr/local/lib
VOLUME /opt/cps/bin/data-dir
ENV PATH /opt/cps/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
