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
                stage("Linter Dockerfile"){
                    steps{
                        script{
                            sh './automation/security.sh hadolint'
                        }
                    }
                }
            }
        } //end paralles
        stage('Build') {
            parallel {
                stage('Build Docker') {
                    steps {
                       sh '''
                        ./automation/docker_build.sh
                        ./automation/docker_push.sh
                       '''
                    }
                }
                stage("Container Security Scan"){
                    steps{
                        script{
                            sh './automation/security.sh trivy'
                            stash name: 'report_trivy.json', includes: 'report_trivy.json'
                        }
                    }
                }
            }
        } //end paralles

    } //end stages
}//end pipeline       