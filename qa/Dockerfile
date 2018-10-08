FROM ruby:2.5.1

RUN set -ex \
  \
  && buildDeps=' \
    apt-transport-https \
    gnupg \
    wget \
  ' \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $buildDeps \
  \
  # Set up the Chrome PPA \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
  \
  && apt-get update \
  && apt-get install -y \
    google-chrome-stable \
    libnss3 \
    tzdata \
    unzip \
    xvfb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && ln -s /usr/bin/google-chrome /usr/bin/chrome

# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_VERSION 2.42

# Download and install Chromedriver
RUN set -ex \
  && curl -s -L -O "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
  && unzip chromedriver_linux64.zip -d /usr/local/bin \
  && rm -f chromedriver_linux64.zip.zip

RUN mkdir -p /app
WORKDIR /app

USER nobody
