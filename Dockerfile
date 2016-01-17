FROM ubuntu:14.04
MAINTAINER Sabelo Mhlambi
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update
RUN apt-get install -y nginx git
# Install RVM
# install RVM, Ruby, and Bundler
# Install some dependencies
## Default Packages
RUN apt-get install -y -q ruby1.9.1 ruby1.9.1-dev build-essential
RUN sudo apt-get install curl -y

# Set up RVM (https://rvm.io/rvm/install) to manage Ruby versions
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.2"
RUN /bin/bash -l -c "rvm use 2.2.2 --default"
RUN /bin/bash -l -c "sudo gem install bundler --no-ri --no-rdoc"

# Install gems
RUN /bin/bash -l -c "gem install unicorn"
RUN /bin/bash -l -c "sudo gem install sinatra"
RUN /bin/bash -l -c "sudo gem install mongo"
RUN /bin/bash -l -c "sudo gem install sinatra-contrib"
RUN /bin/bash -l -c "sudo gem install bcrypt"
