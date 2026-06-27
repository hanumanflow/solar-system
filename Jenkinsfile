pipeline{
	agent any

	tools{
		nodejs "nodejs-22"
	}
	environment{
		MONGO_URI=credentials("mongodb-url")
		MONGO_USERNAME = credentials("mongo_username");
		MONGO_PASSWORD = credentials("mongo_password");
		// SONAR_SCANNER_HOME = tool 'sonarqube-scanner-81';
		// SONAR_TOKEN = '5463f33c30a324dc43ec7a3d4db9a533eb418eb1'
		DOCKER_IMAGE = 'chowdary2001/solar-system:latest' 
		DOCKER_CONTAINER = "solar-system-container"
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
				retry(1)
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

		// stage("Sonar security scan stage"){

		// 	environment{
		// 		SONAR_SCANNER_OPTS = "-Xmx512m"
		// 		// NODE_OPTIONS = "--max-old-space-size=500"
		// 	}

		// 	steps{
		// 		sh """
		// 			${SONAR_SCANNER_HOME}/bin/sonar-scanner \
        //        			 -Dsonar.projectKey=hanumanflow_solar-system \
        //        			 -Dsonar.organization=hanumanflow \
        //         		 -Dsonar.sources=app.js \
        //         		 -Dsonar.host.url=https://sonarcloud.io \
		// 				 -Dsonar.login=5463f33c30a324dc43ec7a3d4db9a533eb418eb1 \
		// 				 -Dsonar.exclusions=node_modules/**,coverage/** \
		// 				 -Dsonar.javascript.node.maxspace=512 \
		 				//  -Dsonar.token=${SONAR_TOKEN} \

		// 		"""
		// 	}
		// }

		stage("Docker image build stage"){
			steps{
				sh 'docker build -t $DOCKER_IMAGE .'
			}
		}
		stage("trivy image scan stage"){
			steps{
				sh """

					trivy image $DOCKER_IMAGE \
					--severity LOW,MEDIUM,HIGH \
					--exit-code 0 \
					--quiet \
					--format json -o trivy-image-MEDIUM-results.json
				"""
				sh """
				trivy image $DOCKER_IMAGE \
					--severity CRITICAL \
					--exit-code 1 \
					--quiet \
					--format json -o trivy-image-CRITICAL-results.json
				"""
			}

		}

		stage("Push image to registry"){
			steps{
				withDockerRegistry(credentialsId: 'docker-credentials' , url:''){
					sh "docker push $DOCKER_IMAGE"
				}
			}
		}

		stage("Deploy - AWS EC2"){
			steps{
				script{
					sshagent(['aws-deploy-instance-key']){
						sh '''
							ssh  -o StrictHostKeyChecking=no ubuntu@172.31.34.250 "
								
								if sudo docker ps -a | grep -w "$DOCKER_CONTAINER" ; then
									echo "Found $DOCKER_CONTAINER stopping and removing"
									docker container stop "$DOCKER_CONTAINER" && docker rm "$DOCKER_CONTAINER"
									echo "Starting the container"
								fi
								 docker run -d --name $DOCKER_CONTAINER \
						               -p  3001:3000 \
						               -e  MONGO_URI=$MONGO_URI \
						               -e  MONGO_USERNAME=$MONGO_USERNAME \
						               -e  MONGO_PASSWORD=$MONGO_PASSWORD \
						               $DOCKER_IMAGE
						        
								docker ps
							"
						'''
					}
				}
			}
		}
	}

	
	post{
		always{
			// junit(testResults: '')
			// echo "POST steps -> after new volume"
			junit(testResults: 'test-results.xml' , keepProperties: true , keepTestNames: true)		
			// archiveArtifacts 'coverage/cobertura-coverage.xml'
			// archiveArtifacts "test-results.xml"
			// publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'coverage/lcov-report/', 
					// reportFiles: 'index.html', reportName: 'Code-coverage-report', reportTitles: '', useWrapperFileDirectly: true])
			// publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './' ,
			// 		 reportFiles: 'welcome.html', reportName: 'welcome', reportTitles: '', useWrapperFileDirectly: true])

					 sh '''
						trivy convert \
						--format template --template "@/usr/local/share/trivy/templates/html.tpl" \
						--output trivy-image-MEDIUM-results.html trivy-image-MEDIUM-results.json

						trivy convert \
						--format template --template "@/usr/local/share/trivy/templates/html.tpl" \
						--output trivy-image-CRITICAL-results.html trivy-image-CRITICAL-results.json

						trivy convert \
						--format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
						--output trivy-image-MEDIUM-results.xml trivy-image-MEDIUM-results.json

						trivy convert \
						--format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
						--output trivy-image-CRITICAL-results.xml trivy-image-CRITICAL-results.json
			'''

				junit(testResults: 'trivy-image-MEDIUM-results.xml' ,  keepProperties: true , keepTestNames: true  ,allowEmptyResults: true)
				junit(testResults: 'trivy-image-CRITICAL-results.xml' , keepProperties: true , keepTestNames: true , allowEmptyResults: true) 

				archiveArtifacts 'trivy-image-MEDIUM-results.json'
				archiveArtifacts 'trivy-image-CRITICAL-results.json'

				publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './' ,
					 		reportFiles: 'trivy-image-MEDIUM-results.html', reportName: 'trivy-image-MEDIUM-results', reportTitles: ''])
				
				publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './' ,
					 reportFiles: 'trivy-image-CRITICAL-results.html', reportName: 'trivy-image-CRITICAL-results', reportTitles: ''])

				

		}
	}
	
}
