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
		stage("Dependencies Audit"){
			steps{
				sh """
					npm audit --audit-level=critical
				"""
			}
		}
	}
}
