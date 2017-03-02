#!groovy
def git_repo = "ksandrmatveyev/gradle-training.git"
def git_branch = "task4"
def nexus_repo = "172.20.20.31:8081/nexus/content/repositories"
def docker_reg = "172.20.20.31:5000"
def tomcat_cont = "172.20.20.35"
def getVersion() {
        def propsString = readFile "gradle.properties"
        def props = new Properties()
        props.load(new StringReader(propsString))
        props.get("version")
    }
def vers
def depTom(adr,pvers){
        def pagecontent = sh(returnStdout: true, script: "curl -s http://${adr}:8080/task4/")
        echo "container content is: $pagecontent"
        if(pagecontent.contains(pvers)){
            echo "versions are the same"
        }
        else {
            echo "versions are different"
            currentBuild.result = 'FAILURE'
        }
}
node('master'){
    deleteDir()
    stage('cloneRepo'){
        git branch: "${git_branch}", credentialsId: 'github_cred', url: "https://github.com/${git_repo}"
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
            sh("git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${git_repo} ${git_branch}")
        }
    }
    stage('publishToNexus'){
        withCredentials([usernamePassword(credentialsId: 'nexus_cred', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
            dir('build/libs'){
                sh "curl -v -u $NEXUS_USERNAME:$NEXUS_PASSWORD --upload-file task4.war \"http://${nexus_repo}/training/task4/${vers}/task4.war\""
            }
        }    
    }
    stage('build_publish'){
        pwd()
        sh("docker build --build-arg v_build=${vers} -t ${docker_reg}/task4:${vers} .")
        sh("docker push ${docker_reg}/task4:${vers}")
        
    }
}
