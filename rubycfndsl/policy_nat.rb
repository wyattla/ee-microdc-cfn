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

  value :Description => 'IAM Policy for NAT'

  # Default Mandatory Parameters

  parameter 'Role',
    :Description => 'The bucket name',
    :Type => 'String',
    :ConstraintDescription => 'must contain only alphanumeric characters.',
    :AllowedPattern => '[a-zA-Z0-9-\.]*'
  
  # Include Mappings under maps/*
  
  Dir[File.join(File.expand_path(File.dirname($0)),'maps','*')].each do |map|
    eval File.read(map)
  end

  # Resource creation

  resource "NATIAMPolicy",
    :Type => "AWS::IAM::Policy",
    :Properties => {
      :PolicyName => "NatHA",
      :Roles => [ ref('Role') ],
      :PolicyDocument => {
        :Version => "2012-10-17",
        :Statement => [ {
          :Effect => "Allow",
          :Resource => "*",
          :Action => [ 
            "ec2:DescribeInstances",
            "ec2:DescribeRouteTables",
            "ec2:CreateRoute",
            "ec2:ReplaceRoute",
            "ec2:StartInstances",
            "ec2:StopInstances"
          ],
        } ]
      },
    }

  output 'IAMPolicy',
    :Value => ref('NATIAMPolicy'),
    :Description => 'The access profile Id for nat'

end.exec!
