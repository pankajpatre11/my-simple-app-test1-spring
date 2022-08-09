FROM lolhens/baseimage-openjre
ADD MyAwesomeApp/target/springbootApp.jar springbootApp.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "springbootApp.jar"]
