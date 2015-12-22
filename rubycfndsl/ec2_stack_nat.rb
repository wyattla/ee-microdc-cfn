#!/usr/bin/env ruby

# Standard cfn-ruby libraries:
require 'pry'
require 'bundler/setup'
require 'cloudformation-ruby-dsl/cfntemplate'
require 'cloudformation-ruby-dsl/spotprice'
require 'cloudformation-ruby-dsl/table'

template do

  # Format Version:
  
  value :AWSTemplateFormatVersion => '2010-09-09'

  # Description:

  value :Description => 'EC2 Instance'

  # Default Mandatory Parameters

  parameter 'EnvironmentName',
    :Description => 'The environment Name',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64',
    :AllowedPattern => '[a-zA-Z][a-zA-Z0-9]*',
    :ConstraintDescription => 'must begin with a letter and contain only alphanumeric characters.'

  parameter 'Application',
    :Description => 'The Project Name',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64',
    :AllowedPattern => '[a-zA-Z][a-zA-Z0-9]*',
    :ConstraintDescription => 'must begin with a letter and contain only alphanumeric characters.'

  parameter 'VPC',
    :Description => 'The VPC Id',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64',
    :AllowedPattern => 'vpc-[a-zA-Z0-9]*',
    :ConstraintDescription => 'must begin with vpc- and contain only alphanumeric characters.'

  # Specific parameters

  parameter 'SubnetId',
    :Description => 'The subnet Id',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64',
    :AllowedPattern => 'subnet-[a-zA-Z0-9]*',
    :ConstraintDescription => 'must begin with subnet- and contain only alphanumeric characters.'

  parameter 'ImageId',
    :Description => 'The AMI Id',
    :Type => 'String',
    :ConstraintDescription => 'must begin with ami- and contain only alphanumeric characters.',
    :AllowedPattern => 'ami-[a-zA-Z0-9]*'

  parameter 'InstanceType',
    :Description => 'EC2 instance type"',
    :Type => 'String',
    :AllowedValues => [ "t2.micro", "m1.small", "m1.medium", "m1.large", "m1.xlarge", "m2.xlarge", "m2.2xlarge", 
                        "m2 .4xlarge", "c1.medium", "c1.xlarge", "hi1.4xlarge", "hs1.8xlarge", "m3.medium",
                        "m3.large", "m3.xlarge", "m3.2xlarge", "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge",
                        "c3.8xlarge" ]

  parameter 'KeyName',
    :Description => 'Key pair name',
    :Type => 'String',
    :ConstraintDescription => 'must contain only alphanumeric characters.',
    :AllowedPattern => '[a-zA-Z0-9]*'

  parameter 'Purpose',
    :Description => 'Instance Purpose',
    :Type => 'String'

  parameter 'BucketName',
    :Description => 'The bucket name',
    :Type => 'String',
    :ConstraintDescription => 'must contain only alphanumeric characters.',
    :AllowedPattern => '[a-zA-Z0-9-\.]*'

  parameter 'AnsibleRole',
    :Description => 'The bucket name',
    :Type => 'String',
    :ConstraintDescription => 'must contain only alphanumeric characters.',
    :AllowedPattern => '[a-zA-Z0-9-\.]*'

  parameter 'Role',
    :Description => 'A Role reference',
    :Type => 'String'

  parameter 'SecurityGroup',
    :Description => 'A Role reference',
    :Type => 'CommaDelimitedList'

  # Include Mappings under maps/*
  
  Dir[File.join(File.expand_path(File.dirname($0)),'maps','*')].each do |map|
    eval File.read(map)
  end

  # Resource creation

  resource 'IAMInstanceProfile',
    :Type => "AWS::IAM::InstanceProfile",
    :Properties => {
      :Path => "/",
      :Roles => [ ref('Role') ]
    }

  resource :EC2Instance,
    :Type => "AWS::EC2::Instance",
    :Properties => {
      :InstanceType => ref("InstanceType"),
      :KeyName => ref('KeyName'),
      :IamInstanceProfile => ref('IAMInstanceProfile'),
      :ImageId => ref('ImageId'),
      :SourceDestCheck => "false",
      :NetworkInterfaces => [ {
        :GroupSet => ref("SecurityGroup"),
        :AssociatePublicIpAddress => "true",
        :DeviceIndex => "0",
        :DeleteOnTermination => "true",
        :SubnetId => ref("SubnetId")
      } ],
      :Tags => [ 
        { :Key => 'Name', :Value => join('-',ref('Application'),ref('EnvironmentName'),'ec2',ref('AnsibleRole')) }, 
        { :Key => 'Environment', :Value => ref('EnvironmentName') }, 
        { :Key => 'AnsibleRole', :Value => ref('AnsibleRole')}, 
        { :Key => 'Application', :Value => ref('Application') }, 
        { :Key => 'Purpose', :Value => ref('Purpose') }, 
        { :Key => 'BucketName', :Value => ref('BucketName') },
      ],
      #:UserData => base64(interpolate(file('user-data/redhat-bootstrap.sh') + file('user-data/waitcondition-handler.sh')))
    }

    # resource 'WaitHandle',
    #   :Type => "AWS::CloudFormation::WaitConditionHandle"

    # resource 'WaitCondition',
    #   :Type => "AWS::CloudFormation::WaitCondition",
    #   :DependsOn => "EC2Instance",
    #   :Properties => {
    #     :Handle => ref('WaitHandle'),
    #     :Timeout => "500"
    #   }

    output 'EC2Instance',
      :Value => ref('EC2Instance'),
      :Description => ' Instance Id'

    output 'PublicIp',
      :Value => get_att('EC2Instance','PublicIp'),
      :Description => 'Instance public ip address'

end.exec!
