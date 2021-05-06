FROM docker.io/openjdk:11-jre

COPY target/*.jar /deployments/app.jar

ENV SPRING_CONFIG_LOCATION=/deployments/config/application.properties

RUN chown :0 -R /deployments && \
    chmod g+rx -R /deployments

CMD ["java", "-jar", "/deployments/app.jar"]
