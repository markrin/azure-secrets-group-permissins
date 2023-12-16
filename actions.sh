#!/bin/bash

: change users permissions for variables group

echo "Usage: ${0} <organization> <project_name> <user_mail> <variables_group_regexp> <permissions_level:Reader,User,Administrator>"
:                       1               2            3                  4                         5               
echo
echo "start..."


PAT="${PAT_SECRET}"


organization=$1
projectName=$2
userName=$3
varGroupName=$4
permissionsLevel=$5

# get vargroups
varGroupmaskJQ=".value[] | select(.name|test(\"${varGroupName}\")) | .id"
GROUPS_ID=$(curl -su :${PAT} https://dev.azure.com/$organization/$projectName/_apis/distributedtask/variablegroups?api-version=6.1-preview.2 \
 | jq "${varGroupmaskJQ}" )

echo GROUPS_ID $GROUPS_ID


# get projects (to extract id)
projectIdJQ=".value[] | select(.name=\"${projectName}\") | .id"
PROJECT_ID=$(curl -su :${PAT} https://dev.azure.com/$organization/_apis/projects?api-version=6.0 | jq "${projectIdJQ}")

PROJECT_ID=$(eval echo $PROJECT_ID) # remove quotes
echo PROJECT_ID $PROJECT_ID


# get user by mask
userNameJQ=".members[] | select(.user.mailAddress==\"${userName}\") | .id"
USER_ID=$(curl -su :${PAT} https://vsaex.dev.azure.com/devmoreopsless/_apis/userentitlements?api-version=7.0\
 | jq "${userNameJQ}")

USER_ID=$(eval echo $USER_ID) # remove quotes
echo USER_ID $USER_ID


# set permissions
jsondata="[{\"userId\":\"${USER_ID}\",\"roleName\":\"$permissionsLevel\"}]"

for groupId in $GROUPS_ID 
do
    echo "Process variable group id ${groupId}"
    curl -s -H "Content-Type: application/json" --request PUT \
 --data "${jsondata}" \
 -u :${PAT} "https://dev.azure.com/devmoreopsless/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$PROJECT_ID\$$groupId?api-version=7.0-preview.1"
    echo

done

echo

exit 0



# TODO: use https://github.com/microsoft/azure-devops-python-api

# reset permissions API
#     curl -s -H "Content-Type: application/json" --request PATCH \
#  --data "" \
#  -u :${PAT} "https://dev.azure.com/devmoreopsless/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$PROJECT_ID\$$groupId?api-version=7.0-preview.1"
