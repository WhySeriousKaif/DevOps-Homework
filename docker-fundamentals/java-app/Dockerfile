FROM amazoncorretto:17-alpine
WORKDIR /app
COPY SimpleWebServer.java .
RUN javac SimpleWebServer.java
EXPOSE 8080
CMD ["java", "SimpleWebServer"]
