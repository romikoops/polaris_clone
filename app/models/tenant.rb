# frozen_string_literal: true

class Tenant < ApplicationRecord
  include ImageTools
  extend MongoTools
  include MongoTools
  include DataValidator
  has_many :shipments
  has_many :routes
  has_many :hubs
  has_many :nexuses
  has_many :routes
  has_many :hub_routes, through: :routes
  has_many :schedules
  has_many :users
  has_many :tenant_vehicles
  has_many :vehicles, through: :tenant_vehicles
  has_many :tenant_cargo_item_types, dependent: :destroy
  has_many :cargo_item_types, through: :tenant_cargo_item_types
  has_many :itineraries
  has_many :stops, through: :itineraries
  has_many :trips, through: :itineraries
  has_many :layovers, through: :stops
  has_many :trucking_pricings
  has_many :hub_truckings, through: :hubs
  has_many :trucking_destinations, through: :hub_truckings
  has_many :documents
  has_many :pricings
  has_many :pricing_exceptions
  has_many :pricing_details
  has_many :local_charges
  has_many :customs_fees
  has_many :tenant_incoterms
  has_many :incoterms, through: :tenant_incoterms
  has_many :seller_incoterm_liabilities, through: :incoterms
  has_many :buyer_incoterm_liabilities, through: :incoterms
  has_many :seller_incoterm_scopes, through: :incoterms
  has_many :buyer_incoterm_scopes, through: :incoterms
  has_many :seller_incoterm_charges, through: :incoterms
  has_many :buyer_incoterm_charges, through: :incoterms
  has_many :conversations
  has_many :max_dimensions_bundles
  has_many :map_data
  has_many :agencies

  validates :scope, presence: true, scope: true
  validates :emails, presence: true, emails: true

  def get_admin
    users.joins(:role).where('roles.name': "admin").first
  end

  def email_for(branch_raw, mode_of_transport=nil)
    return nil unless branch_raw.is_a?(String) || branch_raw.is_a?(Symbol)
    branch = branch_raw.to_s

    return "itsmycargodev@gmail.com" if emails[branch].blank?

    emails[branch][mode_of_transport] || emails[branch]["general"]
  end

  def self.update_hs_codes
    data = get_all_items("hsCodes")
    data.each do |datum|
      code_ref = datum["_id"].slice(0, 2).to_i
      if code_ref >= 28 && code_ref <= 38
        datum["dangerous"] = true
        update_item("hsCodes", { _id: datum["_id"] }, datum)
      end
    end
  end

  def test_pricings(load_type, expected_values, pickup, dropoff, import, export)
    DataValidator::ItineraryPriceValidator.new(
      load_type:        load_type,
      expected_values:  expected_values,
      tenant:           id,
      has_pre_carriage: pickup,
      has_on_carriage:  dropoff,
      import:           import,
      export:           export
    ).perform
  end

  def autogenerate_all_schedules()
    itineraries.each do |itinerary|
      itinerary.default_generate_schedules
    end
  end

  def mode_of_transport_in_scope?(mode_of_transport, load_type=nil)
    return scope.dig("modes_of_transport", mode_of_transport.to_s).values.any? if load_type.nil?

    scope.dig("modes_of_transport", mode_of_transport.to_s, load_type.to_s)
  end

  def max_dimensions
    max_dimensions_bundles.unit.to_max_dimensions_hash
  end

  def max_aggregate_dimensions
    max_dimensions_bundles.aggregate.to_max_dimensions_hash
  end

  private

  def load_type_filter(load_type, mot)
    mot.each_with_object({}) do |(k, v), h|
      h[k] = v.each_with_object({}) { |(_k, _v), _h| _h[_k] = _k != load_type ? false : _v }
    end
  end

  def self.update_web
    web_data = [
      { subdomain: "greencarrier", cloudfront: "E1HIJBT7WVXAP3" },
      { subdomain: "demo", cloudfront: "E20JU5F52LP1AZ", index: "index.html" },
      { subdomain: "nordicconsolidators", cloudfront: "E3P24SVVXVUTZO" },
      { subdomain: "isa", cloudfront: "E33QYEB8CF5AW0" },
      { subdomain: "integrail", cloudfront: "E1WJTKUIV6CYP3" },
      { subdomain: "easyshipping", cloudfront: "E2VR366CPGNLTC" },
      { subdomain: "belglobe", cloudfront: "E42GZPFHU0WZO" },
      { subdomain: "eimskip", cloudfront: "E1XPLYJA1HASN3" }
    ]
    web_data.each do |wd|
      t = Tenant.find_by_subdomain(wd[:subdomain])
      t.web = {} unless t.web
      t.web[:sudomain] = wd[:subdomain]
      t.web[:cloudfront] = wd[:cloudfront]
      t.save!
    end
  end

  def mot_scope_attributes(mot)
    mot.reduce({}) do |h, (k, v)|
      h.merge v.each_with_object({}) { |(_k, _v), _h| _h["#{k}_#{_k}"] = _v }
    end
  end

  def create_default_max_dimensions
    MaxDimensionsBundle.create_defaults_for(self)
  end

  def create_default_aggregate_max_dimensions
    MaxDimensionsBundle.create_defaults_for(self, aggregate: true)
  end

  # Shortcuts to find_by_subdomain to use in the console

  def self.method_missing(name, *args)
    where(subdomain: name.try(:to_s)).first || super
  end
end
