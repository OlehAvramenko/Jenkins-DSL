#!/bin/bash
SERVICE=$(aws ecs list-services --region ${REGION} --cluster ${CLUSTER}| grep ${CLUSTER}-service | wc -l)
if [ $SERVICE -ne 0 ]
then
echo "============ Updating service ============="
aws ecs update-service --region ${REGION} --cluster ${CLUSTER} --service ${CLUSTER}-service --force-new-deployment
else
echo "============ Registering task definition ============"
# ============ CHANGE ENV ================
sed -i -e "s/\${CLUSTER}/"${CLUSTER}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${REGISTRY}/"${REGISTRY}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${DB_USER}/"${DB_USER}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${DB_NAME}/"${DB_NAME}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${DB_USER}/"${DB_USER}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${DB_PASS}/"${DB_PASS}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${DB_URL}/"${DB_URL}"/g" script-DSL/fargate-task.json
sed -i -e "s/\${DB_PORT}/"${DB_PORT}"/g" script-DSL/fargate-task.json

aws ecs register-task-definition --region ${REGION}  --cli-input-json file://fargate-task.json
echo "==================Creating service ================"
REVISION=$(aws ecs describe-task-definition --region ${REGION} --task-definition ${CLUSTER}-fargate --query 'taskDefinition.revision')
aws ecs create-service --region ${REGION} --cluster ${CLUSTER} --service-name ${CLUSTER}-service --task-definition ${CLUSTER}-fargate:"${REVISION}" --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[],securityGroups=[]}"
fi
