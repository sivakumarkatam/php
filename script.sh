ROLE_SESSION_NAME="dev"
TMP_FILE=".temp_credentials"
AssumeRole="arn:aws:iam::060823782989:role/DevOpsCrossAccountTrust"

aws sts assume-role --output json --role-arn ${AssumeRole} --role-session-name ${ROLE_SESSION_NAME} > ${TMP_FILE}
 
ACCESS_KEY=$(cat ${TMP_FILE} | jq -r ".Credentials.AccessKeyId")
SECRET_KEY=$(cat ${TMP_FILE} | jq -r ".Credentials.SecretAccessKey")
SESSION_TOKEN=$(cat ${TMP_FILE} | jq -r ".Credentials.SessionToken")
EXPIRATION=$(cat ${TMP_FILE} | jq -r ".Credentials.Expiration")
 
echo "Retrieved temp access key ${ACCESS_KEY} for role ${ASSUME_ROLE}. Key will expire at ${EXPIRATION}"
 
AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} ${CMD}

## If Condition for Applciation Name and HostID

Application_Name="Unicorn-Magento-${Bake}"
hostid="${Bake}"
Region="ap-southeast-1"
Vpcid="vpc-b9eabddd"
Subnetid="subnet-cc9e86a8"
#KMSkey="6775d859-9213-469a-a03a-f53b122e4037"
Launchconfigurationname="${Env}-magento-${Bake}-${BUILD_NUMBER}"
AutoscalinggroupName="${Env}-magento-${Bake}-${BUILD_NUMBER}"
KeyName="Unicorn-prodclone-kp"
SecurityGroupname="sg-acb5faca"
IAMInstanceprofilename="arn:aws:iam::060823782989:instance-profile/Unicorn-Magento-Admin-Portal-SingleEc2Profile-18KRH4TFR7GR7"
VpczoneName1="subnet-cc9e86a8"
VpczoneName2="subnet-4c777b3a"
InstanceKeyName="Name"
InstanceKeyValue="${Env}-Unicorn-magento-${Bake}-${BUILD_NUMBER}"
#SNSTopicARN="arn:aws:lambda:ap-southeast-1:074581774482:function:APG-Prod-CW-Alarm-Slack-Notifier"
serverdomainname="${domainname}"


echo "Hostname is $Application_Name and Host ID is $hostid"

echo "server domain name is $serverdomainname"
echo "server domain name is $domainname"

#sudo mkdir  /home/ubuntu/packer/${JOB_NAME}
sudo cp -r /home/ubuntu/workspace/${JOB_NAME}/* /home/ubuntu/packer/

echo "Accesskey is : ${ACCESS_KEY}"
echo "secretkey is : ${SECRET_KEY}"

sudo /home/ubuntu/packer/packer build -machine-readable -debug \
-var "aws_access_key=${ACCESS_KEY}" \
-var "aws_secret_key=${SECRET_KEY}" \
-var "aws_session_token=${SESSION_TOKEN}" \
-var "aws-region=${Region}" \
-var "aws-vpc_id=${Vpcid}" \
-var "aws-subnet_id=${Subnetid}" \
-var "kms_key_prod=${KMSkey}" \
-var "hostname=${Application_Name}" \
-var "hostid=${hostid}" \
-var "serverdomainname=${serverdomainname}" \
-var "Env=${Env}" \
/home/ubuntu/packer/BakeJobs/unicorn-magento-centos/GenericApplication.json 2>&1 | sudo tee /home/ubuntu/packer/output

cd /home/ubuntu/packer/

tail -2 output | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }' | sudo tee ami


#amiid=$(cat ami)
#below line is to EBS encryption AMI name is gettig /n in last
#awk '{print substr($0, 1, length($0)-2)}' ami | sudo tee amiids

#amiid=ami-aed240cd
amiid=$(cat ami)
echo "The ID is $amiid"


if [ "$withASG" = YES ]; then

   if [ "$CreateLC" = YES ]; then
      AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling create-launch-configuration --launch-configuration-name ${Launchconfigurationname} --region ${Region} --image-id ${amiid} --key-name ${KeyName} --instance-type c4.xlarge --security-groups ${SecurityGroupname} --iam-instance-profile ${IAMInstanceprofilename}
   fi

   if [ "$actionOnASG" = CREATE ]; then
      AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling create-auto-scaling-group --auto-scaling-group-name ${AutoscalinggroupName} --launch-configuration-name ${Launchconfigurationname} --region ${Region} --min-size 1 --max-size 1 --vpc-zone-identifier "${VpczoneName1},${VpczoneName2}" --health-check-type "ELB" --health-check-grace-period 300
      AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling create-or-update-tags --region ${Region} --tags "ResourceId=${AutoscalinggroupName},ResourceType=auto-scaling-group,Key=${InstanceKeyName},Value=${InstanceKeyValue},PropagateAtLaunch=true"
       
        sleep 20s

      # scale out policy
      #AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling put-scaling-policy --policy-name Scale-Out-Policy --auto-scaling-group-name ${AutoscalinggroupName} --scaling-adjustment 1 --adjustment-type ChangeInCapacity --cooldown 240 --region ap-southeast-1 --output text | sudo tee /home/ubuntu/arn
      #scale_out_arn=$(cat /home/ubuntu/arn)
      #echo "$scale_out_arn"

      # alarm for scale out
      #AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws cloudwatch put-metric-alarm --alarm-name APG-HighCPU-ScaleOut-Alarm${AutoscalinggroupName} --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 60 --threshold 65 --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=${AutoscalinggroupName}" --evaluation-periods 2 --alarm-actions $scale_out_arn --region ap-southeast-1

      # scale in policy
      #AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling put-scaling-policy --policy-name Scale-In-Policy --auto-scaling-group-name ${AutoscalinggroupName} --scaling-adjustment -1 --adjustment-type ChangeInCapacity  --cooldown 240 --region ap-southeast-1 --output text | sudo tee /home/ubuntu/scale_in_arn
      #scale_in_arn=$(cat /home/ubuntu/scale_in_arn)
      #echo "$scale_in_arn"

      # alarm for scale in
      #AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws cloudwatch put-metric-alarm --alarm-name APG-HighCPU-ScaleIn-Alarm${AutoscalinggroupName} --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 60 --threshold 30 --comparison-operator LessThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=${AutoscalinggroupName}" --evaluation-periods 3 --alarm-actions $scale_in_arn --region ap-southeast-1

#      AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws sns list-topics --region ap-southeast-1 | sudo tee /home/ubuntu/tes
 #     grep APG-Slack /home/ubuntu/tes | cut -d '"' -f4 | sudo tee /home/ubuntu/topic
  #    TopicARN=$(cat /home/ubuntu/topic)
     # TopicARN=$SNSTopicARN
      #echo "$TopicARN"

      #AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling put-notification-configuration --auto-scaling-group-name ${AutoscalinggroupName} --region ap-southeast-1 --topic-arn ${TopicARN} --notification-types "autoscaling:EC2_INSTANCE_LAUNCH" "autoscaling:EC2_INSTANCE_TERMINATE" "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
        
    elif [ "$actionOnASG" = UPDATE ]; then
      AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling update-auto-scaling-group --region ${Region} --auto-scaling-group-name ${ExistingAutoscalinggroupName} --launch-configuration-name ${Launchconfigurationname} --min-size 1 --max-size 1 --vpc-zone-identifier "${VpczoneName1},${VpczoneName2}"

    fi

   if [ "$UpdateELB" = YES ]; then
      if [ "$LoadBalancerType" = Classic ]; then
         AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling attach-load-balancers --auto-scaling-group-name ${AutoscalinggroupName} --region ${Region} --load-balancer-names ${LoadBalancerName}
       #AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling attach-load-balancer-target-groups --auto-scaling-group-name ${AutoscalinggroupName} --region ${Region} --target-group-arns ${targetARN}
      elif [ "$LoadBalancerType" = Application ]; then
         AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws autoscaling attach-load-balancer-target-groups --auto-scaling-group-name ${AutoscalinggroupName} --region ${Region} --target-group-arns ${targetARN}
      fi
      
   fi

   if [ "$UpdateCodeDeploy" = YES ]; then
      AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} aws deploy --region=${Region} update-deployment-group --application-name ${codedeploy_app_name} --auto-scaling-groups ${AutoscalinggroupName} --current-deployment-group-name ${codedeploy_group_name} --deployment-config-name CodeDeployDefault.AllAtOnce --ec2-tag-filters Key=Name,Type=KEY_AND_VALUE,Value=${InstanceKeyValue} --service-role-arn ${codedeploy_service_RoleARN}
   fi

fi	
