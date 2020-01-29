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
#  direction          :string
#  fees               :jsonb
#  load_type          :string
#  mode_of_transport  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  hub_id             :integer
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#
# Indexes
#
#  index_customs_fees_on_tenant_id  (tenant_id)
#
