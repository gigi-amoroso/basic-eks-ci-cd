# AWS EKS GitOps Bootstrap Infrastructure

[![Terraform Version](https://img.shields.io/badge/terraform-1.5%2B-blue)](https://terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS-Provider-orange)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This Terraform project bootstraps an Amazon EKS cluster and its supporting infrastructure, including networking, IRSA, and essential Kubernetes add-ons. It also provisions S3 buckets and RDS MariaDB instances for both production and development environments, alongside a GitOps/CICD approach for deploying a sample Bitnami WordPress Helm chart.

> **Note:** This demo assumes that you have already created an AWS Hosted Zone in Route 53.

## 🌟 Overview
This project automates the creation of:
- **EKS Cluster:** With managed node groups running on spot instances to optimize costs.
- **Networking:** A VPC with public/private subnets, NAT gateways, and subnet tagging.
- **IAM Roles:** An execution role (created by running `source setup.sh`) for Terraform, plus IRSA setup (IAM Roles for Service Accounts) for Kubernetes add-ons.
- **Kubernetes Add-ons:**  
  - **AWS Load Balancer Controller:** Automatically provisions AWS load balancers.  
  - **External DNS:** Manages DNS records in Route 53 automatically.  
  - **AWS EBS CSI Driver:** manages the lifecycle of Amazon EBS volumes (required by WordPress).  
  - **AWS Node Termination Handler:** Manages pod migration gracefully during spot instance interruptions.
- **Additional Services:**  
  - **ArgoCD:** Monitors a separate repository ([WordPress Helm chart](https://github.com/gigi-amoroso/wordpress)) and deploys WordPress continuously to dev/prod environments.
  - **Istio Service Mesh & Kiali:** For service mesh management, telemetry, and enhanced networking observability.
- **SSL Termination:** An ACM certificate is provisioned for secure traffic.

## ⚠️ Prerequisites
1. AWS account
2. Pre-existing Route53 Hosted Zone
3. Installed and configured:
   - AWS CLI 
   - Terraform

## 🚀 Quick Start

**Clone repository**:
   ```bash
   git clone https://github.com/gigi-amoroso/basic-eks-ci-cd.git
   cd basic-eks-ci-cd
```
**Set your environment variables for the AWS CLI**:
   ```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```


**Configure Execution Role and initialize Terraform**:
   ```bash
   source source.sh  # Creates TerraformExecutionRole and assumes it
   terraform init
   terraform apply -auto-approve
 ```  

**🌐 Access Endpoints**:
After a successful deployment, you should be able to access:

    ArgoCD Dashboard: https://argo.<your-domain>
![image](https://github.com/user-attachments/assets/18cd7946-6aaa-4faa-b4d2-ea9e5f6f9dd0)


    Kiali Dashboard: https://kiali.<your-domain>
![image](https://github.com/user-attachments/assets/9e0ce40b-f66c-4d0b-8185-e428c1154734)

    Development WordPress: https://dev-wordpress.<your-domain>
    Production WordPress: https://prod-wordpress.<your-domain>
      - Can download plugin like WP Offload Media Lite to offload data to s3 bucket which is already created and should work out of box
      
Default ArgoCD credentials (stored in Kubernetes Secret):

    Username: admin
    Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    
Default WordPress credentials:

    Username: user
    Password admin
    
## ⚠️ Demo Simplification Notice:

This implementation demonstrates core GitOps concepts with ArgoCD, though some simplifications were made. Please note that for a production setup, additional security reviews, automated testing pipelines for commits to both dev and prod branches, and further enhancements would be necessary.
