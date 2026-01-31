# Sumo Logic EC2 Auto-Reboot System

This repository implements an automated remediation workflow where
Sumo Logic alerts trigger an AWS Lambda function to reboot an EC2
instance and send notifications via SNS.

## Components
- Sumo Logic log query and alert
- AWS Lambda (Python)
- Amazon EC2
- Amazon SNS
- Terraform (Infrastructure as Code)

## Repository Structure
# pacerpro-coding-test
Automated EC2 reboot using Sumo Logic alerts, AWS Lambda, SNS, and Terraform

.
├── sumo_logic_query.txt
├── lambda_function/
│   ├── lambda_function.py
│   └── requirements.txt
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── lambda_src/
        └── lambda_function.py


