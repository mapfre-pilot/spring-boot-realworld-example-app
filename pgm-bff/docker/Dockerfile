# Imagen corporativa objetivo (ARQT-SBOOT-001): acrmapfredevops.azurecr.io/mapfre/arch/ram/mapfre-java-base:21-jdk-alpine
# Fuera de la red MAPFRE se usa la base pública equivalente (eclipse-temurin) — ver README.
ARG BUILD_IMAGE=maven:3.9.11-eclipse-temurin-21-alpine
ARG RUNTIME_IMAGE=eclipse-temurin:21-jre-alpine
FROM ${BUILD_IMAGE} AS build
WORKDIR /workspace
COPY sources/pom.xml .
RUN mvn -B -q dependency:go-offline
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
