FROM openjdk:11

RUN mkdir -p /usr/local/pegr/files

COPY resources/pegr_baseline.sql /usr/local/pegr/
COPY resources/pegr-config.properties /usr/local/pegr/
COPY resources/protocols /usr/local/pegr/files/protocols
WORKDIR /usr/local/pegr

RUN wget https://github.com/seqcode/pegr/releases/download/v0.3.0/pegr.war && \
    apt -y update && \
    apt -y install mariadb-server && \
    /etc/init.d/mariadb start && \ 
    mysql -e"CREATE DATABASE pegr CHARACTER SET utf8 COLLATE utf8_general_ci;" && \
    mysql -e"CREATE USER 'pegr'@'localhost' IDENTIFIED BY 'pegr';" && \
    mysql -e"GRANT ALL PRIVILEGES ON pegr.* TO 'pegr'@'localhost' with grant option;" && \
    mysql -e"FLUSH PRIVILEGES;" && \
    mysql -u pegr -ppegr pegr < pegr_baseline.sql

EXPOSE 8080

CMD /etc/init.d/mariadb start ; java -Dgrails.env=prod -server -noverify -Xshare:off -Xms1G -Xmx1G -XX:+UseParallelGC -Djava.net.preferIPv4Stack=true -XX:+EliminateLocks -XX:+UseBiasedLocking -XX:MaxJavaStackTraceDepth=100 -jar pegr.war