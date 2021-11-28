# app
FROM devhub-docker.cisco.com/iox-docker/ir800/base-rootfs
RUN opkg update
RUN opkg install coreutils
RUN (opkg install tzdata ; exit 0) && \
	cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY build/bin/sysbench /bin/
COPY build/share/sysbench /usr/share/sysbench
COPY build/lib /lib
COPY benchmark.sh /bin/
COPY init_benchmark.sh /etc/init.d/
RUN chmod 755 /etc/init.d/init_benchmark.sh && \
	update-rc.d init_benchmark.sh defaults

