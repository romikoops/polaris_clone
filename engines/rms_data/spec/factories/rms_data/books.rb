FactoryBot.define do
  factory :rms_data_book, class: 'RmsData::Book' do
    sheet_type { :hubs }
    association :tenant, factory: :tenants_tenant
  end
end
