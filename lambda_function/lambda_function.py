import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

INSTANCE_ID = os.environ["INSTANCE_ID"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event,context):
    logger.info("Received event: %s",json.dumps(event))

    try:
        ec2.reboot_instances(InstanceIds=[INSTANCE_ID])
        status="SUCCESS"
        message=f"EC2 instance{INSTANCE_ID}reboot initiated."
        logger.info(message)
    except Exception as e:
        status="FAILED"
        message=str(e)
        logger.error(message)

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"Sumo Alert -EC2 Reboot {status}",
        Message=json.dumps({
            "status":status,
            "instance_id":INSTANCE_ID,
            "event":event
        })
    )

    return{
        "statusCode":200,
        "body":message
    }