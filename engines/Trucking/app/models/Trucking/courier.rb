module Trucking
  class Courier < ApplicationRecord
    has_many :rates, class_name: 'Trucking::Rate'
    belongs_to :tenant
  end
end

# == Schema Information
#
# Table name: trucking_couriers
#
#  id         :uuid             not null, primary key
#  name       :string
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
