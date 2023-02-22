#!/bin/bash
vpc_id="vpc-061aceae602c16ed9"

# aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep InternetGatewayId
# aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$vpc | grep SubnetId
# aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc | grep RouteTableId
# aws ec2 describe-network-acls --filters 'Name=vpc-id,Values='$vpc | grep NetworkAclId
# aws ec2 describe-vpc-peering-connections --filters 'Name=requester-vpc-info.vpc-id,Values='$vpc | grep VpcPeeringConnectionId
# aws ec2 describe-vpc-endpoints --filters 'Name=vpc-id,Values='$vpc | grep VpcEndpointId
# aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values='$vpc | grep NatGatewayId
# aws ec2 describe-security-groups --filters 'Name=vpc-id,Values='$vpc | grep GroupId
# aws ec2 describe-instances --filters 'Name=vpc-id,Values='$vpc | grep InstanceId
# aws ec2 describe-vpn-connections --filters 'Name=vpc-id,Values='$vpc | grep VpnConnectionId
# aws ec2 describe-vpn-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep VpnGatewayId
# aws ec2 describe-network-interfaces --filters 'Name=vpc-id,Values='$vpc | grep NetworkInterfaceId

while read -r sg ; do
    # check albs using this security group
    # aws elbv2 describe-load-balancers
    aws ec2 describe-network-interfaces --filters "Name=group-id, Values=$sg"|jq -r '.NetworkInterfaces[].NetworkInterfaceId'

    cmd="aws ec2 delete-security-group --group-id $sg"
    sh -c "echo '$cmd';$cmd"
done < <(aws ec2 describe-security-groups --filters 'Name=vpc-id,Values='$vpc_id \
    | jq -r '.SecurityGroups[].GroupId')

while read -r instance_id ; do
    cmd="aws ec2 terminate-instances --instance-ids $instance_id"
    sh -c "echo '$cmd';$cmd"
done < <(aws ec2 describe-instances --filters 'Name=vpc-id,Values='$vpc_id \ | jq -r '.Reservations[].Instances[].InstanceId')


while read -r rt_id ; do
    cmd="aws ec2 delete-route-table --route-table-id $rt_id"
    sh -c "echo '$cmd';$cmd"
done < <(aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc_id | \
    jq -r ".RouteTables[].RouteTableId")

while read -r ig_id ; do
    cmd="aws ec2 detach-internet-gateway --internet-gateway-id $ig_id --vpc-id $vpc_id"
    sh -c "echo '$cmd';$cmd"
done < <(aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc_id  \
    | jq -r ".InternetGateways[].InternetGatewayId")

while read -r ig_id ; do
    cmd="aws ec2 delete-internet-gateway --internet-gateway-id $ig_id --vpc-id $vpc_id"
    sh -c "echo '$cmd';$cmd"
done < <(aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc_id  \
    | jq -r ".InternetGateways[].InternetGatewayId")

# delete all vpc subnets
while read -r subnet_id ; do
    cmd="aws ec2 delete-subnet --subnet-id $subnet_id"
    sh -c "echo '$cmd';$cmd"
done < <(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$vpc_id | jq -r '.Subnets[].SubnetId')

# delete the whole vpc
aws ec2 delete-vpc --vpc-id=$vpc_id
