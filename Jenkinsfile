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
		stage("list repo"){
			steps{
				sh """
					pwd
					ls -la
				"""
			}
		}
	}
}
