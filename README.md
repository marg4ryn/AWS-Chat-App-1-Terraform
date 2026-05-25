
# Deployment Guide

## Step 1 — Create ECR Repositories

```powershell
aws ecr create-repository --repository-name app-frontend
aws ecr create-repository --repository-name app-backend
````

---

## Step 2 — Package ZIP Files

```powershell
cd App-Frontend
zip ../app-frontend.zip Dockerrun.aws.json

cd ../App-Backend
zip ../app-backend.zip Dockerrun.aws.json
```

---

## Step 3 — Upload ZIP Files to S3

```powershell
aws s3 cp app-frontend.zip s3://elasticbeanstalk-<region>-<account-id>/
aws s3 cp app-backend.zip s3://elasticbeanstalk-<region>-<account-id>/
```

---

## Step 4 — Authenticate Docker with ECR

```powershell
$password = aws ecr get-login-password --region <region>

docker login `
  --username AWS `
  --password $password `
  <account-id>.dkr.ecr.<region>.amazonaws.com
```

---

## Step 5 — Build and Push Docker Images

### Frontend

```powershell
docker build -t app-frontend ./app-frontend

docker tag app-frontend:latest `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-frontend:latest

docker push `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-frontend:latest
```

### Backend

```powershell
docker build -t app-backend ./app-backend

docker tag app-backend:latest `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-backend:latest

docker push `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-backend:latest
```

---

## Step 6 — Create Elastic Beanstalk Application Versions

### Frontend

```powershell
aws elasticbeanstalk create-application-version `
  --application-name app-frontend `
  --version-label v1 `
  --source-bundle `
    S3Bucket=elasticbeanstalk-<region>-<account-id>,S3Key=app-frontend.zip
```

### Backend

```powershell
aws elasticbeanstalk create-application-version `
  --application-name app-backend `
  --version-label v1 `
  --source-bundle `
    S3Bucket=elasticbeanstalk-<region>-<account-id>,S3Key=app-backend.zip
```

---

## Step 7 — Deploy Applications

### Frontend

```powershell
aws elasticbeanstalk update-environment `
  --environment-name app-frontend-env `
  --version-label v1
```

### Backend

```powershell
aws elasticbeanstalk update-environment `
  --environment-name app-backend-env `
  --version-label v1
```

---

# Cleanup

## Remove Elastic Beanstalk Application Versions

```powershell
aws elasticbeanstalk delete-application-version `
  --application-name app-frontend `
  --version-label v1 `
  --delete-source-bundle

aws elasticbeanstalk delete-application-version `
  --application-name app-backend `
  --version-label v1 `
  --delete-source-bundle
```

---

## Remove ECR Repositories

```powershell
aws ecr delete-repository `
  --repository-name app-frontend `
  --force

aws ecr delete-repository `
  --repository-name app-backend `
  --force
```

---

## Remove S3 Bucket

```powershell
aws s3 rm s3://<bucket-name> --recursive
aws s3 rb s3://<bucket-name>
```

---

## Destroy Elastic Beanstalk Infrastructure with Terraform

### Frontend

```powershell
terraform destroy `
  -target="module.frontend.aws_elastic_beanstalk_environment.env"

terraform destroy `
  -target="module.frontend.aws_elastic_beanstalk_application.app"
```

### Backend

```powershell
terraform destroy `
  -target="module.backend.aws_elastic_beanstalk_environment.env"

terraform destroy `
  -target="module.backend.aws_elastic_beanstalk_application.app"
```

---

# Optional

## Restart Elastic Beanstalk App Servers

### Frontend

```powershell
aws elasticbeanstalk restart-app-server `
  --environment-name app-frontend-env
```

### Backend

```powershell
aws elasticbeanstalk restart-app-server `
  --environment-name app-backend-env
```

```
```
