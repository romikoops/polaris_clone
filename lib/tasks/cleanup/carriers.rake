# frozen_string_literal: true

namespace :cleanup do
  task carriers: :environment do
    Legacy::Carrier.where('code LIKE ?', '% 1').find_each do |deprecated_carrier|
      flagship = Legacy::Carrier.find_by(code: deprecated_carrier.code.delete_suffix(' 1'))
      if flagship
        deprecated_carrier.tenant_vehicles.find_each do |service|
          flagship_service = flagship.tenant_vehicles
                                     .find_by(name: service.name, tenant_id: service.tenant_id)
          if flagship_service.exists?
            # rubocop:disable Rails/SkipsModelValidations
            Legacy::LocalCharge.where(tenant_vehicle_id: service.id)
                               .update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::Trip.where(tenant_vehicle_id: service.id)
                        .update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::MaxDimensionsBundle.where(tenant_vehicle_id: service.id)
                                       .update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::Addon.where(tenant_vehicle_id: service.id)
                         .update_all(tenant_vehicle_id: flagship_service.id)
            CustomsFee.where(tenant_vehicle_id: service.id)
                      .update_all(tenant_vehicle_id: flagship_service.id)
            Pricings::Pricing.where(tenant_vehicle_id: service.id)
                             .update_all(tenant_vehicle_id: flagship_service.id)
            Pricings::Margin.where(tenant_vehicle_id: service.id)
                            .update_all(tenant_vehicle_id: flagship_service.id)
            Quotations::Tender.where(tenant_vehicle_id: service.id)
                              .update_all(tenant_vehicle_id: flagship_service.id)
            # rubocop:enable Rails/SkipsModelValidations
            service.destroy
          else
            service.update(carrier: flagship)
          end
        end
        deprecated_carrier.destroy
      else
        deprecated_carrier.update(code: deprecated_carrier.code.delete_suffix(' 1'))
      end
    end
  end
end
