FactoryBot.define do
  factory :rms_data_book, class: 'RmsData::Book' do
    sheet_type { :hubs }
    association :tenant, factory: :tenants_tenant
  end
end

# == Schema Information
#
# Table name: rms_data_books
#
#  id          :uuid             not null, primary key
#  book_type   :integer          default("not_set"), not null
#  metadata    :jsonb
#  sheet_type  :integer
#  target_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_id   :uuid
#  tenant_id   :uuid
#
# Indexes
#
#  index_rms_data_books_on_sheet_type                 (sheet_type)
#  index_rms_data_books_on_target_type_and_target_id  (target_type,target_id)
#  index_rms_data_books_on_tenant_id                  (tenant_id)
#
