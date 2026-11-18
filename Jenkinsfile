pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }

  parameters {
    booleanParam(
      name: 'DEPLOY_TO_AWS',
      defaultValue: false,
      description: 'Enable the separately approved manual deployment gate.'
    )
    string(
      name: 'MONITORING_CIDR',
      defaultValue: '127.0.0.1/32',
      description: 'Trusted workstation public IPv4 CIDR used to scrape Node Exporter.'
    )
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    TF_INPUT = 'false'
    TF_VAR_monitoring_cidr = "${params.MONITORING_CIDR}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Tool versions') {
      steps {
        sh 'terraform version'
        sh 'opa version'
        sh 'python3 --version'
      }
    }

    stage('Policy unit tests') {
      steps {
        sh 'opa test policies tests/policies -v'
      }
    }

    stage('Terraform format') {
      steps {
        sh 'terraform -chdir=terraform fmt -check -recursive'
      }
    }

    stage('Terraform initialize and validate') {
      steps {
        sh 'terraform -chdir=terraform init -backend=false'
        sh 'terraform -chdir=terraform validate'
      }
    }

    stage('Terraform plan') {
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cloudguard']
        ]) {
          sh 'terraform -chdir=terraform plan -out=cloudguard.tfplan'
          sh 'terraform -chdir=terraform show -json cloudguard.tfplan > terraform/terraform-plan.json'
        }
      }
    }

    stage('CloudGuard policy gate') {
      steps {
        script {
          int policyStatus = sh(
            script: 'python3 scripts/evaluate_policy.py terraform/terraform-plan.json --output-dir reports',
            returnStatus: true
          )
          archiveArtifacts artifacts: 'reports/policy-report.*', fingerprint: true
          if (policyStatus == 2) {
            error('CloudGuard blocked the Terraform plan. Review the policy report artifact.')
          }
          if (policyStatus != 0) {
            error('CloudGuard policy evaluation failed unexpectedly.')
          }
        }
      }
    }

    stage('Manual deployment approval') {
      when {
        expression { params.DEPLOY_TO_AWS }
      }
      steps {
        input message: 'CloudGuard passed. Apply this reviewed Terraform plan to AWS?', ok: 'Apply approved plan'
      }
    }

    stage('Deploy to AWS') {
      when {
        expression { params.DEPLOY_TO_AWS }
      }
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cloudguard']
        ]) {
          sh 'terraform -chdir=terraform apply -auto-approve cloudguard.tfplan'
          sh 'terraform -chdir=terraform output -json > terraform/deployment-outputs.json'
        }
        archiveArtifacts artifacts: 'terraform/deployment-outputs.json', fingerprint: true
      }
    }
  }

  post {
    always {
      deleteDir()
    }
  }
}
