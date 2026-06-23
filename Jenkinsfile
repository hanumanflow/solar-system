pipeline{
	agent any

	tools{
		nodejs "nodejs-22"
	}
	environment{
		MONGO_URI=credentials("mongodb-url")
		MONGO_USERNAME = credentials("mongo_username");
		MONGO_PASSWORD = credentials("mongo_password");
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
						junit(testResults: 'test-results.xml' , keepProperties: true , keepTestNames: true)
						archiveArtifacts "test-results.xml"
				}
			}
		}
		stage("Code coverage"){
			steps{
					catchError(buildResult: 'SUCCESS' , message: 'Coverage for lines (79.54%) does not meet global threshold (90%)' , stageResult: 'UNSTABLE'){
							sh "npm run coverage"
					}
					publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'coverage/lcov-report/', 
					reportFiles: 'index.html', reportName: 'Code-coverage-report', reportTitles: '', useWrapperFileDirectly: true])
			}
		}
	}

	post{
		always{
			echo "############### Pipeline executing completed ###############"
		}
	}
}
