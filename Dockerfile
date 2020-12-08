FROM google/dart:2.12-beta
WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

CMD [ "bin/server" ]
ENTRYPOINT [ "bin/runserver.sh" ]