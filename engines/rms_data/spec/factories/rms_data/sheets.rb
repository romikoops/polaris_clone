FactoryBot.define do
  factory :rms_data_sheet, class: 'RmsData::Sheet' do
    sheet_index { 0 }
    association :organization, factory: :organizations_organization
    association :book, factory: :rms_data_book
  end
end

# == Schema Information
#
# Table name: rms_data_sheets
#
#  id              :uuid             not null, primary key
#  metadata        :jsonb
#  name            :string
#  sheet_index     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  book_id         :uuid
#  organization_id :uuid
#  tenant_id       :uuid
#
# Indexes
#
#  index_rms_data_sheets_on_book_id          (book_id)
#  index_rms_data_sheets_on_organization_id  (organization_id)
#  index_rms_data_sheets_on_sheet_index      (sheet_index)
#  index_rms_data_sheets_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
