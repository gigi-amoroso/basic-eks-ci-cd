still under development
# Terraform EKS Infrastructure
This repository provisions an Amazon EKS cluster along with supporting components using Terraform. It includes:
- **EKS Module:** Creates an EKS cluster (with a VPC created via the [terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/terraform-aws-vpc) and [terraform-aws-modules/eks/aws](https://github.com/terraform-aws-modules/terraform-aws-eks) modules).
- **IAM IRSA Module:** Creates IAM roles for the AWS Load Balancer Controller and External DNS via IRSA.
- **ACM Module:** Provisions an ACM certificate with DNS validation (using Route 53).
- **Helm Module:** Installs helm charts for:
  - AWS Load Balancer Controller
  - External DNS
  - AWS Node Termination Handler