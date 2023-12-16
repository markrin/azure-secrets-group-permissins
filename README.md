# azure-secrets-group-permissins
Manage secrets groups access in Azure DevOps

---
## Usage
```
export PAT_SECRET=<azure secret key>
bash actions.sh <org_name> <proj_name> <email of target user> <secrets_group name> <access level: Reader|Administrator|User> 
```
