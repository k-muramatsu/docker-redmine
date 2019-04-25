FROM sameersbn/ubuntu:14.04.20150120
MAINTAINER k.muramatsu625@gmail.com

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y supervisor logrotate nginx mysql-client postgresql-client \
      imagemagick git cvs bzr mercurial rsync locales openssh-client \
      gcc g++ make patch pkg-config libc6-dev zlib1g-dev libxml2-dev \
      libmysqlclient18 libpq5 libyaml-0-2 libcurl3 libssl1.0.0 \
      libxslt1.1 libffi6 zlib1g gsfonts libcurl4-openssl-dev libyaml-dev unzip \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && rm -rf /var/lib/apt/lists/* # 20140918

#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 16126D3A3E5C1192 \
# && wget -q -O - http://opensource.wandisco.com/wandisco-debian.gpg | sudo apt-key add - \
# && sh -c 'echo "deb http://opensource.wandisco.com/debian/ jessie svn17" > /etc/apt/sources.list.d/wandisco-subversion17.list' \
# && sh -c 'echo "deb http://opensource.wandisco.com/debian/ jessie svn18" > /etc/apt/sources.list.d/wandisco-subversion18.list' \
# && apt-get update -y \
# && apt-get install -y subversion=1.7.18-1+WANdisco libsvn1=1.7.18-1+WANdisco libserf1 \
# && echo subversion hold | dpkg --set-selections \
# && echo libsvn1 hold | dpkg --set-selections \
# && echo libserf1 hold | sudo dpkg --set-selections

RUN wget http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz \
 && tar xvfz apr-1.5.2.tar.gz -C /tmp \
 && cd /tmp/apr-1.5.2 \
 && ./configure \
 && make \
 && make install

RUN wget http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz \
 && tar xvfz apr-util-1.5.4.tar.gz  -C /tmp \
 && cd /tmp/apr-util-1.5.4 \
 && ./configure --with-apr=/usr/local/apr \
 && make \
 && make install

RUN wget http://downloads.sourceforge.net/expat/expat-2.1.0.tar.gz \
 && tar xfvz expat-2.1.0.tar.gz -C /tmp \ 
 && cd /tmp/expat-2.1.0 \
 && ./configure --prefix=/usr/local/expat-2.1.0 \
 && make \
 && make install

RUN wget http://archive.apache.org/dist/subversion/subversion-1.6.23.tar.bz2 \
 && tar jxf subversion-1.6.23.tar.bz2 -C /tmp \
 && wget http://sqlite.org/2015/sqlite-amalgamation-3090000.zip \
 && unzip sqlite-amalgamation-3090000.zip -d /tmp \
 && mv /tmp/sqlite-amalgamation-3090000 /tmp/subversion-1.6.23/sqlite-amalgamation \
 && cd /tmp/subversion-1.6.23 \
 && export LD_LIBRARY_PATH=/usr/local/expat-2.1.0/lib/ \
 && ./configure --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr \
 && make \
 && make install

RUN wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p551.tar.gz -O - | tar -zxf - -C /tmp/ && \
    cd /tmp/ruby-1.9.3-p551/ && ./configure --enable-pthread --prefix=/usr && make && make install && \
    cd /tmp/ruby-1.9.3-p551/ext/openssl/ && ruby extconf.rb && make && make install && \
    cd /tmp/ruby-1.9.3-p551/ext/zlib && ruby extconf.rb && make && make install && cd /tmp && \
    rm -rf /tmp/ruby-1.9.3-p551 && gem install --no-ri --no-rdoc bundler

RUN wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz -O - | tar -zxf - -C /tmp/ && \
		cd /tmp && wget http://apolloron.org/software/libiconv-1.14-ja/libiconv-1.14-ja-2.patch && \
		cd /tmp/libiconv-1.14 && \
		patch -p1 < ../libiconv-1.14-ja-2.patch && ./configure && make && make install

RUN wget http://fallabs.com/qdbm/qdbm-1.8.78.tar.gz -O - | tar -zxf - -C /tmp/ && \
		cd /tmp/qdbm-1.8.78 && ./configure && make && make install

RUN wget http://fallabs.com/hyperestraier/hyperestraier-1.4.13.tar.gz -O - | tar -zxf - -C /tmp/ && \
		cd /tmp/hyperestraier-1.4.13 && ./configure && make && make install && cd rubynative/src && \
		wget http://sourceforge.net/p/hyperestraier/bugs/_discuss/thread/812557f7/9cf4/attachment/hyperestraier-ruby191.patch && \
		patch < ./hyperestraier-ruby191.patch && cd ../ && ./configure && make && make install

ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

ADD assets/config/ /app/setup/config/
ADD assets/init /app/init
RUN chmod 755 /app/init

EXPOSE 80
EXPOSE 443

VOLUME ["/home/redmine/data"]
VOLUME ["/var/log/redmine"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
