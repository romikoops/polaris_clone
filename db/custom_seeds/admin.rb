# frozen_string_literal: true

Tenant.all.each do |tenant|
  # Create admin
  tld = tenant.web && tenant.web['tld'] ? tenant.web['tld'] : 'com'
  admin_check = tenant.users.find_by(email: "admin@#{tenant.subdomain}.#{tld}")
  unless admin_check
    admin = tenant.users.new(
      role: Role.find_by_name('admin'),

      company_name: tenant.name,
      first_name: 'Admin',
      last_name: 'Admin',
      phone: '123456789',

      email: "admin@#{tenant.subdomain}.#{tld}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )
    # admin.skip_confirmation!
    admin.save!
  end
  sub_admin_check = tenant.users.find_by(email: "subadmin@#{tenant.subdomain}.#{tld}")
  next if sub_admin_check
  sub_admin = tenant.users.new(
    role: Role.find_by_name('sub_admin'),

    company_name: tenant.name,
    first_name: 'Sub',
    last_name: 'Admin',
    phone: '123456789',

    email: "subadmin@#{tenant.subdomain}.#{tld}",
    password: 'demo123456789',
    password_confirmation: 'demo123456789',

    confirmed_at: DateTime.new(2017, 1, 20)
  )
  sub_admin.save!
end
