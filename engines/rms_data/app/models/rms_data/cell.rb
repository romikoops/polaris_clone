module RmsData
  class Cell < ApplicationRecord
    belongs_to :sheet, class_name: 'RmsData::Sheet'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
  end
end

# == Schema Information
#
# Table name: rms_data_cells
#
#  id         :uuid             not null, primary key
#  tenant_id  :uuid
#  row        :integer
#  column     :integer
#  value      :string
#  sheet_id   :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
