# Build stage
FROM gradle:6.9.4-jdk11 AS builder
WORKDIR /home/gradle/src

# Copy only necessary files for the build
COPY --chown=gradle:gradle ./src /home/gradle/src/src
COPY --chown=gradle:gradle ./build.gradle /home/gradle/src
COPY --chown=gradle:gradle ./settings.gradle /home/gradle/src

RUN gradle clean build --exclude-task test --exclude-task asciidoctor -Dorg.gradle.jvmargs="-Xmx1300m"

# Runtime stage
FROM openjdk:11-jdk-slim

RUN apt-get update && apt-get install -y python3 python3-pip && \
    pip3 install awscli

ENV APPLICATION_USER emoldino
ENV APP_NAME mms-1.0.0

LABEL description="eMoldino"

# Create the necessary directories
RUN mkdir -p /$APPLICATION_USER/config /$APPLICATION_USER/logs /$APPLICATION_USER/upload

WORKDIR /$APPLICATION_USER

COPY --from=builder /home/gradle/src/build/libs/$APP_NAME.jar /$APPLICATION_USER/$APP_NAME.jar
COPY ./run.sh run.sh
RUN chmod +x run.sh

ENTRYPOINT ["./run.sh"]

EXPOSE 80 443
