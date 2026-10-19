# Imagen corporativa objetivo (ARQT-SBOOT-001): acrmapfredevops.azurecr.io/mapfre/arch/ram/mapfre-java-base:21-jdk-alpine
# Fuera de la red MAPFRE se usa la base pública equivalente (eclipse-temurin) — ver README.
ARG BUILD_IMAGE=maven:3.9.11-eclipse-temurin-21-alpine
ARG RUNTIME_IMAGE=eclipse-temurin:21-jre-alpine
FROM ${BUILD_IMAGE} AS build
# MAVEN_MIRROR: Maven Central por defecto; en la red MAPFRE, Azure Artifacts (ver maven/settings.xml); fuera, cualquier mirror si Central limita (HTTP 429).
ARG MAVEN_MIRROR=https://repo.maven.apache.org/maven2
WORKDIR /workspace
RUN mkdir -p /root/.m2 && printf '<settings><mirrors><mirror><id>build-mirror</id><mirrorOf>central</mirrorOf><url>%s</url></mirror></mirrors></settings>' "$MAVEN_MIRROR" > /root/.m2/settings.xml
COPY sources/pom.xml .
RUN mvn -B -q -Dmaven.wagon.http.retryHandler.count=3 dependency:go-offline || true
COPY sources/src ./src
RUN mvn -B -q package -DskipTests

FROM ${RUNTIME_IMAGE}
RUN addgroup -S app && adduser -S app -G app
USER app
WORKDIR /app
COPY --from=build /workspace/target/pgm-bff-*.jar app.jar
ENV SPRING_PROFILES_ACTIVE=local SERVER_PORT=8080 JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s --retries=10 CMD wget -qO- http://localhost:8080/monitoring/health || exit 1
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
