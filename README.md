# Atlan Secure Agent Terraform Deployment

This repository provides Terraform scripts to deploy the Atlan Secure Agent into an existing AWS EKS cluster using Helm and Kubernetes providers.

## Prerequisites

Before you begin, ensure you have the following:

- **An existing AWS EKS cluster** (see [eks-terraform](../eks-terraform) or AWS documentation for setup)
- **kubectl** configured for your EKS cluster
- **AWS CLI** installed and configured with sufficient permissions
- **Terraform** (version matching your `versions.tf` constraints)
- **Helm** (for troubleshooting or manual operations)
- S3 bucket and credentials (if using S3 integration)

## Required Terraform Variables

You must provide the following variables (see `variables.tf` for all options):

| Variable             | Type    | Description                                 |
|----------------------|---------|---------------------------------------------|
| `region`             | string  | AWS region of your EKS cluster              |
| `cluster_name`       | string  | Name of your EKS cluster                    |
| `atlan_domain`       | string  | Atlan instance domain                       |
| `atlan_token`        | string  | Atlan API token                             |
| `agent_name`         | string  | Name for the secure agent                   |
| `s3-credentials`     | object  | S3 credentials (`accesskey`, `secretkey`)   |
| `s3_bucket_name`     | string  | Name of the S3 bucket (if used)             |
| `deployment_stage`   | string  | Must be `install`, `upgrade`, or `uninstall`|

You can use `terraform.tfvars` or set these via CLI/environment.

## Deployment Stages

**You must run Terraform apply twice:**

1. **Install Stage:**  
   For the install, you can either:
   - Provide the variable on the command line:
     ```bash
     terraform apply -var="deployment_stage=install"
     ```
   - Or, if you do not provide `deployment_stage`, Terraform will prompt you for it interactively during `terraform apply`.
   This will install the agent and create initial resources.

2. **Upgrade Stage:**  
   For the upgrade, you can either:
   - Provide the variable on the command line:
     ```bash
     terraform apply -var="deployment_stage=upgrade"
     ```
   - Or, if you do not provide `deployment_stage`, Terraform will prompt you for it interactively during `terraform apply`.

   This will perform any necessary upgrades and finalize the deployment.

> **Why two stages?**  
> Some resources (like Helm releases and Kubernetes secrets) require an initial install before they can be upgraded or fully configured. This two-step process ensures a reliable deployment.

## Usage

1. **Clone the repository:**
   ```bash
   git clone <this-repo-url>
   cd atlan-secure-agent
   ```

2. **Configure your variables:**
   - Copy `terraform.tfvars.sample` to `terraform.tfvars` and edit as needed.
   - Set all required variables, including `region`, `cluster_name`, `atlan_domain`, `atlan_token`, `agent_name`, `s3-credentials`, `s3_bucket_name`, and `deployment_stage`.

3. **Run Terraform (Install Stage):**
   - Either provide the variable on the command line:
     ```bash
     terraform apply -var="deployment_stage=install"
     ```
   - Or, if you do not provide `deployment_stage`, Terraform will prompt you for it interactively during `terraform apply`.
   Confirm the apply when prompted.

4. **Run Terraform again for Upgrade Stage:**
   - Either provide the variable on the command line:
     ```bash
     terraform apply -var="deployment_stage=upgrade"
     ```
   - Or, if you do not provide `deployment_stage`, Terraform will prompt you for it interactively during `terraform apply`.
   Confirm the apply when prompted.

5. **Verify Deployment:**
   - Check the agent pod status in your EKS cluster:
     ```bash
     kubectl get pods -n argo-workflows
     ```

## Outputs

- The deployment may output connection details or resource names as defined in `outputs.tf`.

## Troubleshooting

- Ensure your AWS credentials and `kubectl` context are set for the target EKS cluster.
- If you see errors about missing resources, ensure the EKS cluster and required namespaces exist.
- For Helm or Kubernetes resource errors, try running `terraform apply` again after resolving any issues.

## Cleanup

To remove all resources created by this module:
- Either provide the variable on the command line:
  ```bash
  terraform destroy -var="deployment_stage=unintstall"
  ```
- Or, if you do not provide `deployment_stage`, Terraform will prompt you for it interactively during `terraform destroy`.

## Security Notes

- Do **not** commit sensitive values (like API tokens or S3 credentials) to version control.
- Review IAM permissions and restrict them to the minimum required.

## Contributing

- Please update this README if you add new variables or change the deployment process.
- Test changes in a non-production environment first.

---

**For more details, see the comments in each `.tf` file.**