# frozen_string_literal: true

namespace :cleanup do
  task transshipments: :environment do
    combinations = Pricings::Pricing.where.not(transshipment: nil).group(:transshipment, :itinerary_id).count.keys
    combinations.each do |combination|
      Legacy::Itinerary.find(combination.second).dup.tap do |itinerary|
        itinerary.transshipment = combination.first
        itinerary.save

        Pricings::Pricing.where(transshipment: combination.first, itinerary_id: combination.second)
                         .update_all(itinerary_id: itinerary.id)
      end
    end
  end
end
