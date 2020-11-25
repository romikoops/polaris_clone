module Journey
  class Offer < ApplicationRecord
    has_many :offer_results
    has_many :results, through: :offer_result
  end
end

# == Schema Information
#
# Table name: journey_offers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
