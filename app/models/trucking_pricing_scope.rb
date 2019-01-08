# frozen_string_literal: true

class TruckingPricingScope < ApplicationRecord
  has_many :trucking_pricings
  belongs_to :courier
end

# == Schema Information
#
# Table name: trucking_pricing_scopes
#
#  id          :bigint(8)        not null, primary key
#  load_type   :string
#  cargo_class :string
#  carriage    :string
#  courier_id  :integer
#  truck_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
