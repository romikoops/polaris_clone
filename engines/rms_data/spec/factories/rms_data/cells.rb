FactoryBot.define do
  factory :rms_data_cell, class: 'RmsData::Cell' do
    association :tenant, factory: :tenants_tenant
    association :sheet, factory: :rms_data_sheet
    value { 'Hamburg' }
    row { 1 }
    column { 2 }
  end
end
