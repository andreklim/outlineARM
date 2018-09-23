# Copyright 2018 The Outline Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# See versions at https://hub.docker.com/_/node/
FROM debian

RUN dpkg --add-architecture armhf && apt-get update && apt-get install -y lsof curl gnupg gnupg2 gnupg1 git&& \
curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get update && apt-get install -y nodejs && \
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn libev-dev libc-ares-dev libsodium-dev libmbedtls-dev libpcre++-dev autoconf automake build-essential cmake && \
apt-get clean && rm -rf /var/lib/apt/lists/*


# Versions can be found at https://github.com/shadowsocks/shadowsocks-libev/releases
ARG SS_VERSION=3.2.0

# Save metadata on the software versions we are using.
LABEL shadowbox.node_version=8.11.3
LABEL shadowbox.shadowsocks_version="${SS_VERSION}"

ARG GITHUB_RELEASE
LABEL shadowbox.github.release="${GITHUB_RELEASE}"

# lsof for Shadowbox, curl for detecting our public IP.


COPY src/shadowbox/scripts scripts/
COPY src/shadowbox/scripts/update_mmdb.sh /etc/periodic/weekly/update_mmdb
RUN sh ./scripts/install_shadowsocks.sh $SS_VERSION
RUN /etc/periodic/weekly/update_mmdb


WORKDIR /root/shadowbox

COPY ./ ./




RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN yarn add -W phantomjs-prebuilt --phantomjs_cdnurl=https://bitbucket.org/ariya/phantomjs/downloads
RUN yarn add -W bower
RUN yarn add -W tsc

#RUN yarn install --prod 


#COPY src/shadowbox/package.json .
#COPY yarn.lock .

RUN yarn do shadowbox/server/build
#RUN mkdir /opt/shadow

#COPY ./ /opt/shadow


# Install management service
RUN cp -r build/shadowbox/app app/

# Create default state directory.
RUN mkdir -p /root/shadowbox/persisted-state

COPY src/shadowbox/docker/cmd.sh /


CMD /cmd.sh
