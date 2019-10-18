# frozen_string_literal: true

module Quotations
  class Tender < ApplicationRecord
    belongs_to :quotation, inverse_of: :tenders
    belongs_to :origin_hub, class_name: 'Legacy::Hub'
    belongs_to :destination_hub, class_name: 'Legacy::Hub'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle'

    has_many :line_items, inverse_of: :tender

    monetize :amount_cents
  end
end

# == Schema Information
#
# Table name: quotations_tenders
#
#  id                 :uuid             not null, primary key
#  quotation_id       :bigint(8)
#  tenant_vehicle_id  :bigint(8)
#  origin_hub_id      :integer
#  destination_hub_id :integer
#  carrier_name       :string
#  name               :string
#  load_type          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  amount_cents       :integer
#  amount_currency    :string
#
