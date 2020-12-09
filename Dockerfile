FROM google/dart:2.12-beta
WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline
RUN chmod +x bin/runserver.sh
RUN chmod +x bin/runserver-heroku.sh

#CMD [ "bin/runserver.sh" ]
ENTRYPOINT [ "bin/runserver.sh" ]