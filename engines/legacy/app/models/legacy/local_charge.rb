# frozen_string_literal: true

module Legacy
  class LocalCharge < ApplicationRecord
    include PgSearch::Model

    UUID_V5_NAMESPACE = "9a295592-e5a9-427a-ad64-df244730b9dc"

    self.table_name = "local_charges"

    acts_as_paranoid

    has_paper_trail

    belongs_to :hub, class_name: "Legacy::Hub"
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :group, class_name: "Groups::Group"
    belongs_to :tenant_vehicle, class_name: "Legacy::TenantVehicle", optional: true
    has_one :carrier, class_name: "Legacy::Carrier", through: :tenant_vehicle
    belongs_to :counterpart_hub, class_name: "Legacy::Hub", optional: true
    has_many :notes, dependent: :destroy, as: :target

    scope :for_mode_of_transport, ->(mot) { where(mode_of_transport: mot.downcase) }
    scope :for_load_type, ->(load_type) { where(load_type: load_type.downcase) }
    scope :for_dates, (lambda do |start_date, end_date|
      where("validity && daterange(?::date, ?::date)", start_date, end_date)
    end)
    scope :current, -> { where("validity::daterange @> ?::date", Time.zone.now) }

    pg_search_scope :hub_search, associated_against: {
      hub: %i[name hub_code]
    },
                                 using: {
                                   tsearch: { prefix: true }
                                 }
    pg_search_scope :counterpart_search, associated_against: {
      counterpart_hub: %i[name hub_code]
    },
                                         using: {
                                           tsearch: { prefix: true }
                                         }
    pg_search_scope :service_search, associated_against: {
      tenant_vehicle: %i[name]
    },
                                     using: {
                                       tsearch: { prefix: true }
                                     }
    pg_search_scope :carrier_search, associated_against: {
      carrier: %i[name]
    },
                                     using: {
                                       tsearch: { prefix: true }
                                     }

    before_validation -> { generate_upsert_id }, on: %i[create update]
    before_validation :set_validity

    def generate_upsert_id
      return if [hub_id, tenant_vehicle_id, load_type, mode_of_transport, group_id, direction, organization_id].any?(&:blank?)

      self.uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID.parse(UUID_V5_NAMESPACE), [hub_id.to_s, counterpart_hub_id.to_s, tenant_vehicle_id.to_s, load_type.to_s, mode_of_transport.to_s, group_id.to_s, direction.to_s, organization_id.to_s].join)
    end

    def hub_name
      hub&.name
    end

    def counterpart_hub_name
      counterpart_hub&.name
    end

    def carrier_name
      tenant_vehicle&.carrier&.name
    end

    def service_level
      tenant_vehicle&.name
    end

    def set_validity
      self.validity = Range.new(effective_date.to_date, expiration_date.to_date)
    end
  end
end

# == Schema Information
#
# Table name: local_charges
#
#  id                 :bigint           not null, primary key
#  dangerous          :boolean          default(FALSE)
#  deleted_at         :datetime
#  direction          :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  fees               :jsonb
#  internal           :boolean          default(FALSE)
#  load_type          :string
#  metadata           :jsonb
#  mode_of_transport  :string
#  uuid               :uuid
#  validity           :daterange
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  group_id           :uuid
#  hub_id             :integer
#  legacy_user_id     :integer
#  organization_id    :uuid
#  sandbox_id         :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#  user_id            :uuid
#
# Indexes
#
#  index_local_charges_on_direction          (direction)
#  index_local_charges_on_group_id           (group_id)
#  index_local_charges_on_hub_id             (hub_id)
#  index_local_charges_on_load_type          (load_type)
#  index_local_charges_on_organization_id    (organization_id)
#  index_local_charges_on_sandbox_id         (sandbox_id)
#  index_local_charges_on_tenant_id          (tenant_id)
#  index_local_charges_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_local_charges_on_user_id            (user_id)
#  index_local_charges_on_uuid               (uuid)
#  index_local_charges_on_validity           (validity) USING gist
#  local_charges_uuid                        (uuid,validity) WHERE (deleted_at IS NULL) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
