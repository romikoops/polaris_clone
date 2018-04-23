# frozen_string_literal: true

FactoryBot.define do
  factory :itinerary do
    name 'Gothenburg - Shanghai'
    mode_of_transport 'ocean'
    association :mot_scope
    association :tenant
  end

end
