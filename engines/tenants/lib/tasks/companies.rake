# frozen_string_literal: true

namespace :tenants do
  task companies: :environment do
    ::User.find_in_batches do |group|
      group.each do |user|
        tenant_user = Tenants::User.find_by(legacy_id: user) 
        tenant_user.verify_company
      end
    end

    ::Agency.find_each do |agency|
      tenant = ::Tenants::Tenant.find_by(legacy_id: agency.tenant_id)
      company_agency = ::Tenants::Company.find_by(name: agency.name, tenant_id: tenant.id)
      company_agency ||= ::Tenants::Company.create!(
        name: agency.name,
        tenant_id: tenant.id,
        email: agency.agency_manager&.email
      )
      users = ::User.where(agency_id: agency.id)
      users.each do |user|
        tenant_user = ::Tenants::User.find_by(legacy_id: user.id)
        tenant_user.company = company_agency
        tenant_user.save!
      end
    end
  end
end

