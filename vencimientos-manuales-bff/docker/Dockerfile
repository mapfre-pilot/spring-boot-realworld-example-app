ARG BASE_IMAGE=acrmapfredevops.azurecr.io/mapfre/arch/ram/mapfre-java-base:21-jre-alpine
ARG MAVEN_CENTRAL_MIRROR=
FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
ARG MAVEN_CENTRAL_MIRROR
COPY sources/pom.xml .
COPY sources/.mvn .mvn
COPY sources/mvnw .
COPY sources/src src
RUN chmod +x mvnw && if [ -n "$MAVEN_CENTRAL_MIRROR" ]; then \
      printf '<settings><mirrors><mirror><id>central-mirror</id><mirrorOf>central</mirrorOf><url>%s</url></mirror></mirrors></settings>' "$MAVEN_CENTRAL_MIRROR" > /tmp/maven-settings.xml && \
      ./mvnw -s /tmp/maven-settings.xml -B -DskipTests package; \
    else \
      ./mvnw -B -DskipTests package; \
    fi

ARG BASE_IMAGE
FROM ${BASE_IMAGE}
WORKDIR /app
COPY --from=build /app/target/vencimientos-manuales-bff.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
