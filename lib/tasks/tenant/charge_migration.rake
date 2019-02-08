# frozen_string_literal: true

namespace :tenant do # rubocop:disable Metrics/BlockLength
  task charge_migration: :environment do # rubocop:disable Metrics/BlockLength
    Tenant.find_each do |tenant| # rubocop:disable Metrics/BlockLength
      shipment_association = tenant.quotation_tool? ? tenant.shipments.where.not(quotation_id: nil) : tenant.shipments
      shipment_association.each do |shipment| # rubocop:disable Metrics/BlockLength
        shipment.charge_breakdowns.each do |charge_breakdown| # rubocop:disable Metrics/BlockLength
          %w(import export).each do |direction| # rubocop:disable Metrics/BlockLength
            local_charge = charge_breakdown.charge(direction)
            next if local_charge.nil?

            next unless local_charge.children.length > 1 && local_charge.children.first.children.length.zero?

            children_charge_category = ChargeCategory.find_or_create_by(
              name: shipment.fcl? ? 'Container' : 'Cargo Item',
              code: shipment.fcl? ? 'container' : 'cargo_item',
              cargo_unit_id: shipment.fcl? ? 'container' : 'cargo_item'
            )
            parent_charge = Charge.create(
              children_charge_category: children_charge_category,
              charge_category: local_charge.children_charge_category,
              charge_breakdown: charge_breakdown,
              parent: local_charge,
              price: local_charge.price
            )
            Charge.where(parent_id: local_charge.id).each do |charge|
              next if charge == parent_charge

              local_charge.children.first.children
              unless charge.children.empty?
                charge.children.each do |cc|
                  cc.detail_level += 1
                  cc.save!
                end
              end
              charge.parent = parent_charge
              charge.detail_level += 1
              charge.save!
            end
          end
        end
      end
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['tenant:charge_migration'].invoke
end