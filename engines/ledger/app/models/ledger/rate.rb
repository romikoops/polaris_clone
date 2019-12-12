# frozen_string_literal: true

module Ledger
  class Rate < ApplicationRecord
    belongs_to :target, polymorphic: true
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :location, class_name: 'Routing::Location', optional: true
    has_many :fees, class_name: 'Ledger::Fee'
  end
end

# == Schema Information
#
# Table name: ledger_rates
#
#  id          :uuid             not null, primary key
#  target_type :string
#  target_id   :uuid
#  location_id :uuid
#  terminal_id :uuid
#  tenant_id   :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
