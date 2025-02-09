Terraform EKS Infrastructure

    Status: Under Development

This repository provisions an Amazon EKS cluster with supporting infrastructure using Terraform. It leverages community modules and custom code to deliver a secure, scalable, and auditable baseline.
Key Components

    VPC & Networking:
    Uses terraform-aws-modules/vpc/aws to create a VPC with public/private subnets, NAT gateways, and proper subnet tagging.

    EKS Cluster:
    Provisions an EKS cluster (via terraform-aws-modules/eks/aws) with managed node groups, IRSA (IAM Roles for Service Accounts), and OIDC support.

    IAM IRSA Roles:
    Creates IAM roles for AWS Load Balancer Controller and External DNS using a dedicated module based on terraform-aws-modules/iam/aws.
    Tip: Future enhancements will include centralized service account management for tighter integration.

    ACM Certificate:
    Provisions an ACM certificate with DNS validation via Route 53. A valid hosted zone is required.

    Helm Releases:
    Installs key Kubernetes add-ons (AWS LB Controller, External DNS, AWS Node Termination Handler) using a Helm module. Helm charts reference pre‑created service accounts (or, in future, ones managed by Terraform) to ensure consistency.

    Setup Script:
    The setup.sh script retrieves Route 53 hosted zone info, generates generated.auto.tfvars and trust policy files, and creates (if needed) and assumes a TerraformExecutionRole to export temporary credentials.

How It Works

    Setup: Run ./setup.sh to auto‑generate required variables, trust policies, and assume a Terraform execution role.
    Provisioning: Execute terraform init, then terraform plan and terraform apply to create the VPC, EKS cluster, IAM IRSA roles, ACM certificate, and deploy Helm charts.
    Deployment: Helm charts reference the pre‑configured service accounts (via IRSA) so that add-on deployments remain consistent.

Prerequisites

    An AWS account with a configured hosted zone (Route 53)
    AWS CLI, Terraform (>=1.0), kubectl, Helm, and jq installed
    Appropriate AWS credentials (or a configured AWS profile)