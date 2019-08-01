module Routing
  class Carrier < ApplicationRecord
    validates :name, presence: true, uniqueness: { case_sensitive: false }
  end
end

# == Schema Information
#
# Table name: routing_carriers
#
#  id               :uuid             not null, primary key
#  name             :string
#  abbreviated_name :string
#  code             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
