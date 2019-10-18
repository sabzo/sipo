FROM ruby:2.6.4
MAINTAINER Sabelo Mhlambi
RUN apt-get update 

WORKDIR /app
ADD . /app

# Install gems
RUN bundle install 

