# Use a base image that includes the Java Runtime Environment (JRE)
FROM openjdk:17-jdk-alpine

# Use a multi-stage build with Maven as the build stage
FROM maven:3-openjdk-17 AS build

# Set the working directory within the container to /app
WORKDIR /app/java-backend

# Copy the application source code from the host's src directory to the container's /app/src directory
COPY src src

# Copy the project's POM (pom.xml) file to the current directory (/app)
COPY pom.xml .

# Build the application using Maven
RUN mvn package

# Specify the command to run your Java application when the container starts
CMD ["java", "-jar", "target/learners-api-1.0-SNAPSHOT.jar"]

