#!/bin/bash
SERVICE=$(aws ecs list-services --region ${REGION} --cluster ${CLUSTER}| grep ${CLUSTER}-service-DSL | wc -l)
if [ $SERVICE -ne 0 ]
then
echo "============ Updating service ============="
aws ecs update-service --region ${REGION} --cluster ${CLUSTER} --service ${CLUSTER}-service-DSL --force-new-deployment
else
echo "============ Registering task definition ==========="
# ============ CHANGE ENV ================
sed -i -e "s/\$CLUSTER/${CLUSTER}/g" scripts/fargate-task.json
sed -i -e "s/\$DB_USER/${DB_USER}/g"  scripts/fargate-task.json
sed -i -e "s/\$DB_NAME/${DB_NAME}/g"  scripts/fargate-task.json
sed -i -e "s/\$DB_PASS/${DB_PASS}/g" scripts/fargate-task.json
sed -i -e "s/\$DB_URL/${DB_URL}/g"  scripts/fargate-task.json
sed -i -e "s/\$DB_PORT/${DB_PORT}/g"  scripts/fargate-task.json

aws ecs register-task-definition --region ${REGION}  --cli-input-json file://script-DSL/fargate-task.json
echo "==================Creating service ================"
REVISION=$(aws ecs describe-task-definition --region ${REGION} --task-definition ${CLUSTER}-fargate --query 'taskDefinition.revision')
aws ecs create-service --region ${REGION} --cluster ${CLUSTER} --service-name ${CLUSTER}-service-DSL --task-definition ${CLUSTER}-fargate:"${REVISION}" --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-45a4181c],securityGroups=[sg-031cad4dded62d028]}"
fi

sleep 120
# ============================= HEALTH CHECKS ==============================
ACTIVE_TASKS=$(aws ecs list-tasks --cluster ${CLUSTER} --region ${REGION} --service ${CLUSTER}-deploy | jq .taskArns[] | tr -d '"')

APP_IP=$(aws ecs describe-tasks --tasks $ACTIVE_TASKS --cluster ${CLUSTER} --region ${REGION} --query "sort_by(tasks, &createdAt)[0]" | \
		jq 'select(.overrides.containerOverrides[].name == "${CLUSTER}-petclinic") | .attachments[].details[] | select(.name == "privateIPv4Address") | .value' | tr -d '"')
curl -fs http://$APP_IP/ &>/dev/null || { echo "APP failed to start"; exit 1; }

DB_HEALTH_STATUS=$(aws ecs describe-tasks --tasks $ACTIVE_TASKS  --cluster ${CLUSTER} --region ${REGION} --query 'sort_by(tasks, &createdAt)[0]' |
				  jq 'select(.overrides.containerOverrides[].name == "kilo-petclinic") | .healthStatus' | tr -d '"')
                  
echo $DB_HEALTH_STATUS
                  
if [[ "$DB_HEALTH_STATUS" == "HEALTHY" ]]; then
	echo "APP is running correctly"
else
	echo "Probably smth is wrong with DB"
    exit 2
fi

# ============= CREATE/UPDATE RECORD IN ROUTE 53 ============
cat > record-set.json <<EOF
{
            "Comment": "CREATE/UPSERT a record ",
            "Changes": [{
           "Action": "UPSERT",
                        "ResourceRecordSet": {
                                    "Name": "Domen.namezone",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "$APP_IP"}]
}}]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id Z3ANYTCYP3WQQS --change-batch file://record-set.json

