# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_layover, class: "Legacy::Layover" do
    etd { Date.tomorrow + 7.days + 2.hours }
    eta { Date.tomorrow + 11.days }
    closing_date { Date.tomorrow + 4.days + 5.hours }
    sequence(:stop_index) { |n| n }
    association :stop, factory: :legacy_stop
    association :trip, factory: :legacy_trip
    association :itinerary, factory: :default_itinerary
  end
end

# == Schema Information
#
# Table name: layovers
#
#  id           :bigint           not null, primary key
#  closing_date :datetime
#  eta          :datetime
#  etd          :datetime
#  stop_index   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  itinerary_id :integer
#  sandbox_id   :uuid
#  stop_id      :integer
#  trip_id      :integer
#
# Indexes
#
#  index_layovers_on_sandbox_id  (sandbox_id)
#  index_layovers_on_stop_id     (stop_id)
#
