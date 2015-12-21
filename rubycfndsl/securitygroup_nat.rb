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

  value :Description => 'Security Group for NAT'

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

  parameter 'Purpose',
    :Description => 'Instance Purpose',
    :Type => 'String',
    :ConstraintDescription => 'must contain only alphanumeric characters.',
    :AllowedPattern => '[a-zA-Z0-9]*'

  # Include Mappings under maps/*

  Dir[File.join(File.expand_path(File.dirname($PROGRAM_NAME)), 'maps', '*')].each do |map|
    eval File.read(map)
  end

  # Resource creation

  resource 'SecurityGroup',
    :Type => 'AWS::EC2::SecurityGroup',
    :Properties => {
      :GroupDescription => join(' ', 'Security Group for', ref('Purpose'), ' - ', ref('Application')),
      :VpcId => ref('VPC'),
      :SecurityGroupIngress => [
        { 'IpProtocol' => '-1', 'FromPort' => '-1', 'ToPort' => '-1', 'CidrIp' => find_in_map(ref('EnvironmentName'),'VPC','CIDR') },
      ],
      :Tags => [
        { :Key => 'Name', :Value => join('-', ref('Application'), ref('EnvironmentName'), 'sg', ref('Purpose')) },
        { :Key => 'Environment', :Value => ref('EnvironmentName') },
        { :Key => 'Application', :Value => ref('Application') },
        { :Key => 'Purpose', :Value => ref('Purpose') }
      ]
    }

  output 'SecurityGroup',
    :Value => ref('SecurityGroup'),
    :Description => 'Security Group Id'

end.exec!
