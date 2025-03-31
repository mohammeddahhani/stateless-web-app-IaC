# stateless-web-app-IaCL: AWS Infrastructure Deployment
A terraform deployment to host a stateless containerized application 
 
## Requirements
- **Terraform**: Ensure Terraform is installed and configured.
- **Service Account Credentials**:
  - Create an **IAM User** with programmatic access.
  - Generate and securely store **AWS Access Key ID** and **Secret Access Key**.
  - set credentials under **./.aws/credentials**.
- **Service Account Permissions**:
  - In total, the following permissions are needed: **AmazonEC2FullAccess**, **AWSCertificateManagerFullAccess** and **IAMFullAccess**

## Deployment Overview

![Architecture](images/architecture.png)

### 1. Load Balancer for High Availability
- Application is deployed behind an **Application Load Balancer (ALB)**.
- Uses **two public and two private subnets** across different availability zones.

### 2. Secure Network Hosting
- **Security groups** restrict access to only required traffic.
- **EC2 instances** allow inbound traffic only from ALB and SSH access via Bastion.

### 3. Secure SSH Access
- **Bastion host** deployed in a public subnet for controlled SSH access to private EC2 instances.

### 4. Service Accounts & Permissions
- IAM roles and policies are attached to instances for secure AWS resource access.

### 5. Web Application Security
- **HTTPS** enabled via AWS Certificate Manager (ACM).
- **Web Application Firewall (WAF)** for added protection.

### 6. Network Segmentation
- **VPC with public and private subnets**.
- **NAT Gateway** for private subnets to access the internet without exposure.

## How to Deploy
1. **Clone the repository**:
   ```sh
   git clone <repository-url>
   cd <project-directory>
   ```
2. **Configure AWS Credentials** under ./.aws/credentials*:
   ```sh
	[default]
	aws_access_key_id = 
	aws_secret_access_key = 

   ```
3.1 **Initialize Terraform**:
   ```sh
   terraform init
   ```
3.2 **Update terraform.vartf with the *public_key_path* and eventually
   ```sh
   terraform init
   ```
4. **Plan the deployment**:
   ```sh
   terraform plan
   ```
5. **Apply the deployment**:
   ```sh
   terraform apply -auto-approve
   ```
6. **Access the Application**:
   - Retrieve the ALB DNS name using:
     ```sh
     terraform output alb_dns_name
     ```
   - Open the DNS name in a browser to access the web app securely over HTTPS.

 - Access the jumpstation via SSH using the private key:
     ```sh
     terraform output alb_dns_name
     ```

## Cleanup
To destroy all deployed resources:
```sh
terraform destroy -auto-approve
```

