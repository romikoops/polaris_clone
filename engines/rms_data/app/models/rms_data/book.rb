module RmsData
  class Book < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :sheets, class_name: 'RmsData::Sheet', dependent: :destroy

    enum sheet_type: { hubs: 1, local_charges: 2, pricings: 3, routes: 0 }
  end
end

# == Schema Information
#
# Table name: rms_data_books
#
#  id          :uuid             not null, primary key
#  sheet_type  :integer
#  tenant_id   :uuid
#  target_type :string
#  target_id   :uuid
#  book_type   :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
