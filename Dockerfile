FROM openjdk:11.0.11-jre-slim-buster
COPY build/libs/demo1-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]