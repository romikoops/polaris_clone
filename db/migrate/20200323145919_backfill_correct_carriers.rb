# frozen_string_literal: true

class BackfillCorrectCarriers < ActiveRecord::Migration[5.2]
  def up
    Legacy::Carrier.all.group_by(&:name).values.each do |carrier_group|
      sorted_carrier_group = carrier_group.sort_by(&:created_at)
      flagship = sorted_carrier_group.first
      impostors = sorted_carrier_group.reject { |carrier| carrier == flagship }
      impostors.each do |carrier|
        carrier.tenant_vehicles.each do |service|
          flagship_service = flagship.tenant_vehicles.find_by(name: service.name, tenant_id: service.tenant_id)
          if flagship_service.present?
            Legacy::LocalCharge.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::Pricing.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::Trip.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::MaxDimensionsBundle.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Legacy::Addon.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            CustomsFee.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Pricings::Pricing.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Pricings::Margin.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            Quotations::Tender.where(tenant_vehicle_id: service.id).update_all(tenant_vehicle_id: flagship_service.id)
            service.destroy
          else
            service.update(carrier: flagship)
          end
        end
        carrier.destroy
      end
    end
  end
end
