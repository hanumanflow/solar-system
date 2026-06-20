pipeline{
	agent any

	tools{
		nodejs "nodejs-26"
	}
	stages{
		stage("Checkout repo"){
			steps{
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
		stage("Dependencies Scanning"){
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
	}
}
