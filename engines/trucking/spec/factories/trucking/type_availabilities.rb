FactoryBot.define do
  factory :trucking_type_availability, class: 'Trucking::TypeAvailability' do
    load_type  { 'cargo_item' }
    carriage   { 'pre' }
    truck_type { 'default' }
    query_method { :not_set }
  end
end

# == Schema Information
#
# Table name: trucking_type_availabilities
#
#  id           :uuid             not null, primary key
#  carriage     :string
#  load_type    :string
#  query_method :integer
#  truck_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_type_availabilities_on_sandbox_id  (sandbox_id)
#
