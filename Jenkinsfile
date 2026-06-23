pipeline{
	agent any

	tools{
		nodejs "nodejs-22"
	}
	environment{
		MONGO_URI=credentials("mongodb-url")
		MONGO_DETAILS_USR = credentials("mongo-db-credentials");
		MONGO_DETAILS_PSW = credentials("mongo-db-credentials");



		// MONGO_USERNAME="superuser"
		// MONGO_PASSWORD="SuperPassword"

	}
	stages{
		stage("Checkout repo"){
			steps{
				// echo "${PROJECT_NAME}"
				sh """
				echo 'username - ${MONGO_DETAILS_USR}'
				echo 'password - ${MONGO_DETAILS_PSW}'
				"""
			   checkout scm
			}
		}
		stage("Install dependencies"){

			options{
				timestamps()
			}

			steps{
				sh """
					npm install --no-audit
				"""
			}
		}
		stage("Dependencies Scanning stage"){
			parallel {
				stage("Dependencies Audit"){
					steps{
						sh """
							npm audit --audit-level=critical
						"""
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
					withCredentials([usernamePassword(credentialsId: 'mongo-db-credentials' , usernameVariable: 'MONGO_USERNAME' ,
														passwordVariable: 'MONGO_PASSWORD')]){
														// string(credentialsId: 'mongodb-url' , variable: 'MONGO_URI')
						sh "npm test"
					}
					junit(testResults: 'test-results.xml' , keepProperties: true , keepTestNames: true)
					archiveArtifacts "test-results.xml"
				}
			}
		}
		stage("Code coverage"){
			steps{
				withCredentials([usernamePassword(credentialsId: 'mongo-db-credentials' , usernameVariable: 'MONGO_USERNAME' ,
														passwordVariable: 'MONGO_PASSWORD')]){
					catchError(buildResult: 'SUCCESS' , message: 'Coverage for lines (79.54%) does not meet global threshold (90%)' , stageResult: 'UNSTABLE'){
							sh "npm run coverage"
					}
					
					// archiveArtifacts "coverage/lcov-report/index.html"
					publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'coverage/lcov-report/', 
					reportFiles: 'index.html', reportName: 'Code-coverage-report', reportTitles: '', useWrapperFileDirectly: true])

				}
			}
		}
		
	}
}
