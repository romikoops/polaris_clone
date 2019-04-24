# frozen_string_literal: true

namespace :tenants do
  task scopes: :environment do
    ::Tenant.find_each do |tenant|
      scope = tenant.scope
      new_tenant = ::Tenants::Tenant.find_by(legacy_id: tenant.id)
      ::Tenants::Scope.find_or_create_by(target: new_tenant, content: scope)
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['tenants:scopes'].invoke
end
