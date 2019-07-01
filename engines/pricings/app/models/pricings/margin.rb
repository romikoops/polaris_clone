# frozen_string_literal: true

module Pricings
  class Margin < ApplicationRecord
    attr_accessor :transient_marked_as_old

    enum margin_type: { trucking_pre_margin: 1, export_margin: 2, freight_margin: 3, import_margin: 4, trucking_on_margin: 5 }

    belongs_to :applicable, polymorphic: true
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :details, class_name: 'Pricings::Detail', dependent: :destroy
    belongs_to :pricing, class_name: 'Pricings::Pricing', optional: true
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :itinerary, class_name: 'Legacy::Itinerary', optional: true
    belongs_to :origin_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :destination_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    scope :for_cargo_classes, (lambda do |cargo_classes|
      where(cargo_class: cargo_classes.map(&:downcase))
    end)
    scope :for_dates, (lambda do |start_date, end_date|
      where(Arel::Nodes::InfixOperation.new(
              'OVERLAPS',
              Arel::Nodes::SqlLiteral.new(
                "(#{arel_table[:effective_date].name}, #{arel_table[:expiration_date].name})"
              ),
              Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
            ))
    end)

    before_validation :set_application_order

    def service_level
      (tenant_vehicle&.name || pricing&.tenant_vehicle&.name) || 'All'
    end

    def itinerary_name # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if itinerary
        itinerary.name
      elsif pricing
        pricing&.itinerary&.name
      elsif origin_hub && !destination_hub
        "Departing #{origin_hub.name}"
      elsif destination_hub && !origin_hub
        "Entering #{destination_hub.name}"
      elsif destination_hub && origin_hub && (destination_hub == origin_hub)
        destination_hub.name
      else
        'All'
      end
    end

    def mode_of_transport
      (itinerary&.mode_of_transport || pricing&.itinerary&.mode_of_transport) || (default_for || 'ALL')
    end

    def get_pricing # rubocop:disable Naming/AccessorMethodName
      return pricing if pricing

      tenant.legacy.rates.find_by(
        tenant_vehicle_id: tenant_vehicle_id,
        cargo_class: cargo_class,
        itinerary_id: itinerary_id
      )
    end

    def cargo_class
      (self[:cargo_class] || pricing&.cargo_class) || 'All'
    end

    def fee_code
      'N/A'
    end

    private

    def set_application_order
      existing_margins = Pricings::Margin.where(applicable: applicable, margin_type: margin_type).order(application_order: :desc)
      return if existing_margins.empty?

      self.application_order = existing_margins.first.application_order + 1
    end
  end
end

# == Schema Information
#
# Table name: pricings_margins
#
#  id                 :uuid             not null, primary key
#  tenant_id          :uuid
#  pricing_id         :uuid
#  default_for        :string
#  operator           :string
#  value              :decimal(, )
#  effective_date     :datetime
#  expiration_date    :datetime
#  applicable_type    :string
#  applicable_id      :uuid
#  tenant_vehicle_id  :integer
#  cargo_class        :string
#  itinerary_id       :integer
#  origin_hub_id      :integer
#  destination_hub_id :integer
#  application_order  :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  margin_type        :integer
#  sandbox_id         :uuid
#
