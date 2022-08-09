pipeline {
  agent any

  environment {
    imageName = "myapp"
    registryCredentials = "nexusid1"
    registry = "54.226.187.187:8083"
    dockerImage = ''
  }
  options {
    buildDiscarder logRotator(daysToKeepStr: '5', numToKeepStr: '7')
  }
  stages {
    stage('Build') {
      steps {
        sh script: 'mvn -f MyAwesomeApp/pom.xml clean package'
      }
    }

    stage('SonarQube analysis') {

      steps {

        withSonarQubeEnv('SonarQube') {
          sh "mvn sonar:sonar\
		      -Dsonar.java.coveragePlugin=jacoco \
                      -Dsonar.jacoco.reportPaths=target/jacoco.exec \
    		      -Dsonar.junit.reportsPaths=target/surefire-reports"
        }
      }
    }

    stage('Upload War To Repo') {
      steps {
        script {
          def mavenPom = readMavenPom file: 'MyAwesomeApp/pom.xml'
          def nexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "maven-snapshots" : "maven-releases"
          nexusArtifactUploader artifacts: [
              [artifactId: 'maven-project',
                classifier: '',
	        file: "MyAwesomeApp/target/springbootApp.jar",
                type: 'jar'
              ]
            ],
            credentialsId: 'nexusid1',
            groupId: 'com.example',
            nexusUrl: '54.226.187.187:8081',
            nexusVersion: 'nexus3',
            protocol: 'http',
            repository: nexusRepoName,
            version: "${mavenPom.version}"
        }
      }
    }	    


    stage('Build Docker image') {
      steps {
        script {
          dockerImage = docker.build(imageName)
        }
      }
    }
       stage('Upload Docker image into Repo')
        {
            steps
            {
                 script{
                       docker.withRegistry('http://'+registry, registryCredentials)
                           {
                           dockerImage.push("latest")
                            }
	                }   
	    }
            
         }
    stage('K8S Deploy') {
      steps {

        kubernetesDeploy(
          configs: 'springboot-lb.yaml',
          kubeconfigId: 'K8S',
          enableConfigSubstitution: true
        )
      }
    }

  }
}


