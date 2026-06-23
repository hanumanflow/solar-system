pipeline{
	agent any

	tools{
		nodejs "nodejs-22"
	}
	environment{
		MONGO_URI=credentials("mongodb-url")
		MONGO_USERNAME = credentials("mongo_username");
		MONGO_PASSWORD = credentials("mongo_password");
		SONAR_SCANNER_HOME = tool 'sonarqube-scanner-81';
		SONAR_TOKEN = '0b85227e58a1466dbe9022b06f4d6441e2193b7d'
	}
	stages{
		stage("Checkout repo"){
			steps{
			   checkout scm
			}
		}
		stage("Install dependencies"){

			options{
				timestamps()
			}

			steps{
				sh 'npm install --no-audit'
			}
		}
		stage("Dependencies Scanning stage"){
			parallel {
				stage("Dependencies Audit"){
					steps{
						sh 'npm audit --audit-level=critical'
					}
				}
				// stage("OWASP dependency check"){
				// 	steps{
				// 		dependencyCheck additionalArguments: '''
				// 						-- scan \'./\'
				// 						-- out \'./ \'
				// 						-- format \'ALL\'
				// 						-- prettyPrint''', odcInstallation: 'OWASP-depCheck-10'

				// 	}
				// }
			}
		}
		stage("Testing stage"){

			options{
				retry(2)
			}

			steps{
				script{					
						sh "npm test"
				}
			}
		}
		stage("Code coverage"){
			steps{
					catchError(buildResult: 'SUCCESS' , message: 'ISSUE:: Coverage for lines does not meet global threshold (90%)' , stageResult: 'UNSTABLE'){
							sh "npm run coverage"
					}
			}
		}

		stage("Sonar security scan stage"){

			steps{
				sh """
					${SONAR_SCANNER_HOME}/bin/sonar-scanner \
               			 -Dsonar.projectKey=hanumanflow_solar-system \
               			 -Dsonar.organization=hanumanflow \
                		 -Dsonar.sources=. \
                		 -Dsonar.host.url=https://sonarcloud.io
						 -Dsonar.login=0b85227e58a1466dbe9022b06f4d6441e2193b7d
				"""
			}
		}
	}

	post{
		always{
			echo "Executing post stage steps"
			junit(testResults: 'test-results.xml' , keepProperties: true , keepTestNames: true)		
			archiveArtifacts 'coverage/cobertura-coverage.xml'
			archiveArtifacts "test-results.xml"
			publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'coverage/lcov-report/', 
						reportFiles: 'index.html', reportName: 'Code-coverage-report', reportTitles: '', useWrapperFileDirectly: true])

		}
	}
}
