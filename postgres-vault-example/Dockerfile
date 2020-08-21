FROM docker.io/openjdk:11-jre-slim

COPY target/*.jar /deployments/app.jar

ENV SPRING_CONFIG_LOCATION=/deployments/config/application.properties

CMD ["java", "-jar", "/deployments/app.jar"]