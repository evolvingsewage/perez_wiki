// Build/test/deploy pipeline for perez_wiki. The infra_perez_wiki repo
// provisions the Jenkins job that runs this file (SCM: perez_wiki, Jenkinsfile)
// and supplies the linode-ssh-key credential and LINODE_HOST env.
pipeline {
    agent any

    stages {
        // Run E2E tests against Docker headless image
        stage('Pre-deploy E2E') {
            steps {
                sh 'docker compose -f docker-compose.e2e.yml up --build --abort-on-container-exit --exit-code-from tests'
            }
            post {
                always {
                    sh 'docker compose -f docker-compose.e2e.yml down -v'
                }
            }
        }

        // Deploy: pull, install, and restart the site on the linode
        stage('Deploy') {
            steps {
                sshagent(credentials: ['linode-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no jenkins-deploy@${env.LINODE_HOST} '
                          cd /home/perez-wiki/perez_wiki &&
                          git pull origin main &&
                          source venv/bin/activate &&
                          pip install --upgrade pip &&
                          pip install -r requirements.txt &&
                          sudo cp /home/perez-wiki/perez_wiki/files/perez_wiki /etc/nginx/sites-available/perez_wiki &&
                          sudo systemctl reload nginx &&
                          sudo cp /home/perez-wiki/perez_wiki/files/perez_wiki.service /etc/systemd/system/perez_wiki.service &&
                          sudo systemctl daemon-reload &&
                          sudo systemctl restart perez_wiki
                        '
                    """
                }
            }
        }

        // run the same suite against the linode
        stage('Post-deploy') {
            steps {
                sh 'E2E_BASE_URL=https://perez.wiki docker compose -f docker-compose.e2e.yml up --no-deps --abort-on-container-exit --exit-code-from tests chrome tests'
            }
            post {
                always {
                    sh 'docker compose -f docker-compose.e2e.yml down -v'
                }
            }
        }
    }
}
