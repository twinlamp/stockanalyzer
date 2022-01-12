FROM ruby:2.4

ENV PHANTOM_JS="phantomjs-1.9.8-linux-x86_64"

# Install apt based dependencies required to run Rails as 
# well as RubyGems. As the Ruby image itself is based on a 
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs && \
  curl -L -O https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 && \
  tar xvjf $PHANTOM_JS.tar.bz2 && \
  mv $PHANTOM_JS /usr/local/share && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin && \
  mkdir -p /root/.phantomjs/2.1.1/x86_64-linux/bin && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /root/.phantomjs/2.1.1/x86_64-linux/bin/phantomjs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install npm -y

# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
RUN mkdir -p /stockanalyzer
WORKDIR /stockanalyzer

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY Gemfile Gemfile.lock ./ 
RUN bundle update
RUN gem install google-api-client
# Copy the main application.
COPY . ./

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]