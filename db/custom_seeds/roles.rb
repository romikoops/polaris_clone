# frozen_string_literal: true

puts 'Seeding Roles...'

%w(admin shipper super_admin sub_admin agent agency_manager).each do |role|
  Role.find_or_create_by(name: role)
end
