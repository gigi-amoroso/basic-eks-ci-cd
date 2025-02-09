# Terraform EKS Infrastructure

**Status:** Core functionality works; CI/CD setup coming

This repository provisions an Amazon EKS cluster with its supporting infrastructure using Terraform. It leverages community modules and custom code to provide a baseline for deploying microservices that can be customized via `variables.tf`.

## Key Components

- **VPC & Networking**  
  Uses [terraform-aws-modules/vpc/aws] to create a VPC with public/private subnets, NAT gateways, and proper subnet tagging for automatic subnet discovery (for the Load Balancer Controller).

- **EKS Cluster**  
  Provisions an EKS cluster (via [terraform-aws-modules/eks/aws]) with a managed node group and IRSA (IAM Roles for Service Accounts).

- **IAM IRSA Roles**  
  Creates IAM roles for key Kubernetes add-ons using a dedicated module based on [iam-role-for-service-accounts-eks].

- **ACM Certificate**  
  Provisions an ACM SSL certificate with DNS validation via Route 53 (a valid hosted zone is a prerequisite).

- **Helm Releases**  
  Deploys core Kubernetes add-ons:
  - **AWS Load Balancer Controller:** Manages AWS ELBs to route external traffic based on created ingresses.
  - **External DNS:** Automates DNS record management in Route 53.
  - **AWS Node Termination Handler:** Handles spot instance termination events (important when using spot instances).

- **Setup Script**  
  The `setup.sh` script retrieves hosted zone info from Route 53, generates `generated.auto.tfvars` and trust policy files, and creates (if needed) and assumes a `TerraformExecutionRole` to export temporary credentials.

## How It Works

1. **Setup:**  
   Run `source setup.sh` to generate required variables, trust policies, and assume the Terraform execution role.

2. **Provisioning:**  
   Execute:
   ```bash
   terraform init
   terraform apply
   ```
   creates the VPC, EKS cluster, IAM IRSA roles, ACM certificate, and deploys Helm charts.

## Prerequisites

- An AWS account with a configured hosted zone (Route 53)
- AWS CLI, Terraform (>=1.0), and jq installed  

## Future Enhancements

- Additional features/modules for autoscaling, monitoring, enhanced RBAC, CI/CD integration etc.
- Production-grade refinements.
