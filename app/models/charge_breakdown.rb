# frozen_string_literal: true

class ChargeBreakdown < Legacy::ChargeBreakdown
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id          :bigint           not null, primary key
#  shipment_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  trip_id     :integer
#  sandbox_id  :uuid
#  valid_until :datetime
#
