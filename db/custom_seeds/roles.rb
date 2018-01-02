# Create user roles
['admin', 'shipper'].each do |role|
  Role.find_or_create_by({name: role})
end