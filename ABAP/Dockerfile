FROM opensuse/leap:latest

LABEL de.itsfullofstars.sapnwdocker.version="1.0.0"
LABEL de.itsfullofstars.sapnwdocker.vendor="Tobias Hofmann"
LABEL de.itsfullofstars.sapnwdocker.name="Docker for SAP NetWeaver 7.5x Developer Edition"

RUN zypper --non-interactive install --replacefiles uuidd expert tcsh which vim hostname tar net-tools inputils libaio iproute2 net-tools-deprecated gzip; \
    zypper clean

RUN mkdir /run/uuidd && chown uuidd /var/run/uuidd && /usr/sbin/uuidd

COPY NW752 /var/tmp/NW752/

WORKDIR /var/tmp/NW752

RUN chmod +x install.sh

RUN echo $ '#!/usr/bin/expect -f \n\
spawn ./install.sh -s -k \n\
set PASSWORD "s@pABAP752" \n\ 
set timeout -1\n\
expect "youir distribution \'opensuse-leap\' was not tested. Do you want to continue?"\n\
send "yes\\r"\n\
expect "Do you agree to the above license terms? yes/no:"\n\
send "yes\\r"\n\
expect "Please enter a password:"\n\
send "$PASSWORD\\r"\n\
expect "Please re-enter password for verification:"\n\
send "$PASSWORD\\r"\n\
expect eof' >> ./run.sh; chmod +x ./run.sh

EXPOSE 8000
EXPOSE 44300
EXPOSE 3300
EXPOSE 3200

RUN ./run.sh

RUN rm -rf /var/tmp/NW752



