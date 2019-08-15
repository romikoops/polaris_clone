# frozen_string_literal: true

namespace :tenants do
  task domains: :environment do
    ::Tenants::Tenant.find_each do |tenant|
      next if ::Tenants::Domain.exists?(tenant_id: tenant.id, domain: "#{tenant.slug}.itsmycargo.com")

      ::Tenants::Domain.create(
        tenant_id: tenant.id,
        domain: "#{tenant.slug}.itsmycargo.com",
        default: true
      )
    end

    unless Rails.env.production?
      ::Tenants::Domain.find_each do |tenants_domain|
        dev_domain = ENV['REVIEW_APP_NAME'] ? "#{ENV['REVIEW_APP_NAME']}.itsmycargo.dev" : 'local'

        tenants_domain.update(
          domain: tenants_domain.domain.gsub(/(?<subdomain>\w+)\.itsmycargo\.com/, "\\k<subdomain>.#{dev_domain}")
        )
      end
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['tenants:domains'].invoke
end
