FROM gradle:alpine

USER root
RUN apk update \                                                                                                                                                                                                                        
  && apk add ca-certificates wget openssl expect \
  && update-ca-certificates \
  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://developer.android.com/studio/releases/sdk-tools.html

ENV SDK_VERSION 26.0.1
ENV TOOLS_VERSION 25.2.5
ENV PLATFORM_VERSION 25
ENV ANDROID_HOME /opt

COPY tools /opt/tools
RUN cd /opt && wget -O android-sdk.zip https://dl.google.com/android/repository/tools_r${TOOLS_VERSION}-linux.zip \
 && unzip android-sdk.zip \
 && rm -f android-sdk.zip 

RUN cd /opt \
 && yes | tools/bin/sdkmanager "tools" "platforms;android-${PLATFORM_VERSION}"

USER gradle
ENV ANDROID_HOME /opt
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}
RUN echo "no" | android create avd \
                --force \
                --device "Nexus 5" \
                --name test \
                --target android-21 \
                --abi armeabi-v7a \
                --skin WVGA800 \
                --sdcard 512M

CMD ["gradle", "installDebug"]
