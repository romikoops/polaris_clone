# frozen_string_literal: true

namespace :tenants do
  namespace :data do
    desc 'Import Tenants and Users for CBRA'
    task import: :environment do
      ::Tenant.find_each do |tenant|
        Tenants::Tenant.create_from_legacy(tenant) unless Tenants::Tenant.exists?(legacy_id: tenant.id)
      end

      ::User.find_in_batches do |group|
        group.each do |user|
          Tenants::User.create_from_legacy(user) unless Tenants::User.exists?(legacy_id: user.id)
        end
      end
    end
  end
end
