output "ec2_instance_id" {
  value=aws_instance.target.id
}

output "sns_topic_arn" {
  value=aws_sns_topic.alerts.arn
}

output "lambda_name" {
  value=aws_lambda_function.reboot.function_name
}

output "lambda_function_url" {
  value=aws_lambda_function_url.reboot_url.function_url
}