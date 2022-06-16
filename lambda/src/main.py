import boto3
import json

asg = boto3.client('autoscaling', region_name='us-west-2')
asg_name = "ec2-scale-by-trigger-dev-test"


def handler(event, context):
    
    # print(f"{event}")
    
    new_desired_count = int(event['Records'][0]['body'])

    current_asg = asg.describe_auto_scaling_groups(
        AutoScalingGroupNames=[
        asg_name,
        ]
    )

    current_desired_count = int(current_asg['AutoScalingGroups'][0]['DesiredCapacity'])

    if new_desired_count == 0:
        asg.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=new_desired_count
        )
    elif new_desired_count < 0:
        asg.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=current_desired_count-1
        )
    elif new_desired_count > 0:
        asg.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=current_desired_count+1
        )        
