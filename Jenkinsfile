pipeline{
	agent any

	tools{
		nodejs "nodejs-26"
	}
	stages{
		stage("hello-world"){
			steps{
			   sh "echo 'hello world this is first pipeline updated the webhook added actual IP'"
			}
		}
		stage("Second stage"){
			steps{
				sh """
				node -v
				npm -v
				"""
			}
		}
	}
}
