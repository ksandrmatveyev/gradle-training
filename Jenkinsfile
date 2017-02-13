#!groovy
def getVersion() {
        def propsString = readFile "gradle.properties"
        def props = new Properties()
        props.load(new StringReader(propsString))
        props.get("version")
    }
def vers
def depTom(inst,adr,pvers){
    withCredentials([usernamePassword(credentialsId: 'tomcat_cred', passwordVariable: 'TOMCAT_PASSWORD', usernameVariable: 'TOMCAT_USERNAME')]) {
        httpRequest httpMode: 'POST', url: "http://172.20.20.33/jkstatus/?cmd=update&from=list&w=loadbalancer&sw=${inst}&vwa=1"
        sh "curl \"http://172.20.20.32:8081/nexus/content/repositories/training/task3/${pvers}/task4.war\" | curl -T - -u $TOMCAT_USERNAME:$TOMCAT_PASSWORD \"http://${adr}:8080/manager/text/deploy?path=/testapp/task4&update=true\""
        sleep 60
        def pagecontent = sh(returnStdout: true, script: "curl -s http://${adr}:8080/testapp/task3/")
        echo "tomcat1=$pagecontent"
        if(pagecontent.contains(pvers)){
            echo "versions are the same"
            httpRequest httpMode: 'POST', url: "http://172.20.20.33/jkstatus/?cmd=update&from=list&w=loadbalancer&sw=${inst}&vwa=0"
        }
        else {
            echo "versions are different"
            currentBuild.result = 'FAILURE'
        }            
    }
}
node{
    deleteDir()
    stage('cloneRepo'){
        git branch: 'task4', credentialsId: 'github_cred', url: 'https://github.com/ksandrmatveyev/gradle-training.git'
    }
    stage('buildIncVersion'){
        sh('chmod +x gradlew && ./gradlew setBuildVersion && ./gradlew build')
    }
	vers = getVersion()
	println vers
	stage('pushChanges'){
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'github_cred', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD']]) {
            sh('git config --global user.name "Aleksandr Matveyev"')
            sh('git config --global user.email ksandr.matveyev@gmail.com')
            sh("git commit -am \"from Jenkins. Build - ${vers}\"")
            sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/ksandrmatveyev/gradle-training.git task4')
        }
    }
    stage('publishToNexus'){
        withCredentials([usernamePassword(credentialsId: 'nexus_cred', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
            dir('build/libs'){
                sh "curl -v -u $NEXUS_USERNAME:$NEXUS_PASSWORD --upload-file task4.war \"http://172.20.20.32:8081/nexus/content/repositories/training/task4/${vers}/task4.war\""
            }
        }    
    }
    stage('build_publish'){
        sh("docker build --build-arg v_build=${vers} -t task4 .")
        sh("docker tag task4 172.20.20.31:5000/task4:${vers}")
        sh("docker push 172.20.20.31:5000/task4")
        
    }
}
