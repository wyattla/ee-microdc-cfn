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

  value :Description => 'IAM Policy DEFAULT'

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

  parameter 'Role',
    :Description => 'The bucket name',
    :Type => 'String',
    :ConstraintDescription => 'must contain only alphanumeric characters.'

  # Include Mappings under maps/*

  Dir[File.join(File.expand_path(File.dirname($PROGRAM_NAME)), 'maps', '*')].each do |map|
    eval File.read(map)
  end

  # Resource creation

  resource 'S3IAMPolicy',
    :Type => 'AWS::IAM::Policy',
    :Properties => {
      :PolicyName => "S3Ansible",
      :Roles => [ ref('Role') ],
      :PolicyDocument => {
        :Version => "2012-10-17",
        :Statement => [ {
          :Effect => "Allow",
          :Action => [ 
            "s3:Get*" 
          ],
          :Resource => [ 
            join("","arn:aws:s3:::",ref("BucketName"),'/',
                 join("/",ref('Application'),ref('EnvironmentName'),
                      'ansible',join("","ansible-playbook-",ref("AnsibleRole"),'.tar.gz'))),
            join("","arn:aws:s3:::",ref("BucketName"),'/',
                 join("/",ref('Application'),ref('EnvironmentName'),'ansible','version'))
          ]
        } ]
      },
    }

  resource 'DTIAMPolicy',
    :Type => 'AWS::IAM::Policy',
    :Properties => {
      :PolicyName => "DescribeTags",
      :Roles => [ ref('Role') ],
      :PolicyDocument => {
        :Version => "2012-10-17",
        :Statement => [ {    
          :Effect => "Allow",
          :Action => [
            "ec2:DescribeTags",
            "ec2:CreateTags",
          ],
          :Resource => ["*"]
        } ]
      },
    }

end.exec!
