# frozen_string_literal: true

class SuperAdminSeeder
  def self.perform
    puts 'Seeding Super Admin...'
    tenant = Tenant.find_by(subdomain: 'demo')

    if tenant.nil?
      puts "Cannot seed super admin without tenant 'demo'".red
      return
    end

    super_admin_demo = Tenant.find_by_subdomain('demo').users.new(
      role: Role.find_by_name('super_admin'),

      company_name: 'ItsMyCargo',
      first_name: 'Someone',
      last_name: 'Staff',
      phone: '123456789',

      email: 'info@itsmycargo.com',
      password: 'stafflogin1',
      password_confirmation: 'stafflogin1',

      confirmed_at: DateTime.new(2017, 1, 20)
    )

    puts 'Super Admin already existed'.yellow unless super_admin_demo.save
  end
end
