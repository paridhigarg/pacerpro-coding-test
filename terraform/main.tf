terraform{
  required_version =">=1.5.0"
  required_providers {
    aws={
      source="hashicorp/aws"
      version=">= 2.4"
    }
  }
}

provider "aws" {
  region=var.aws_region
}

data "aws_vpc" "default" {
  default =true
}

data "aws_subnets" "default" {
  filter{
    name = "vpc-id"
    values=[data.aws_vpc.default.id]
  }
}

resource "aws_sns_topic" "alerts" {
  name = "performance-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.sns_email == "" ? 0:1
  topic_arn=aws_sns_topic.alerts.arn
  protocol="email"
  endpoint=var.sns_email
}

resource "aws_security_group" "ec2_sg" {
  name = "sumo-reboot-ec2-sg"
  description = "Security group for terraform ec2"
  vpc_id=data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.my_ip_cidr =="" ? [] :[1]
    content {
      description = "SSH from my IP"
      from_port=22
      to_port=22
      protocol="tcp"
      cidr_blocks=[var.my_ip_cidr]
    }
  }

  egress {
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
  }
}

resource "aws_instance" "target" {
  ami = var.ami_id
  instance_type=var.instance_type
  subnet_id=element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids=[aws_security_group.ec2_sg.id]
  associate_public_ip_address=true

  tags={
    Name="sumo-reboot-target"
  }
}

data "archive_file" "lambda_zip" {
  type="zip"
  source_dir="${path.module}/lambda_src"
  output_path="${path.module}/lambda_package.zip"
}

resource "aws_iam_role" "lambda_role" {
  name="sumo-ec2-reboot-lambda-role"

  assume_role_policy=jsonencode({
    Version="2012-10-17"
    Statement=[{
      Effect="Allow",
      Principal={Service="lambda.amazonaws.com"},
      Action="sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role=aws_iam_role.lambda_role.name
  policy_arn="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "least_privilege" {
  name="sumo-reboot-least-privilege"
  role=aws_iam_role.lambda_role.id

  policy=jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Sid="RebootOnlyTaggedInstances",
        Effect="Allow"
        Action=["ec2:RebootInstances"],
        Resource="*",
        Condition={
          StringEquals = {
            "ec2:ResourceTag/Name" = "sumo-reboot-target"
          }
        }
      },
      {
        Sid="PublishOnlyToThisTopic",
        Effect="Allow"
        Action=["sns:Publish"],
        Resource=aws_sns_topic.alerts.arn
      }
    ]
  })
}

resource "aws_lambda_function" "reboot" {
  function_name="sumo-ec2-reboot"
  role=aws_iam_role.lambda_role.arn
  handler="lambda_function.lambda_handler"
  runtime="python3.12"

  filename=data.archive_file.lambda_zip.output_path
  source_code_hash=data.archive_file.lambda_zip.output_base64sha256

  timeout=30
  memory_size=128

  environment{
    variables={
      INSTANCE_ID = aws_instance.target.id
      SNS_TOPIC_ARN=aws_sns_topic.alerts.arn
    }
  }
}

resource "aws_lambda_function_url" "reboot_url" {
  function_name=aws_lambda_function.reboot.function_name
  authorization_type="NONE"
}

resource "aws_lambda_permission" "public_invoke_url" {
  statement_id="AllowPublicInvokeFunctionUrl"
  action="lambda:InvokeFunctionUrl"
  function_name=aws_lambda_function.reboot.function_name
  principal="*"
  function_url_auth_type="NONE"
}

