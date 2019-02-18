FactoryBot.define do
  factory :trucking_hub_availability, class: 'HubAvailability' do
    hub { :association }
    trucking_type_availability { :association }
  end
end
