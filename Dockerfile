FROM ruby:2.3-slim

MAINTAINER developers@forward3d.com

# Install and bundle
WORKDIR /opt/frugal
COPY Gemfile /opt/frugal/Gemfile
COPY Gemfile.lock /opt/frugal/Gemfile.lock
RUN /opt/ruby/bin/bundle install
COPY . /opt/frugal

# Entrypoint is to run the frugal binary
ENTRYPOINT ["/usr/local/bin/ruby", "/opt/frugal/bin/check"]
