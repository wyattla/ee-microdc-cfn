# Total CIDR provisioned for this service:
#
# 10.183.144.0/21 => production
#
# 10.183.152.0/21 => non production
#   10.183.152.0/23 => DEV VPC
#   10.183.154.0/23 => SIT VPC
#   10.183.156.0/23 => CERT VPC
#   10.183.158.0/23 => TEST VPC

mapping 'MICRODC',
  :VPC        => { :CIDR => '10.152.152.0/23' },
  :PublicAZ1  => { :CIDR => '10.152.152.0/25' },
  :PublicAZ2  => { :CIDR => '10.152.152.128/25' },
  :PrivateAZ1 => { :CIDR => '10.152.153.0/25' },
  :PrivateAZ2 => { :CIDR => '10.152.153.128/25' }

