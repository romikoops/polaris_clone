# frozen_string_literal: true

Dir["#{Rails.root}/app/queries/trucking_pricing/*.rb"].each { |file| require file }

class TruckingPricing < ApplicationRecord
  has_paper_trail
  has_many :shipments
  belongs_to :trucking_pricing_scope
  delegate :courier, to: :trucking_pricing_scope
  belongs_to :tenant
  has_many :hub_truckings, dependent: :destroy
  has_many :hubs, through: :hub_truckings
  has_many :trucking_destinations, through: :hub_truckings
  include Queries::TruckingPricing

  SCOPING_ATTRIBUTE_NAMES = %i(load_type cargo_class carriage courier_id truck_type).freeze

  SCOPING_ATTRIBUTE_NAMES.each do |scoping_attribute_name|
    delegate scoping_attribute_name, to: :trucking_pricing_scope
  end

  # Validations

  # Class methods
  def self.copy_to_tenant(from_tenant, to_tenant)
    ft = Tenant.find_by_subdomain(from_tenant)
    tt = Tenant.find_by_subdomain(to_tenant)
    ft.trucking_pricings.each do |tp|
      temp_tp = tp.as_json
      temp_tp.delete('id')
      hub_id = Hub.find_by(name: Hub.find(tp.hub_id).name, tenant_id: tt.id).id

      temp_tp['tenant_id'] = tt.id
      ntp = TruckingPricing.create!(temp_tp)
      hts = tp.hub_truckings
      nhts = hts.map do |ht|
        temp_ht = ht.as_json
        temp_ht.delete('id')
        temp_ht['hub_id'] = hub_id
        temp_ht['trucking_pricing_id'] = ntp.id
        HubTrucking.create!(temp_ht)
      end
    end
  end

  def self.fix_hub_truckings(subd)
    t = Tenant.find_by_subdomain(subd)
    t.trucking_pricings.map do |tp|
      hub = Hub.find(tp.hub_id)
      next unless hub.tenant_id != t.id

      new_hub = Hub.find_by(name: hub.name, tenant_id: t.id)
      tp.hub_truckings.each do |ht|
        ht.hub_id = new_hub.id
        ht.save!
      end
    end
  end

  def self.delete_existing_truckings(hub)
    hub.trucking_pricings.delete_all
    hub.hub_truckings.delete_all
  end

  def self.find_by_filter(args = {})
    FindByFilter.new(args.merge(klass: self)).perform
  end

  def self.find_by_hub_id(hub_id)
    find_by_hub_ids([hub_id])
  end

  def self.find_by_hub_ids(hub_ids)
    query = FindByHubIds.new(hub_ids: hub_ids, klass: self)
    query.perform
    query.deserialized_result
  end

  # Instance Methods
  def nexus_id
    ActiveRecord::Base.connection.execute("
      SELECT addresses.id FROM addresses
      JOIN hubs ON hubs.nexus_id = addresses.id
      JOIN hub_truckings ON hub_truckings.hub_id = hubs.id
      JOIN trucking_pricings ON hub_truckings.trucking_pricing_id = trucking_pricings.id
      WHERE trucking_pricings.id = #{id}
      LIMIT 1
    ").values.first.try(:first)
  end

  def hub_id
    ActiveRecord::Base.connection.execute("
      SELECT hubs.id FROM hubs
      JOIN hub_truckings ON hub_truckings.hub_id = hubs.id
      JOIN trucking_pricings ON hub_truckings.trucking_pricing_id = trucking_pricings.id
      WHERE trucking_pricings.id = #{id}
      LIMIT 1
    ").values.first.try(:first)
  end

  def as_options_json(options = {})
    as_json(options.reverse_merge(methods: SCOPING_ATTRIBUTE_NAMES))
  end
end

# == Schema Information
#
# Table name: trucking_pricings
#
#  id                        :bigint(8)        not null, primary key
#  load_meterage             :jsonb
#  cbm_ratio                 :integer
#  modifier                  :string
#  tenant_id                 :integer
#  created_at                :datetime
#  updated_at                :datetime
#  rates                     :jsonb
#  fees                      :jsonb
#  identifier_modifier       :string
#  trucking_pricing_scope_id :integer
#
