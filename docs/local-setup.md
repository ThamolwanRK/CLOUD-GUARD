# Local Setup

## Prerequisites

- Git
- Terraform 1.17.x AMD64
- Docker Desktop with Linux containers
- Docker Compose
- AWS CLI v2

## Start the control services

1. Copy `.env.example` to `.env`.
2. Replace the Grafana password with a unique local value.
3. Build and start the services:

```powershell
docker compose up -d --build jenkins prometheus grafana
```

4. Inspect service status:

```powershell
docker compose ps
```

Jenkins stores its state in a named Docker volume, separate from the previous Windows installation.

## Unlock Jenkins

Read the generated password locally:

```powershell
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open `http://localhost:8080`, enter the password, and create your own Jenkins administrator. Do not share that password.

## Create the pipeline

Create a Pipeline job pointing to the GitHub repository and select `Jenkinsfile` from source control. Complete GitHub authentication yourself if the repository requires it.

Before real planning, add an AWS credential in Jenkins with ID `aws-cloudguard`. You must create and enter that credential yourself according to `aws-identity-setup.md`.

## Local policy tests

```powershell
docker compose --profile tools run --rm policy-test
```

## Stop services

```powershell
docker compose down
```

Do not add `--volumes` unless you deliberately intend to erase Jenkins, Prometheus, and Grafana local data.
