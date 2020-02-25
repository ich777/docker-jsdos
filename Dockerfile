FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends curl && \
	curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
	apt-get -y install --no-install-recommends nodejs && \
	rm -rf /var/lib/apt/lists/*

ENV SERVER_DIR=/jsdos
ENV APP_NAME="CivilisazionBI"
ENV ZIP_NAME="civ.zip"
ENV START_FILE="CIV.EXE"
ENV BGND_C="1f1f1f"
ENV FPS_C="true"
ENV DOSBOX_V="wdosbox-nosync"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="jsdos"

RUN mkdir $SERVER_DIR && \
	useradd -d $SERVER_DIR -s /bin/bash $USER && \
	chown -R $USER $SERVER_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]