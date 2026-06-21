pipeline{
	agent any

	tools{
		nodejs "nodejs-22"
	}
	environment{
		// PROJECT_NAME = "Solar system"
		MONGO_URI="mongodb+srv://superuser:SuperPassword@supercluster.d83jj.mongodb.net/superData"
		// MONGO_USERNAME="superuser"
		// MONGO_PASSWORD="SuperPassword"

	}
	stages{
		stage("Checkout repo"){
			steps{
				// echo "${PROJECT_NAME}"
			   checkout scm
			}
		}
		stage("Install dependencies"){
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
			steps{
				script{
					withCredentials([usernamePassword(credentialsId: 'mongo-db-credentials' , usernameVariable: 'MONGO_USERNAME' ,
														passwordVariable: 'MONGO_PASSWORD')]){
						sh "npm test"
					}
					junit(testResults: 'test-results.xml' , keepProperties: true , keepTestNames: true)
					archiveArtifacts "test-results.xml"
				}
			}
		}
		
	}
}
