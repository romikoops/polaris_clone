Tenant.all.each do |tenant|
  # Create admin
  # admin = tenant.users.new(
  #   role: Role.find_by_name('admin'),

  #   company_name: tenant.name,
  #   first_name: "Admin",
  #   last_name: "Admin",
  #   phone: "123456789",

  #   email: "admin@#{tenant.subdomain}.com",
  #   password: "demo123456789",
  #   password_confirmation: "demo123456789",

  #   confirmed_at: DateTime.new(2017, 1, 20)
  # )
  # # admin.skip_confirmation!
  # admin.save!
  sub_admin = tenant.users.new(
    role: Role.find_by_name('sub_admin'),

    company_name: tenant.name,
    first_name: "Sub",
    last_name: "Admin",
    phone: "123456789",

    email: "subadmin@#{tenant.subdomain}.com",
    password: "demo123456789",
    password_confirmation: "demo123456789",

    confirmed_at: DateTime.new(2017, 1, 20)
  )
  sub_admin.save!
end
