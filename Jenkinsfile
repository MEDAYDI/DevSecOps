pipeline {
  agent any
  tools { 
        maven 'Maven' 
    }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
      }   

      stage('Unit Tests - JUnit and JaCoCo'){
        steps{
          sh "mvn test"
        }
        post{
          always{
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
          }
        }
      }

      // stage('Mutation Tests - PIT'){
      //   steps{
      //     sh "mvn org.pitest:pitest-maven:mutationCoverage"
      //   }
      //   post{
      //     always {
      //       pitmutation mutationStatsFile: '**/target/pit-reports/**/index.html'
      //     }
      //   }
      // }

      // stage('Docker Build and Push'){
      //   steps{
      //     withDockerRegistry(credentialsId: 'DockerHub1', url: ''){
      //       sh 'docker build -t mohamedaydi/devsecops:1.0 .'
      //       sh 'docker push mohamedaydi/devsecops:1.0'
      //     }
      //   }
      // }

    stage('SonarQube Analysis') {
      steps{
        withSonarQubeEnv() {
         sh "mvn clean verify sonar:sonar -Dsonar.projectKey=DevSecOps -Dsonar.projectName=DevSecOps"
        }
        timeout(time: 2, unit: 'MINUTES'){
        script{
         waitForQualityGate: abortPipeline: true
        }
    }

      }
  }


  }

}