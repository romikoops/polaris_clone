# frozen_string_literal: true

FactoryBot.define do
  factory :locations_location, class: 'Locations::Location' do
    bounds { '010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F40' }
    osm_id { '-11111' }
    name { 'Shanghai' }
    admin_level { 8 }
  end
end
