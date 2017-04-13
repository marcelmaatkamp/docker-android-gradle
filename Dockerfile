FROM gradle:alpine

USER root
RUN apk update \                                                                                                                                                                                                                        
  && apk add ca-certificates wget openssl expect \
  && update-ca-certificates \
  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV ANDROID_VERSION 25.2.3

COPY tools /opt/tools
RUN cd /opt && wget -q -O android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_VERSION}-linux.zip && \
  unzip android-sdk.zip && \
  rm -f android-sdk.zip 

RUN \
  /opt/tools/android-accept-licenses.sh "/opt/tools/android update sdk --all --no-ui --filter platform-tools,tools" 
RUN \
  /opt/tools/android-accept-licenses.sh "/opt/tools/android update sdk --all --force --no-ui --filter platform-tools,tools,build-tools-21.0.0,build-tools-21.0.1,build-tools-21.0.2,build-tools-21.1,build-tools-21.1.1,build-tools-21.1.2,build-tools-22.0.0,build-tools-22.0.1,android-21,android-22,addon-google_apis_x86-google-21,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-android-21"

# Setup environment
USER gradle
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN which adb
RUN which android

# Create emulator
RUN echo "no" | android create avd \
                --force \
                --device "Nexus 5" \
                --name test \
                --target android-21 \
                --abi armeabi-v7a \
                --skin WVGA800 \
                --sdcard 512M

CMD ["gradle", "installDebug"]
