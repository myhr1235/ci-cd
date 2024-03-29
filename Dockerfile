FROM gradle:6.9.2-jdk11-alpine AS TEMP_BUILD_IMAGE
WORKDIR /home/gradle/src/

COPY --chown=gradle:gradle . /home/gradle/src
USER root
RUN chown -R gradle /home/gradle/src

COPY . .
RUN gradle clean bootJar



FROM openjdk:11-jre-slim
COPY --from=TEMP_BUILD_IMAGE $APP_HOME/build/libs/ROOT.jar  /application/ROOT.jar

WORKDIR /application

EXPOSE 8080

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.security.egd=file:/dev/./urandom","-jar","/application/ROOT.jar"]
