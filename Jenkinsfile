pipeline {

    agent any

    stages {

        stage("Build") {
            steps {
                echo "Building..."
                sh "make distclean"
                sh "make"
            }
        }

        stage("Test") {
            steps {
                echo "Testing..."
                sh "make test"
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
