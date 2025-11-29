pipeline {
    agent any
    
    // environment { 
    //     DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    //     VM1_CREDENTIALS = credentials('vm1-userpass')
    // }
    
    stages {
        stage('Initialize') {
            steps {
                script {
        
                    def dockerHome = tool 'docker-tool' [cite: 4]
                    env.PATH = "${dockerHome}/bin:${env.PATH}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
   
                git url: 'https://github.com/jaehyuncho1229/Final_Work_Assignment_SB', // Updated to your new repository
                branch: 'leon',
                credentialsId: 'github-token'
            }
        }

        stage('Add build number') {
            steps {
       
                script {
                    sh ('sed -i "s/INSERT_BUILD_NUMBER/${BUILD_NUMBER}/g" index.html') [cite: 6]
                }
            }
        }

        stage('Build Docker Image') {
            steps {
      
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) { [cite: 7]
                    script {
                        echo "The commit ID is: ${GIT_COMMIT}"

                        def image = docker.build(
       
                            "yelucpp/devops_workflow_integration_repo:${GIT_COMMIT}-${BUILD_NUMBER}", [cite: 8]
                            "."
                        )

                        sh ('docker login --username \$DOCKERHUB_USERNAME --password \$DOCKERHUB_PASSWORD') [cite: 9]
                        image.push()
                        image.push('latest')
                    }
                }
            }
 
        } [cite: 10]
        
        stage('Run Ansible') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD'),
                    usernamePassword(credentialsId: 'vm1-userpass', usernameVariable: 'VM_USER', passwordVariable: 'VM_PASS'), [cite: 11]
                    // NEW: Credential for Grafana Admin
                    usernamePassword(credentialsId: 'grafana-admin-creds', usernameVariable: 'GRAFANA_USER', passwordVariable: 'GRAFANA_PASSWORD') 
                ]) {
                    script {
                        def remote = [:]
                        remote.name = 'vm1'
     
                        remote.host = '10.0.0.3' [cite: 12]
                        remote.user = VM_USER
                        remote.password = VM_PASS
                        remote.allowAnyHosts = true
 
                        // Put deploy_nginx.yml
                        sshPut remote: remote, from: 'deploy_nginx.yml', into: '/home/leon/ansible/deploy_nginx.yml'
                        
                        // NEW: Put monitoring configuration files
                        sshPut remote: remote, from: 'prometheus.yml', into: '/home/leon/ansible/prometheus.yml'
                        sshPut remote: remote, from: 'datasource.yml', into: '/home/leon/ansible/datasource.yml'
                        
                        sshCommand remote: remote, 
                    
                        command: """
                                ansible-playbook ansible/deploy_nginx.yml \
                                    -e DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME} \
                                    -e DOCKERHUB_PASSWORD=${DOCKERHUB_PASSWORD} \
                                    -e GRAFANA_USER=${GRAFANA_USER} \
                                    -e GRAFANA_PASSWORD=${GRAFANA_PASSWORD}
                            """ // Added GRAFANA_USER and GRAFANA_PASSWORD as extra vars
                            // ,sudo: true
                    }
    
                } [cite: 16]
            }
        }
    }
    // post {
    //     success {
    //         sh """
    //         curl -X POST https://webexapis.com/v1/messages \
    //         -H "Authorization: Bearer ${env.WEBEX_TOKEN}" [cite: 17] \
    //         -H "Content-Type: application/json" \
    //         -d '{"roomId":"${env.WEBEX_ROOM_ID}","text":"Pipeline ran successfully.
    //         Build number is #${BUILD_NUMBER}!"}' [cite: 18]
    //         """
    //     }
    //     failure {
    //         sh """
    //         curl -X POST https://webexapis.com/v1/messages \
    //         -H "Authorization: Bearer ${env.WEBEX_TOKEN}" \
    //         -H "Content-Type: application/json" \
    //         -d '{"roomId":"${env.WEBEX_ROOM_ID}","text":"Pipeline failed for build number #${BUILD_NUMBER}!"}' [cite: 19]
    //         """
    //     }
    // }
}