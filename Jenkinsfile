pipeline {
    agent any
    
    stages {
        stage('Initialize') {
            steps {
                script {
                    def dockerHome = tool 'docker-tool'
                    env.PATH = "${dockerHome}/bin:${env.PATH}"
                }
            }
        }

        stage('Checkout Code') {
            // NOTE: This stage will still run, but it will check out the code to get 
            // the index.html, Dockerfile, deploy_nginx.yml, etc.
            steps {
                git url: 'https://github.com/jaehyuncho1229/Final_Work_Assignment_SB',
                branch: 'leon',
                credentialsId: 'github-token'
            }
        }

        stage('Add build number') {
            steps {
                script {
                    sh ('sed -i "s/INSERT_BUILD_NUMBER/${BUILD_NUMBER}/g" index.html')
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    script {
                        echo "The commit ID is: ${GIT_COMMIT}"

                        def image = docker.build(
                            "yelucpp/devops_workflow_integration_repo:${GIT_COMMIT}-${BUILD_NUMBER}",
                            "."
                        )

                        sh ('docker login --username \$DOCKERHUB_USERNAME --password \$DOCKERHUB_PASSWORD')
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Run Ansible') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD'),
                    usernamePassword(credentialsId: 'vm1-userpass', usernameVariable: 'VM_USER', passwordVariable: 'VM_PASS'),
                    usernamePassword(credentialsId: 'grafana-admin-creds', usernameVariable: 'GRAFANA_USER', passwordVariable: 'GRAFANA_PASSWORD') 
                ]) {
                    script {
                        def remote = [:]
                        remote.name = 'vm1'
                        remote.host = '10.0.0.3'
                        remote.user = VM_USER
                        remote.password = VM_PASS
                        remote.allowAnyHosts = true
 
                        // --- CORRECTED PATHS TO /home/jaecho/ansible ---
                        sshPut remote: remote, from: 'deploy_nginx.yml', into: '/home/jaecho/ansible/deploy_nginx.yml'
                        sshPut remote: remote, from: 'prometheus.yml', into: '/home/jaecho/ansible/prometheus.yml'
                        sshPut remote: remote, from: 'datasource.yml', into: '/home/jaecho/ansible/datasource.yml'
                     
                        sshCommand remote: remote, 
                        command: """
                            ansible-playbook ansible/deploy_nginx.yml \
                                -e DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME} \
                                -e DOCKERHUB_PASSWORD=${DOCKERHUB_PASSWORD} \
                                -e GRAFANA_USER=${GRAFANA_USER} \
                                -e GRAFANA_PASSWORD=${GRAFANA_PASSWORD}
                            """
                    }
                }
            }
        }
    }
}
