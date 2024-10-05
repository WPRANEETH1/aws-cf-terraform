### (1) Apply infrastructure using Terraform 
`terraform init`  
`terraform apply`

### (2) This Terraform code includes the following AWS services:
- `AWS RDS MariaDB (Read and Write replicas)`
- `AWS EC2 Application Server`
- `AWS SSM Jump Server for connecting with RDS DB and EC2 Server`
- `Network Load Balancer (NLB) for exposing the EC2 service to CloudFront`
- `Two public and two private subnets with NAT Gateway for internet access in private subnets`

### (3) Network Setup
- Access from the NLB to the EC2 Application Server is established.
- SSM Jump Server is configured to access both the EC2 Server and RDS Database.

### Output
After running the Terraform code, the following output will be provided:
- URLs to access the CloudFront distribution and EC2 Application Server.

You can verify RDS DB and Server access using the provided output URLs.