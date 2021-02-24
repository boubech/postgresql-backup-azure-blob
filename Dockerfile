FROM postgres:alpine
MAINTAINER Julien Boubechtoula <julien.boubechtoula@gmail.com>

RUN apk update && apk add curl tar libc6-compat 

# install go-cron
RUN apk add curl
RUN curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
RUN chmod u+x /usr/local/bin/go-cron

# install azcopy
RUN curl -L https://aka.ms/downloadazcopy-v10-linux > azcopy_v10.tar.gz
RUN tar -xf azcopy_v10.tar.gz --strip-components=1
RUN mv azcopy /usr/bin/azcopy
RUN chmod +x /usr/bin/azcopy && chown root:root /usr/bin/azcopy

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ADD backup.sh /backup.sh
RUN chmod +x /backup.sh

ADD purge.sh /purge.sh
RUN chmod +x /purge.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]