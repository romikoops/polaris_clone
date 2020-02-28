# frozen_string_literal: true

module Legacy
  class Tenant < ApplicationRecord
    self.table_name = 'tenants'

    has_many :users
    has_many :shipments, class_name: 'Legacy::Shipment'
    has_many :itineraries, class_name: 'Legacy::Itinerary'
    has_many :hubs, dependent: :destroy
    has_many :tenant_cargo_item_types, dependent: :destroy, foreign_key: :tenant_id
    has_many :cargo_item_types, through: :tenant_cargo_item_types, dependent: :destroy
    has_many :map_data, dependent: :destroy, class_name: '::MapDatum'
    has_many :margins, as: :applicable
    has_many :rates, class_name: 'Pricings::Pricing', dependent: :destroy
    has_many :max_dimensions_bundles, dependent: :destroy, class_name: 'Legacy::MaxDimensionsBundle'
    has_many :tenant_cargo_item_types, dependent: :destroy
    has_many :cargo_item_types, through: :tenant_cargo_item_types, dependent: :destroy

    has_paper_trail

    def subdomain
      super
    end
    deprecate :subdomain, deprecator: ActiveSupport::Deprecation.new('', Rails.application.railtie_name)

    def __subdomain
      self['subdomain']
    end

    def max_dimensions
      max_dimensions_bundles.unit.to_max_dimensions_hash
    end

    def max_aggregate_dimensions
      max_dimensions_bundles.aggregate.to_max_dimensions_hash
    end

    def email_for(branch_raw, mode_of_transport = nil)
      return nil unless branch_raw.is_a?(String) || branch_raw.is_a?(Symbol)

      branch = branch_raw.to_s

      return Settings.emails.booking if emails[branch].blank?

      emails[branch][mode_of_transport] || emails[branch]['general']
    end

  end
end

# == Schema Information
#
# Table name: tenants
#
#  id          :bigint           not null, primary key
#  theme       :jsonb
#  emails      :jsonb
#  subdomain   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  phones      :jsonb
#  addresses   :jsonb
#  name        :string
#  scope       :jsonb
#  currency    :string           default("EUR")
#  web         :jsonb
#  email_links :jsonb
#
