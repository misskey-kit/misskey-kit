FROM public.ecr.aws/docker/library/node:20

RUN apt-get update && apt-get install tini --no-install-recommends -y && apt-get clean && rm -rf /var/lib/apt-get/lists/*

ARG enable_mecab=1
ARG AI_MISSKEY_TOKEN
ARG AI_MASTER
ARG AI_GEMINI_API_TOKEN

RUN cd / && git clone --depth 1 https://github.com/syuilo/ai.git

RUN if [ $enable_mecab -ne 0 ]; then apt-get update \
  && apt-get install mecab libmecab-dev mecab-ipadic-utf8 make curl xz-utils file sudo --no-install-recommends -y \
  && apt-get clean \
  && rm -rf /var/lib/apt-get/lists/* \
  && cd /opt \
  && git clone --depth 1 https://github.com/yokomotod/mecab-ipadic-neologd.git \
  && cd /opt/mecab-ipadic-neologd \
  && ./bin/install-mecab-ipadic-neologd -n -y \
  && rm -rf /opt/mecab-ipadic-neologd \
  && echo "dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd/" > /etc/mecabrc \
  && apt-get purge git make curl xz-utils file -y; fi

RUN apt-get update && apt-get install -y build-essential libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

WORKDIR /ai
RUN npm install && npm run build || test -f ./built/index.js

COPY entrypoint.sh /ai/entrypoint.sh

ENTRYPOINT /ai/entrypoint.sh