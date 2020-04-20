# frozen_string_literal: true

namespace :tenant do
  task max_dimensions: :environment do
    Tenants::Tenant.find_each do |tenant|
      user = tenant.users.first
      legacy_tenant_id = tenant.legacy_id
      cargo_classes = Wheelhouse::EquipmentService.new(user: user).perform
      cargo_classes.each do |cargo_class|
        if Legacy::MaxDimensionsBundle.exists?(
          tenant_id: legacy_tenant_id,
          cargo_class: cargo_class,
          mode_of_transport: 'general'
        )
          next
        end

        Legacy::MaxDimensionsBundle.create(
          tenant_id: legacy_tenant_id,
          aggregate: false,
          cargo_class: cargo_class,
          mode_of_transport: 'general',
          payload_in_kg: 50_000
        )
      end
    end
  end
end
Rake::Task['db:migrate'].enhance do
  Rake::Task['tenant:max_dimensions'].invoke
end
