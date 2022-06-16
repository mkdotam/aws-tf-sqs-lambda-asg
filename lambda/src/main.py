import boto3
import json

asg = boto3.client('autoscaling', region_name='us-west-2')
asg_arn = "ec2-scale-by-trigger-dev-test"


def handler(event, context):
    
    new_desired_count = event['Records'][0]['body']

    asg.update_auto_scaling_group(
        AutoScalingGroupName=asg_arn,
        DesiredCapacity=new_desired_count,
    )
