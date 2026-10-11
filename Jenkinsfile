pipeline {
    agent {
        label 'python-agent'
    }

    options {
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        K8S_NAMESPACE = 'jenkins'
        APP_NAME      = 'nginx-test'
        APP_IMAGE     = 'nginx:alpine'
    }

    stages {

        stage('01 - Agent Information') {
            steps {
                sh '''
                    echo "=== JENKINS AGENT ==="
                    hostname
                    whoami
                    pwd
                    echo "Namespace: $K8S_NAMESPACE"
                '''
            }
        }

        stage('02 - Check Tools') {
            steps {
                sh '''
                    echo "=== PYTHON ==="
                    python3 --version
                    python3 -m pip --version

                    echo "=== GIT ==="
                    git --version

                    echo "=== KUBERNETES ==="
                    kubectl version --client
                '''
            }
        }

        stage('03 - Kubernetes RBAC') {
            steps {
                sh '''
                    echo "=== SERVICE ACCOUNT NAMESPACE ==="
                    cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
                    echo

                    echo "=== CHECK PERMISSIONS ==="
                    kubectl auth can-i get pods          -n "$K8S_NAMESPACE"
                    kubectl auth can-i create deployments -n "$K8S_NAMESPACE"
                    kubectl auth can-i patch deployments  -n "$K8S_NAMESPACE"

                    echo "RBAC permissions: OK"
                '''
            }
        }

        stage('04 - Kubernetes Connection') {
            steps {
                sh '''
                    echo "=== KUBERNETES RESOURCES ==="
                    kubectl get pods        -n "$K8S_NAMESPACE"
                    kubectl get deployments -n "$K8S_NAMESPACE"
                    kubectl get services    -n "$K8S_NAMESPACE"
                '''
            }
        }

        stage('05 - Deploy Nginx') {
            steps {
                sh '''
                    echo "=== DEPLOY NGINX ==="
                    kubectl create deployment "$APP_NAME" \
                      --image="$APP_IMAGE" \
                      --replicas=1 \
                      -n "$K8S_NAMESPACE" \
                      --dry-run=client -o yaml \
                      | kubectl apply -f -

                    echo "Deployment submitted"
                '''
            }
        }

        stage('06 - Verify Deployment') {
            steps {
                sh '''
                    echo "=== WAIT FOR ROLLOUT ==="
                    kubectl rollout status deployment/"$APP_NAME" \
                      -n "$K8S_NAMESPACE" --timeout=120s

                    echo "=== DEPLOYMENTS ==="
                    kubectl get deployments -n "$K8S_NAMESPACE"

                    echo "=== PODS ==="
                    kubectl get pods -n "$K8S_NAMESPACE" -o wide
                '''
            }
        }

        stage('07 - Test Application') {
            steps {
                sh '''
                    echo "=== TEST NGINX ==="
                    kubectl wait --for=condition=available \
                      deployment/"$APP_NAME" \
                      -n "$K8S_NAMESPACE" --timeout=60s

                    echo "Nginx application is available!"
                '''
            }
        }
    }

    post {
        success { echo 'SUCCESS: Jenkins Kubernetes Pipeline completed!' }
        failure { echo 'FAILED: Check the failed stage in Console Output.' }
        always  { echo 'Pipeline execution finished.' }
    }
}
