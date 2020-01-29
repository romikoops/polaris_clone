FactoryBot.define do
  factory :rms_data_cell, class: 'RmsData::Cell' do
    association :tenant, factory: :tenants_tenant
    association :sheet, factory: :rms_data_sheet
    value { 'Hamburg' }
    row { 1 }
    column { 2 }
  end
end

# == Schema Information
#
# Table name: rms_data_cells
#
#  id         :uuid             not null, primary key
#  column     :integer
#  row        :integer
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sheet_id   :uuid
#  tenant_id  :uuid
#
# Indexes
#
#  index_rms_data_cells_on_column     (column)
#  index_rms_data_cells_on_row        (row)
#  index_rms_data_cells_on_sheet_id   (sheet_id)
#  index_rms_data_cells_on_tenant_id  (tenant_id)
#
