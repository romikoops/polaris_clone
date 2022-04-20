# frozen_string_literal: true

module Pricings
  class Margin < ApplicationRecord
    attr_accessor :transient_marked_as_old

    enum margin_type: {
      trucking_pre_margin: 1, export_margin: 2, freight_margin: 3, import_margin: 4, trucking_on_margin: 5, total_margin: 6
    }

    belongs_to :applicable, polymorphic: true
    belongs_to :organization, class_name: "Organizations::Organization"
    has_many :details, class_name: "Pricings::Detail", dependent: :destroy
    belongs_to :pricing, class_name: "Pricings::Pricing", optional: true
    belongs_to :tenant_vehicle, class_name: "Legacy::TenantVehicle", optional: true
    belongs_to :itinerary, class_name: "Legacy::Itinerary", optional: true
    belongs_to :origin_hub, class_name: "Legacy::Hub", optional: true
    belongs_to :destination_hub, class_name: "Legacy::Hub", optional: true

    scope :for_cargo_classes, (lambda do |cargo_classes|
      where(cargo_class: cargo_classes.map(&:downcase))
    end)
    scope :for_dates, (lambda do |start_date, end_date|
      where("validity && daterange(?::date, ?::date)", start_date, end_date)
    end)
    validates :operator, inclusion: { in: %w[+ %], message: "Operator for a Parent Margin must be either '%' or '+'." }

    before_validation :set_application_order, :set_validity

    accepts_nested_attributes_for :details

    def service_level
      (tenant_vehicle&.name || pricing&.tenant_vehicle&.name) || "All"
    end

    def itinerary_name
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
        "All"
      end
    end

    def mode_of_transport
      (itinerary&.mode_of_transport || pricing&.itinerary&.mode_of_transport) || (default_for || "ALL")
    end

    def get_pricing
      return pricing if pricing

      Pricings::Pricing.where(organization_id: organization_id).find_by(
        tenant_vehicle_id: tenant_vehicle_id,
        cargo_class: cargo_class,
        itinerary_id: itinerary_id
      )
    end

    def cargo_class
      (self[:cargo_class] || pricing&.cargo_class) || "All"
    end

    def fee_code
      "N/A"
    end

    private

    def set_application_order
      existing_margins = Pricings::Margin.where(applicable: applicable, margin_type: margin_type)
        .order(application_order: :desc)
      return if existing_margins.empty?

      self.application_order = existing_margins.first.application_order + 1
    end

    def set_validity
      self.validity = Range.new(effective_date.to_date, expiration_date.to_date)
    end
  end
end

# == Schema Information
#
# Table name: pricings_margins
#
#  id                 :uuid             not null, primary key
#  applicable_type    :string
#  application_order  :integer          default(0)
#  cargo_class        :string
#  default_for        :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  margin_type        :integer
#  operator           :string
#  validity           :daterange
#  value              :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  applicable_id      :uuid
#  destination_hub_id :integer
#  itinerary_id       :integer
#  organization_id    :uuid
#  origin_hub_id      :integer
#  pricing_id         :uuid
#  sandbox_id         :uuid
#  tenant_id          :uuid
#  tenant_vehicle_id  :integer
#
# Indexes
#
#  index_pricings_margins_on_applicable_type_and_applicable_id  (applicable_type,applicable_id)
#  index_pricings_margins_on_application_order                  (application_order)
#  index_pricings_margins_on_cargo_class                        (cargo_class)
#  index_pricings_margins_on_destination_hub_id                 (destination_hub_id)
#  index_pricings_margins_on_effective_date                     (effective_date)
#  index_pricings_margins_on_expiration_date                    (expiration_date)
#  index_pricings_margins_on_itinerary_id                       (itinerary_id)
#  index_pricings_margins_on_margin_type                        (margin_type)
#  index_pricings_margins_on_organization_id                    (organization_id)
#  index_pricings_margins_on_origin_hub_id                      (origin_hub_id)
#  index_pricings_margins_on_pricing_id                         (pricing_id)
#  index_pricings_margins_on_sandbox_id                         (sandbox_id)
#  index_pricings_margins_on_tenant_id                          (tenant_id)
#  index_pricings_margins_on_tenant_vehicle_id                  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
