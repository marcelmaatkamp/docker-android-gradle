FROM gradle:alpine

USER root
ENV ANDROID_HOME /opt/android-sdk

RUN apk update \                                                                                                                                                                                                                        
  && apk add ca-certificates wget openssl expect \
  && update-ca-certificates \
  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir ${ANDROID_HOME} && chown gradle:gradle ${ANDROID_HOME}

# https://developer.android.com/studio/releases/sdk-tools.html
ENV SDK_VERSION 26.0.1
ENV TOOLS_VERSION 25.2.5
ENV PLATFORM_VERSION 25

COPY tools ${ANDROID_HOME}/tools
RUN cd ${ANDROID_HOME} && wget -O android-sdk.zip https://dl.google.com/android/repository/tools_r${TOOLS_VERSION}-linux.zip \
 && unzip android-sdk.zip \
 && rm -f android-sdk.zip 

RUN cd ${ANDROID_HOME} \
 && yes | tools/bin/sdkmanager "tools" "platforms;android-${PLATFORM_VERSION}"

# RUN echo "no" | android create avd \
#  --force \
#  --device "Nexus 5" \
#  --name test \
#  --target android-21 \
#  --abi armeabi-v7a \
#  --skin WVGA800 \
#  --sdcard 512M

USER gradle
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

CMD ["gradle", "installDebug"]
