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


Testing note (Sumo not available):
The Lambda is designed to be triggered by the Sumo Logic alert payload. Because I did not have access to real Sumo Logic logs/alerts in this environment, I tested the Lambda using the AWS console “Test” event with a representative JSON payload ({"source":"manual-test"}). This validates the core requirements: the function triggers, reboots the target EC2 instance, and publishes a notification to SNS. In a real setup, Sumo would invoke the Lambda via an alert action (e.g., webhook → API Gateway → Lambda), and the incoming alert JSON would appear in the event (or event["body"] for API Gateway proxy events)