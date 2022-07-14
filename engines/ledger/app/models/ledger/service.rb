# frozen_string_literal: true

module Ledger
  class Service < ApplicationRecord
    MODES_OF_TRANSPORT = [
      OCEAN = "ocean",
      AIR = "air",
      RAIL = "rail",
      TRUCK = "truck",
      BARGE = "barge"
    ].freeze

    belongs_to :carrier, class_name: "Routing::Carrier"
    belongs_to :organization, class_name: "Organizations::Organization"

    validates :name, presence: true
    validates_enum :mode_of_transport, allow_nil: true
  end
end

# == Schema Information
#
# Table name: ledger_services
#
#  id                     :uuid             not null, primary key
#  cargo_class            :string
#  destination_cfs        :string
#  destination_inland_cfs :string
#  mode_of_transport      :enum
#  name                   :string           not null
#  origin_cfs             :string
#  origin_inland_cfs      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  carrier_id             :uuid             not null
#  organization_id        :uuid             not null
#  routing_id             :bigint
#
# Indexes
#
#  index_ledger_services_on_carrier_id       (carrier_id)
#  index_ledger_services_on_organization_id  (organization_id)
#  index_ledger_services_on_routing_id       (routing_id)
#
# Foreign Keys
#
#  fk_rails_...  (carrier_id => routing_carriers.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
