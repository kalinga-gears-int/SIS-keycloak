FROM maven:3.6.0-jdk-11-slim AS build1
COPY SIS-keycloak/src /home/app/src
COPY SIS-keycloak/pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean install -DskipTests
RUN ls /home/app/src/main
FROM maven:3.6.0-jdk-11-slim AS build2
COPY /keycloak/services/. /home/app/services
RUN mvn -f /home/app/services/pom.xml clean install -DskipTests
FROM quay.io/keycloak/keycloak:15.0.2 AS keycloak
COPY --from=build1 /home/app/target/login-event-listener-1.0-SNAPSHOT.jar /opt/jboss/keycloak/standalone/deployments/
COPY --from=build2 /home/app/services/target/keycloak-services-15.0.2.jar /opt/jboss/keycloak/modules/system/layers/keycloak/org/keycloak/keycloak-services/main/
COPY SIS-keycloak/src/themes /opt/jboss/keycloak/themes
RUN sed -i "s,http://localhost:8089,http://10.0.0.11:8089,g" /opt/jboss/keycloak/themes/gears/login/theme.properties
