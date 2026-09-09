# Secure Automated Web Architecture

## Description

This project deploys a secure web server infrastructure in AWS using Terraform as Infrastructure as Code (IaC). A GitHub Actions CI/CD security pipeline scans the Terraform configuration with tfsec before deployment, helping identify security issues before infrastructure is deployed.

## Technologies Used

- AWS
- Terraform
- GitHub Actions
- tfsec
- Amazon EC2
- Amazon VPC

## Architecture

The infrastructure uses a custom AWS VPC with a public subnet connected to an Internet Gateway. A route table directs internet traffic through the gateway, allowing the EC2 web server to be publicly accessible.

A security group acts as the firewall for the EC2 instance. HTTP traffic is allowed on port 80 so users can access the web server, while SSH access on port 22 is restricted to a specific IP address rather than being open to the entire internet.

Terraform provisions the AWS infrastructure, including the VPC, subnet, Internet Gateway, route table, security group, and EC2 instance. The EC2 instance uses a user data script to automatically install and start the web server.

Before deployment, GitHub Actions runs a tfsec security scan against the Terraform configuration. The pipeline is configured to fail when security issues are detected, creating a security quality gate before deployment.
