pipeline{
    agent any

// if you want to push a new version of your app, just make changes in html, upgrade the tag.
environment {
    DOCKER_HUB_LOGIN = credentials('docker-hub')
}

    stages{
        stage('Init') {
            parallel {
                stage('Install dependencies') {
                    agent{
                        docker{
                            image 'node:18-alpine'
                            args '-u root:root'                    
                        }
                    }
                    steps {
                       sh 'npm install'
                    }
                }
                stage("Test"){
                    agent{
                        docker{
                            image 'roxsross12/node-chrome'
                            args '-u root:root'                    
                        }
                    }
                    steps{
                        script{
                            sh 'npm run test'
                        }
                    }
                }
            }
        } //end paralles


    } //end stages
}//end pipeline       