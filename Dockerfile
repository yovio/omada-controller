FROM ubuntu:18.04
MAINTAINER Yovi Oktofianus <yovio@hotmail.com>

ARG OMADA_SOURCE=https://static.tp-link.com/2020/202007/20200720/Omada_SDN_Controller_v4.1.5_linux_x64.tar.gz
                 
                 
# install runtime dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update &&\
  apt-get install -y libcap-dev net-tools curl tar tzdata &&\
  rm -rf /var/lib/apt/lists/* && \
  ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata

# install omada controller (instructions taken from install.sh); then create a user & group and set the appropriate file system permissions
RUN cd /tmp &&\
  curl $OMADA_SOURCE -o omada.tar.gz &&\
  tar -xvzf omada.tar.gz &&\  
  rm /tmp/omada.tar.gz &&\
  cd Omada* &&\    
  mkdir /opt/tplink/EAPController -vp &&\
  cp bin /opt/tplink/EAPController -r &&\
  cp data /opt/tplink/EAPController -r &&\
  cp properties /opt/tplink/EAPController -r &&\
  cp webapps /opt/tplink/EAPController -r &&\
  cp keystore /opt/tplink/EAPController -r &&\
  cp lib /opt/tplink/EAPController -r &&\
  cp install.sh /opt/tplink/EAPController -r &&\
  cp uninstall.sh /opt/tplink/EAPController -r &&\
  cp jre /opt/tplink/EAPController/jre -r &&\
  chmod 755 /opt/tplink/EAPController/bin/* &&\
  chmod 755 /opt/tplink/EAPController/jre/bin/* &&\
  cd /tmp &&\
  rm -rf /tmp/Omada* &&\
  groupadd -g 508 omada &&\
  useradd -u 508 -g 508 -d /opt/tplink/EAPController omada &&\
  mkdir /opt/tplink/EAPController/logs /opt/tplink/EAPController/work &&\
  chown -R omada:omada /opt/tplink/EAPController/data /opt/tplink/EAPController/logs /opt/tplink/EAPController/work

USER omada
WORKDIR /opt/tplink/EAPController
EXPOSE 8088 8043
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
CMD ["/opt/tplink/EAPController/jre/bin/java","-server","-Xms128m","-Xmx1024m","-XX:MaxHeapFreeRatio=60","-XX:MinHeapFreeRatio=30","-XX:+HeapDumpOnOutOfMemoryError","-XX:-UsePerfData","-Deap.home=/opt/tplink/EAPController","-cp","/opt/tplink/EAPController/lib/*:","com.tp_link.eap.start.EapLinuxMain"]
