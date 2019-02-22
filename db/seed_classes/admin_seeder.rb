# frozen_string_literal: true

class AdminSeeder
  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      next unless find_admin_for_tenant(tenant).nil?

      new_admin(tenant).save!

      next unless find_sub_admin_for_tenant(tenant).nil?

      new_sub_admin(tenant).save!
    end
  end

  private

  def self.tld(tenant)
    tenant.web && tenant.web['tld'] ? tenant.web['tld'] : 'com'
  end

  def self.find_admin_for_tenant(tenant)
    tenant.users.find_by(uid: "#{tenant.id}***admin@#{tenant.subdomain}.#{tld(tenant)}")
  end

  def self.find_sub_admin_for_tenant(tenant)
    tenant.users.find_by(uid: "#{tenant.id}***subadmin@#{tenant.subdomain}.#{tld(tenant)}")
  end

  def self.new_admin(tenant)
    tenant.users.new(
      role: Role.find_by_name('admin'),

      company_name: tenant.name,
      first_name: 'Admin',
      last_name: 'Admin',
      phone: '123456789',

      email: "admin@#{tenant.subdomain}.#{tld(tenant)}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )
  end

  def self.new_sub_admin(tenant)
    tenant.users.new(
      role: Role.find_by_name('sub_admin'),

      company_name: tenant.name,
      first_name: 'Sub',
      last_name: 'Admin',
      phone: '123456789',

      email: "subadmin@#{tenant.subdomain}.#{tld(tenant)}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )
  end
end
