FROM tomcat:7-jre8
ARG v_build
RUN wget -P /usr/local/tomcat/webapps http://172.20.20.31:8081/nexus/content/repositories/training/task4/$v_build/task4.war
EXPOSE 8080
