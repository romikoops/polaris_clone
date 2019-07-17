FactoryBot.define do
  factory :rms_data_sheet, class: 'RmsData::Sheet' do
    sheet_index { 0 }
    association :tenant, factory: :tenants_tenant
    association :book, factory: :rms_data_book
  end
end
