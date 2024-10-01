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
      }

      stage('Mutation Tests - PIT'){
        steps{
          sh "mvn -DwithHistory test-compile org.pitest:pitest-maven:mutationCoverage"
        }
      }

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
        withSonarQubeEnv('sonar') {
         sh "mvn clean verify sonar:sonar -Dsonar.projectKey=DevSecOps -Dsonar.projectName=DevSecOps"
        }
        timeout(time: 2, unit: 'MINUTES'){
        script{
         waitForQualityGate abortPipeline: true
        }
        }

      }
    }

    stage('vulnerability Scan - Docker'){
      steps{
            parallel(
        	      "Dependency Scan": {
        		        sh "mvn dependency-check:check"
			            },
			          "Trivy Scan":{
				            sh "bash trivy-docker-image-scan.sh"
			            },
			          "OPA Conftest":{
				            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
			          }   	
      	    )
          }
    }
  }



  post { 
        always { 
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
          // pitmutation mutationStatsFile: '**/target/pit-reports/**/index.html'
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
  }

}