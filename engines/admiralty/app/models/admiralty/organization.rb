# frozen_string_literal: true

module Admiralty
  class Organization < Organizations::Organization
    has_many :charge_categories, -> { where code: %w[trucking_pre export cargo import trucking_on] }, class_name: "Legacy::ChargeCategory"
    accepts_nested_attributes_for :charge_categories

    has_many :margins, -> { where "organization_id = applicable_id" }, class_name: "Pricings::Margin"
    accepts_nested_attributes_for :margins

    has_many :tenant_cargo_item_types, class_name: "Legacy::TenantCargoItemType"
    accepts_nested_attributes_for :tenant_cargo_item_types

    after_initialize :initialize_charge_categories, :initialize_margins, :initialize_colli_types

    def initialize_charge_categories
      return unless charge_categories.empty?

      %w[trucking_pre export cargo import trucking_on].each do |section|
        charge_categories << Legacy::ChargeCategory.new(code: section, name: section.humanize)
      end
    end

    def initialize_margins
      margins << ["rail", "ocean", "air", "truck", "local_charge", "trucking", nil].product(
        %i[freight_margin export_margin import_margin trucking_pre_margin trucking_on_margin]
      ).map do |default, margin_type|
        ::Pricings::Margin.create_with(
          value: 0,
          operator: "%",
          effective_date: created_at || Time.zone.now,
          expiration_date: 100.years.from_now
        ).find_or_initialize_by(
          organization: self,
          default_for: default,
          applicable: self,
          margin_type: margin_type
        )
      end
    end

    def initialize_colli_types
      return unless tenant_cargo_item_types.empty?

      tenant_cargo_item_types << Legacy::TenantCargoItemType.new(
        cargo_item_type: Legacy::CargoItemType.find_by(category: "Pallet", width: nil, length: nil)
      )
    end
  end
end

# == Schema Information
#
# Table name: organizations_organizations
#
#  id         :uuid             not null, primary key
#  live       :boolean          default(FALSE)
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_organizations_on_slug  (slug) UNIQUE
#
