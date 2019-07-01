# frozen_string_literal: true

class Courier < ApplicationRecord
  has_many :trucking_pricings
  belongs_to :tenant
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
end

# == Schema Information
#
# Table name: couriers
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
