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
        stage('Security Sast') {
            parallel {
                stage('Horusec') {
                    steps {
                       sh './automation/security.sh horusec'
                       stash name: 'report_horusec.json', includes: 'report_horusec.json'
                    }
                }
                stage("Semgrep"){
                    agent{
                        docker{
                            image 'returntocorp/semgrep'
                            args '-u root:root'                    
                        }
                    }
                    steps{
                         sh '''
                            cat << 'EOF' | bash
                                semgrep ci --config=auto --json --output=report_semgrep.json --max-target-bytes=2MB
                                EXIT_CODE=$?
                                if [ "$EXIT_CODE" = "0" ] || [ "$EXIT_CODE" = "1" ]
                                then
                                    exit 0
                                else
                                    exit $EXIT_CODE
                                fi
                            EOF
                            '''
                            stash name: 'report_semgrep.json', includes: 'report_semgrep.json'
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
        stage('Deploy') {
            parallel {
                stage('Deploy to AWS') {
                    steps {
                      sshagent(credentials : ['ssh-aws']){
                        sh './automation/deploy.sh ec2'
                      }
                    }
                }
                stage("Notifications"){
                    when {
                        branch "master"
                    }
                    steps{
                        script{
                            sh './automation/telegram-notification.sh'
                        }
                    }
                }
            }
        } //end paralles
        stage("Security Dast"){
            when {
                branch "testing"
            }
            agent{
              docker{
                image "owasp/zap2docker-weekly"
                args "--volume ${WORKSPACE}:/zap/wrk"
                reuseNode true                   
                }
                    }
            steps{
                script {
                    def result = sh label: "OWASP ZAP", returnStatus: true,
                        script: """\
                            zap-baseline.py \
                            -t "http://18.233.150.95" \
                            -m 1 \
                            -d \
                            -r zapreport.html \
                    """
                    if (result > 0) {
                        unstable(message: "OWASP ZAP issues found")
                    }
                     stash name: 'zapreport.html', includes: 'zapreport.html'   
                }
            }
        }        
    } //end stages
}//end pipeline       