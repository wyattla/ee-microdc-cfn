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

  value :Description => 'Role Access for NAT'

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

  parameter 'BucketName',
    :Description => 'The application Name',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64'
  
  parameter 'AnsibleRole',
    :Description => 'The application Name',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64'

  parameter 'Category',
    :Description => 'Category for billing purpose',
    :Type => 'String',
    :MinLength => '1',
    :MaxLength => '64',
    :AllowedPattern => '[a-zA-Z0-9-\.]*',
    :ConstraintDescription => 'must begin with a letter and contain only alphanumeric characters.'

  # Include Mappings under maps/*
  
  Dir[File.join(File.expand_path(File.dirname($0)),'maps','*')].each do |map|
    eval File.read(map)
  end

  # Resource creation

  resource "JenkinsIAMRole",
    :Type =>"AWS::IAM::Role",
    :Properties => {
      :AssumeRolePolicyDocument => {
        :Version => "2012-10-17",
        :Statement => [ {
          :Effect =>"Allow",
          :Principal => {
            :Service => [ "ec2.amazonaws.com" ]
          },
          :Action =>[ "sts:AssumeRole" ]
        } ]
      },
      :Path =>"/",
    }

  resource "DefaultIAMPolicy",
    :Type => "AWS::CloudFormation::Stack",
    :Properties => {
      :TemplateURL => join("/","https://s3.amazonaws.com",ref('BucketName'),ref('Application'),
                           ref('EnvironmentName'),'cloudformation','policy_default.template'),
      :Parameters => {
        :EnvironmentName => ref('EnvironmentName'),
        :Application => ref('Application'),
        :BucketName => ref('BucketName'),
        :AnsibleRole => ref('AnsibleRole'),
        :Role => ref('JenkinsIAMRole'),
      }
    }


  output 'IAMRole',
    :Value => ref('JenkinsIAMRole'),
    :Description => 'The access profile Id for Jenkins'

end.exec!
