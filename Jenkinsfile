
@Library('hanumanflow-shared-libraries@trivyScan') _

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
		IMAGE_TAG = 'latest'
		DOCKER_IMAGE = 'chowdary2001/solar-system' 
		DOCKER_CONTAINER = "solar-system-container"
		GIT_TOKEN = credentials("github-token")
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
				stash(includes: "node_modules/" , name: "solar-system-node-modules")
			}
		}
		stage("Dependencies Scanning stage"){
			parallel {
				stage("Dependencies Audit"){
					steps{
						sh 'npm audit --audit-level=critical'
					}
				}
			}
		}
		stage("Parallel testing"){
			parallel{
				stage("Testing node-22"){
					steps{
						script{	
							sh "node -v"				
							sh "npm test"
						}
					}
				}

				stage("testing node-20"){
					agent{
						docker{
							image "node:20-alpine"
						}
					}
					stages{
						stage("install dependencies"){
							steps{
							// sh "npm install --no-audit"
							unstash "solar-system-node-modules"
							}
						}
						stage("testing"){
							steps{
								sh "node -v"
								sh "npm test"
							}
						}

					}
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
		stage("Docker image build stage"){
			steps{
				sh 'docker build -t $DOCKER_IMAGE:$IMAGE_TAG .'
			}
		}
		stage("trivy image scan stage"){
			steps{
				script{
					trivyScan.scan(imageName: "$DOCKER_IMAGE:$IMAGE_TAG" , build: "$JOB_NAME" )
				}
			}
		}

		// }
		// stage("Push image to registry"){
		// 	steps{
		// 		withDockerRegistry(credentialsId: 'docker-credentials' , url:''){
		// 			sh "docker push $DOCKER_IMAGE:$IMAGE_TAG"
		// 		}
		// 	}
		// }
		// stage("Deploy - AWS EC2"){
		// 	when{
		// 		branch 'feature/*' 
		// 	}
		// 	steps{
		// 		script{
		// 			sshagent(['aws-deploy-instance-key']){
		// 				sh '''
		// 					ssh  -o StrictHostKeyChecking=no ubuntu@172.31.34.250 "
								
		// 						if sudo docker ps -a | grep -w "$DOCKER_CONTAINER" ; then
		// 							echo "Found $DOCKER_CONTAINER stopping and removing"
		// 							docker container stop "$DOCKER_CONTAINER" && docker rm "$DOCKER_CONTAINER"
		// 							echo "Starting the container"
		// 						fi
		// 						 docker run -d --name $DOCKER_CONTAINER \
		// 				               -p  3001:3000 \
		// 				               -e  MONGO_URI=$MONGO_URI \
		// 				               -e  MONGO_USERNAME=$MONGO_USERNAME \
		// 				               -e  MONGO_PASSWORD=$MONGO_PASSWORD \
		// 				               $DOCKER_IMAGE:$IMAGE_TAG
						        
		// 						docker ps
		// 					"
		// 				'''
		// 			}
		// 		}
		// 	}
		// }

		// stage("Integration testing"){
		// 	when{
		// 		branch 'feature/*'
		// 	}
		// 	options{
		// 		retry(2)
		// 	}
		// 	steps{
		// 		withAWS(credentials:'aws-creds' , region: 'ap-south-1'){
		// 			sh """
		// 				chmod +x integration-test.sh
		// 				bash integration-test.sh
		// 			""" 
					
		// 		}
		// 	}
		// }

		// stage("[PR] k8s update image tag stage"){

		// 	when{
		// 		branch "PR*"
		// 	}
		// 	steps{

		// 		sh 'git clone -b main https://github.com/hanumanflow/solar-system-gitops-argocd.git'

		// 		dir("solar-system-gitops-argocd/solar"){
		// 			sh """
		// 				set -e
		// 				git checkout main
		// 				git checkout -b feature-$BUILD_ID
		// 				yq -iy '.spec.template.spec.containers[0].image="$DOCKER_IMAGE:$IMAGE_TAG"' solar-deployment.yaml
		// 				cat solar-deployment.yaml
		// 				git add .
		// 				git commit -am "Updated docker image file to $DOCKER_IMAGE:$IMAGE_TAG"
		// 				git remote set-url origin https://$GIT_TOKEN@github.com/hanumanflow/solar-system-gitops-argocd.git
		// 				git push origin feature-$BUILD_ID
		// 				git status

		// 			"""
		// 		}

		// 	}

		// }

		// stage("[PR] Raise PR on argocd repo"){
		// 	when {
		// 		branch "PR*"
		// 	}
		// 	steps{
		// 		sh """
		// 			curl -s -o /dev/null -w "Status code :: %{http_code}\n" \
		// 			-X POST \
		// 			-H "Accept: application/vnd.github+json" \
		// 			-H "Authorization: Bearer ${GIT_TOKEN}" \
		// 			https://api.github.com/repos/hanumanflow/solar-system-gitops-argocd/pulls \
		// 			-d '{
		// 				"title":"Updated docker image to $DOCKER_IMAGE:$IMAGE_TAG",
		// 				"head":"feature-$BUILD_ID",
		// 				"base":"main",
		// 				"body":"The image tag is updated to $DOCKER_IMAGE:$IMAGE_TAG"
		// 			}' 
		// 		"""
		// 	}
		// }

		// stage("[PR] Merge PR branch to main"){
		// 	when{
		// 		branch "PR*"
		// 	}
		// 	steps{
		// 		script{
		// 			timeout(time: 1 , unit: "DAYS"){
		// 				input message: "Is feature-$BUILD_ID PR merged to main to update image tag to $DOCKER_IMAGE:$IMAGE_TAG" , ok: "Yes PR merged and image tag updated to $DOCKER_IMAGE:$IMAGE_TAG"
		// 			}
		// 		}
		// 	}
		// }
		// stage("[PR] DAST - OWASP ZAP"){
		// 	when{
		// 		branch "PR*"
		// 	}
		// 	steps{
		// 		// sh """
		// 		// 	chmod 777 $(pwd)
		// 		// 	docker run -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
		// 		// 		-t http://<nginx-ingress-controller-url>/api-docs \
		// 		// 		-f openapi \
		// 		// 		-r zap_report.html \
		// 		// 		-w zap_report.md \
		// 		// 		-J zap_json_report.json \
		// 		// 		-x zap_xml_report.xml \
		// 		// 		-c zap_ignore_rules
					

		// 		// """
		// 		echo "testing completed"
		// 	}
		// }

		// stage("[PR] Delete feature branch in gitops repo"){
		// 	when{
		// 		branch "PR*"
		// 	}
		// 	steps{
		// 		dir("solar-system-gitops-argocd"){
		// 				sh """
		// 					echo 'Deleting feature-$BUILD_ID branch from solar-system-gitops-argocd repo'
		// 					git remote set-url origin https://$GIT_TOKEN@github.com/hanumanflow/solar-system-gitops-argocd.git
		// 					git push origin --delete feature-$BUILD_ID
		// 				"""
		// 			}
		// 		}
		// }
		// stage("[PR] AWS S3 upload"){
		// 	when{
		// 		branch "PR*"
		// 	}
		// 	steps{
		// 		withAWS(credentials: 'aws-creds' , region: 'ap-south-1'){
		// 			sh """
		// 				pwd
		// 				mkdir reports-$BUILD_ID
		// 				cp trivy-image-* test-results.xml coverage/cobertura-coverage.xml reports-$BUILD_ID/

		// 				#cp reports-$BUILD_ID s3://jenkins-reports-9900/reports-$BUILD_ID --recurssive
		// 			"""	
		// 			s3Upload(file: "reports-$BUILD_ID",
		// 			 		 bucket: "jenkins-reports-9900", 
		// 			 		 path: "jenkins-reports-$BUILD_ID")
		// 			sh "aws s3 ls jenkins-reports-9900"
		// 		}
		// 	}
		// }

		// stage("Deploy to prod"){

		// 	when{
		// 		branch "main"
		// 	}
		// 	steps{
		// 		script{
		// 			timeout(time: 1 , unit: 'DAYS'){
		// 				input message: "Should this $DOCKER_IMAGE:$IMAGE_TAG deploy to prod?" ,
		// 					 ok: "YES, Deploy $DOCKER_IMAGE:$IMAGE_TAG to production",
		// 					 submitter: "satya"
							
		// 			}
		// 		}
		// 	}
		// }
	}

	
	post{
		always{
			// junit(testResults: '')
			// echo "POST steps -> after new volume"
				
			// archiveArtifacts 'coverage/cobertura-coverage.xml'
			// archiveArtifacts "test-results.xml"
			// publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'coverage/lcov-report/', 
					// reportFiles: 'index.html', reportName: 'Code-coverage-report', reportTitles: '', useWrapperFileDirectly: true])
			
			junit(testResults: 'test-results.xml' , keepProperties: true , keepTestNames: true)

				script{	
					trivyScan.reportsConvertor()
				}
				

			// 	junit(testResults: 'trivy-image-MEDIUM-results.xml' ,  keepProperties: true , keepTestNames: true  ,allowEmptyResults: true)
			// 	junit(testResults: 'trivy-image-CRITICAL-results.xml' , keepProperties: true , keepTestNames: true , allowEmptyResults: true) 

				archiveArtifacts 'trivy-image-MEDIUM-results.json'
				archiveArtifacts 'trivy-image-CRITICAL-results.json'

			// 	publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './' ,
			// 		 		reportFiles: 'trivy-image-MEDIUM-results.html', reportName: 'trivy-image-MEDIUM-results', reportTitles: ''])
				
			// 	publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './' ,
			// 		 reportFiles: 'trivy-image-CRITICAL-results.html', reportName: 'trivy-image-CRITICAL-results', reportTitles: ''])

			// script{
			// 	if(fileExists('solar-system-gitops-argocd')){
			// 		sh "rm -rf solar-system-gitops-argocd"
			// 	}
			// }

		}
		success{
			slackNotification("SUCCESS")
		}
		failure{
			slackNotification("FAILURE")
		}
	}
	
}

