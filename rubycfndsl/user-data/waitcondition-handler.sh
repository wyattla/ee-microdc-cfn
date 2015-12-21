################################################################################
# Waitcondition handle

curl -X PUT \
     -H 'Content-Type:' \
     --data-binary '{"Status" : "SUCCESS","Reason" : "Configuration Complete","UniqueId" : "ID1234","Data" : "Application has completed configuration."}' \
     "{{ ref('WaitHandle') }}"
