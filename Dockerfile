FROM ruby:3.2.1

ADD . /myapp
WORKDIR /myapp
RUN bundle install
