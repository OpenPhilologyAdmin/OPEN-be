FROM ruby:3.1.2

ADD . /myapp
WORKDIR /myapp
RUN bundle install