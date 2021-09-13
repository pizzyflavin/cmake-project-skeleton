pipeline {

    agent any

    stages {

        stage("Build") {
            steps {
                echo "CLeaning..."
                sh "make distclean"

                echo "Building..."
                sh "make"
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
