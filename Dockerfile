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
      imagemagick subversion git cvs bzr mercurial rsync locales openssh-client \
      gcc g++ make patch pkg-config libc6-dev zlib1g-dev libxml2-dev \
      libmysqlclient18 libpq5 libyaml-0-2 libcurl3 libssl1.0.0 \
      libxslt1.1 libffi6 zlib1g gsfonts libcurl4-openssl-dev \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && rm -rf /var/lib/apt/lists/* # 20140918

RUN wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p551.tar.gz -O - | tar -zxf - -C /tmp/ && \
    cd /tmp/ruby-1.9.3-p551/ && ./configure --enable-pthread --prefix=/usr && make && make install && \
    cd /tmp/ruby-1.9.3-p551/ext/openssl/ && ruby extconf.rb && make && make install && \
    cd /tmp/ruby-1.9.3-p551/ext/zlib && ruby extconf.rb && make && make install && cd /tmp \
    rm -rf /tmp/ruby-1.9.3-p551 && gem install --no-ri --no-rdoc bundler # mysql2

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
