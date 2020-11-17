FactoryBot.define do
  factory :routing_line_service, class: 'Routing::LineService' do
    name { 'Far East 1' }
    association :carrier, factory: :routing_carrier
    category { 2 }
  end
end

# == Schema Information
#
# Table name: routing_line_services
#
#  id         :uuid             not null, primary key
#  category   :integer          default(NULL), not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  carrier_id :uuid
#
# Indexes
#
#  index_routing_line_services_on_carrier_id  (carrier_id)
#  line_service_unique_index                  (carrier_id,name) UNIQUE
#
