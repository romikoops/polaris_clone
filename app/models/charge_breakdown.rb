# frozen_string_literal: true

class ChargeBreakdown < Legacy::ChargeBreakdown
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id          :bigint           not null, primary key
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sandbox_id  :uuid
#  shipment_id :integer
#  tender_id   :uuid
#  trip_id     :integer
#
# Indexes
#
#  index_charge_breakdowns_on_sandbox_id  (sandbox_id)
#
