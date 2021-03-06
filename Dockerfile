# This is a Python 3.6 image that uses the nginx, gunicorn, flask stack
# for serving inferences in a stable way.

FROM ubuntu:18.04

LABEL maintainer="Amazon AI <sage-learner@amazon.com>"


RUN apt-get -y update && apt-get install -y --no-install-recommends \
        wget \
        python3.6-dev \
        python3-distutils \
        nginx \
        ca-certificates \
        && cd /usr/local/bin \
        && ln -s /usr/bin/python3.6 python \
        && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt

# Here we get all python packages.
# There's substantial overlap between scipy and numpy that we eliminate by
# linking them together. Likewise, pip leaves the install caches populated which uses
# a significant amount of space. These optimizations save a fair amount of space in the
# image, which reduces start up time.
RUN wget https://bootstrap.pypa.io/get-pip.py && \
        python get-pip.py && \
        pip install -r requirements.txt && \
        (cd /usr/local/lib/python3.6/dist-packages/scipy/.libs; rm *; ln ../../numpy/.libs/* .) && \
        rm -rf /root/.cache

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case.

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE