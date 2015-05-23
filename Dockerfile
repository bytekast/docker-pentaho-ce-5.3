FROM tutum/ubuntu:trusty

MAINTAINER Rowell Belen developer@bytekast.com

# Add a repo where Oracle JDK7 can be found.
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java

# Auto-accept the Oracle JDK license
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

RUN apt-get update
RUN apt-get install -y oracle-java7-installer

# Install maven
RUN apt-get update
RUN apt-get install -y maven

# Install supervisor
RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

# Install useful command line utilities
RUN apt-get -y install man vim sudo

# Install networking tools
RUN apt-get -y install net-tools dnsutils

# Install postgres
RUN apt-get -y install postgresql-9.3

# Install libraries and utilities
RUN apt-get install -y bash-completion
RUN apt-get install -y libwebkitgtk-1.0-0 libxtst6

# Add pentaho user
RUN useradd --create-home -s /bin/bash -G sudo pentaho
RUN sed -i.orig 's/%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
RUN cp -rvT /root /home/pentaho
RUN chown -Rv pentaho:pentaho /home/pentaho

# Setup Environment
RUN echo export JAVA_HOME=/usr/lib/jvm/java-7-oracle >>/etc/bash.bashrc
ADD psqlfix.sql /root/
RUN /etc/init.d/postgresql start && \
	sudo -u postgres psql </root/psqlfix.sql && rm /root/psqlfix.sql
ADD psqlfix.sh /root/
RUN sh /root/psqlfix.sh && rm /root/psqlfix.sh

# Download and extract pentaho BA Server binary
WORKDIR /home/pentaho/
RUN wget http://downloads.sourceforge.net/project/pentaho/Business%20Intelligence%20Server/5.3/biserver-ce-5.3.0.0-213.zip
RUN unzip biserver-ce-5.3.0.0-213.zip -d biserver-ce-5.3.0.0-213
RUN rm biserver-ce-5.3.0.0-213.zip

# Add/run script to load default tables
ADD loaddb.sh /home/pentaho/
RUN chmod +x /home/pentaho/loaddb.sh
RUN /etc/init.d/postgresql start && \
	printf 'password\n' | /home/pentaho/loaddb.sh

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add script to start biserver
ADD start.sh /home/pentaho/
RUN chmod +x /home/pentaho/start.sh

# Redirect Tomcat output
ENV CATALINA_OUT /dev/stdout

# Start Service
EXPOSE 8080 22 5432
CMD /home/pentaho/start.sh && /usr/bin/supervisord

