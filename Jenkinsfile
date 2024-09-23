pipeline {
  agent any
  tools { 
        mvn 'mvn' 
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

      stage('Mutation Tests - PIT'){
        steps{
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        post{
          always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
      }

      stage('Docker Build and Push'){
        steps{
          withDockerRegistry([credentialsId:"DockerHub",url: ""]){
            sh 'docker build -t mohamedaydi/DevSecOps:1.0'
            sh 'docker push mohamedaydi/DevSecOps:1.0'
          }
        }
      }


  }

}