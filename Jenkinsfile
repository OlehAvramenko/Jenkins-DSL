pipeline {
    agent none

    environment {
<<<<<<< HEAD
      REGION = ''
      REGISTRY = ''
      BUCKET = ''
      DB_NAME = ''
      DB_USER = ''
      DB_URL = ''
      DB_PORT = ''
      CLUSTER = ''
=======
      REGION = 'us-east-1'
      REGISTRY = ''
      BUCKET = 'demo3-dependency-m2'
      DB_NAME = 'foxtrot_petclinic'
      DB_USER = 'foxtrot'
      DB_URL = ''
      DB_PORT = '3306'
      CLUSTER = 'Foxtrot'
>>>>>>> dee0c9dfcadd99efa0deb2a36c1422eeb8d8f47f
    }


    stages {
        stage('build-main') {
          agent {
            label 'foxtrot_build'
          }
            steps {
              echo "=========== BUILD APP ============"
                git branch: 'main',
                  credentialsId: 'avramenko',
                   url: '${URL}'
              sh '''
<<<<<<< HEAD
               chmod 777 script-DSL/build_app.sh && script-DSL/build_app.sh
=======
              #!/bin/bash
                  sudo chmod 666 /var/run/docker.sock
                  [ ! -d "${WORKSPACE}/.m2" ]  && mkdir -p ${WORKSPACE}/.m2
                  aws s3 sync  s3://${BUCKET}/.m2 ${WORKSPACE}/.m2/
                  DOCKER_BUILDKIT=1 docker build . -t petclinic-app:${BUILD_NUMBER} -f docker/docker_APP/Dockerfile --progress=plain
                  aws s3 sync ${WORKSPACE}/.m2/ s3://${BUCKET}/.m2
>>>>>>> dee0c9dfcadd99efa0deb2a36c1422eeb8d8f47f
                  '''
              echo "============== PUSH INTO REGISTRY ============"
              sh '''
<<<<<<< HEAD
              chmod 777 script-DSL/push_registry.sh && script-DSL/push_registry.sh
=======
              #!/bin/bash
               GIT_TAG=`git tag --points-at HEAD`
               [ -z "${GIT_TAG}" ] && TAG=${BUILD_NUMBER} || TAG=${GIT_TAG}_${BUILD_NUMBER}
               aws ecr get-login-password --region=${REGION} | docker login --username AWS --password-stdin ${REGISTRY}
               docker tag petclinic-app:${BUILD_NUMBER} ${REGISTRY}:${TAG}
               docker push ${REGISTRY}:$TAG
               docker tag petclinic-app:${BUILD_NUMBER} ${REGISTRY}:latest
               docker push ${REGISTRY}:latest
>>>>>>> dee0c9dfcadd99efa0deb2a36c1422eeb8d8f47f
               '''
                }
              }
              stage ('deploy') {
                agent {
                  label 'foxtrot_deploy'
                }
                steps {
                       git branch: 'main',
                        credentialsId: 'avramenko',
                        url: '${URL}'
                  echo "============ DEPLOY APP ============="
<<<<<<< HEAD
                sh '''
                chmod 777 script-DSL/deploy.sh && script-DSL/deploy.sh
=======
                  sh '''
                    echo "===============Creating task definition ============"
                    tee "fargate-task.json" > "/dev/null" <<EOF
                    {
                    "family": "${CLUSTER}-fargate",
                    "executionRoleArn": "ecsTaskExecutionRole",
                    "networkMode": "awsvpc",
                    "containerDefinitions": [
                      {
                        "name": "${CLUSTER}-petclinic",
                        "image": "${REGISTRY}",
                        "portMappings": [
                          {
                            "containerPort": 8080,
                            "protocol": "tcp"
                          }
                        ],
                        "essential": true,
                        "environment": [
                          {
                            "name": "MYSQL_USER",
                            "value": "${DB_USER}"
                          },
                          {
                            "name": "MYSQL_PASS",
                            "value": "${DB_PASS}"
                          },
                          {
                            "name": "MYSQL_URL",
                            "value": "jdbc:mysql://${DB_URL}:${DB_PORT}/${DB_NAME}"
                          }
                        ],
                        "healthCheck": {
                          "command": [ "CMD-SHELL", "curl -f http://localhost:8080/ || exit 1" ],
                          "startPeriod": 60
                        }
                      }
                    ],
                    "requiresCompatibilities": [ "FARGATE" ],
                    "cpu": "1024",
                    "memory": "2048"
                    }
                '''
                sh '''
                #!/bin/bash
                SERVICE=$(aws ecs list-services --region ${REGION} --cluster ${CLUSTER}| grep ${CLUSTER}-service | wc -l)
                if [ $SERVICE -ne 0 ]
                then
                  echo "Updating service"
                  aws ecs update-service --region ${REGION} --cluster ${CLUSTER} --service ${CLUSTER}-service --force-new-deployment
                else
                  echo "============ Registering task definition ==========="
                  aws ecs register-task-definition --region ${REGION}  --cli-input-json file://fargate-task.json
                  echo "==================Creating service ==============="
                  REVISION=$(aws ecs describe-task-definition --region ${REGION} --task-definition ${CLUSTER}-fargate --query 'taskDefinition.revision')
                  aws ecs create-service --region ${REGION} --cluster ${CLUSTER} --service-name ${CLUSTER}-service --task-definition ${CLUSTER}-fargate:"${REVISION}" --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[],securityGroups=[]}"
                fi
>>>>>>> dee0c9dfcadd99efa0deb2a36c1422eeb8d8f47f
                  '''
                }
          }
    }
}
