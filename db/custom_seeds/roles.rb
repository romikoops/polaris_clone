# frozen_string_literal: true

# Create user roles
%w[admin shipper super_admin sub_admin].each do |role|
  Role.find_or_create_by(name: role)
end
