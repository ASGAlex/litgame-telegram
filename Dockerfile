FROM google/dart:2.13-beta
WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline
RUN chmod +x bin/runserver.sh

#CMD [ "bin/runserver.sh" ]
ENTRYPOINT [ "bin/runserver.sh" ]