# frozen_string_literal: true

class LocalCharge < ApplicationRecord
  has_paper_trail
  belongs_to :hub
  belongs_to :tenant
  belongs_to :tenant_vehicle, optional: true
  belongs_to :counterpart_hub, class_name: "Hub", optional: true

  scope :for_mode_of_transport, ->(mot) { where(mode_of_transport: mot) }
end
