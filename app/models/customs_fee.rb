# frozen_string_literal: true

class CustomsFee < ApplicationRecord
  has_paper_trail
  belongs_to :hub
  belongs_to :tenant
end

# == Schema Information
#
# Table name: customs_fees
#
#  id                 :bigint           not null, primary key
#  mode_of_transport  :string
#  load_type          :string
#  hub_id             :integer
#  tenant_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tenant_vehicle_id  :integer
#  counterpart_hub_id :integer
#  direction          :string
#  fees               :jsonb
#
