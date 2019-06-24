# frozen_string_literal: true

namespace :pricings do
  task defaults: :environment do
    ::Tenants::Tenant.find_in_batches do |group|
      group.each do |tenant|
        existing_margins = ::Pricings::Margin.where(applicable: tenant)
        next unless existing_margins.empty?
        ['rail', 'ocean', 'air', 'truck', 'local_charge', 'trucking', nil].each do |default|
          %i(freight_margin export_margin import_margin trucking_pre_margin trucking_on_margin).each do |m_type|
            ::Pricings::Margin.find_or_create_by!(
              tenant: tenant,
              value: 0,
              default_for: default,
              operator: '%',
              applicable: tenant,
              margin_type: m_type,
              effective_date: Date.today,
              expiration_date: Date.today + 5.years
            )
          end
        end
      end
    end
  end
end

