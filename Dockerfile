#Stage 1
# initialize build and set base image for first stage
FROM maven:3.6.3-adoptopenjdk-11 as stage1
# speed up Maven JVM a bit
#ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
# set working directory
WORKDIR /opt/demo
# copy just pom.xml
COPY pom.xml .
# go-offline using the pom.xml
RUN mvn dependency:go-offline
# copy your other files
COPY ./src ./src
# compile the source code and package it in a jar file
RUN mvn clean install -Dmaven.test.skip=true
#Stage 2
# set base image for second stage
FROM adoptopenjdk/openjdk11:jre-11.0.9_11-alpine
# Install necessary packages
RUN apk --no-cache add shadow
# Create a custom user with UID 1234 and GID 1234
RUN groupadd -r user && \
    useradd -r -g user user
# Set the working directory to /app
WORKDIR /app
# Change the ownership of the working directory to the non-root user "user"
RUN chown -R user:user /app
# Switch to the non-root user "user"
USER user
EXPOSE 8080
# copy over the built artifact from the maven image
COPY --from=stage1 /opt/demo/target/*.jar /app/app.jar

ENTRYPOINT ["java","-jar","/app.jar"]