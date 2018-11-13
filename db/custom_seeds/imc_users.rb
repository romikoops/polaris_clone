Tenant.all.each do |tenant|
  admin_user = tenant.users.find_by(email: 'shopadmin@itsmycargo.com')
  if !admin_user
    tenant.users.create!(
      role: Role.find_by_name('admin'),

      company_name: 'ItsMyCargo GmbH',
      first_name: 'IMC',
      last_name: 'Admin',
      phone: '123456789',

      email: "shopadmin@itsmycargo.com",
      password: 'IMC123456789',
      password_confirmation: 'IMC123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )
  end
  shipper_user = tenant.users.find_by(email: 'shipper@itsmycargo.com')
  if !shipper_user
    tenant.users.create!(
      role: Role.find_by_name('shipper'),

      company_name: 'ItsMyCargo GmbH',
      first_name: 'IMC',
      last_name: 'Shipper',
      phone: '123456789',
      email: "shipper@itsmycargo.com",
      password: 'IMC123456789',
      password_confirmation: 'IMC123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )
  end
end