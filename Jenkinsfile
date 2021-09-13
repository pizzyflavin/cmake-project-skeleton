pipeline {

    agent any

    stages {

        stage("Build") {
            steps {
                echo "Building..."
            }
        }

        stage("Test") {
            steps {
                echo "Testing..."
            }
        }

        stage("Deploy") {
            steps {
                echo "Deploying..."
            }
        }
    }
    post {

        always {
            echo "Build completed"
        }

        success {
            echo "Build succeeded"
        }

        failure {
            echo "Build failed"
        }
    }
}
