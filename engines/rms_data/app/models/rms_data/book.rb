module RmsData
  class Book < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :target, polymorphic: true, optional: true
    has_many :sheets, class_name: 'RmsData::Sheet', dependent: :destroy

    enum sheet_type: { hubs: 1, local_charges: 2, pricings: 3, carriage: 4, trucking: 5, routes: 0 }
    enum book_type: { cargo_item: 1, container: 2, not_set: 0 }
  end
end

# == Schema Information
#
# Table name: rms_data_books
#
#  id          :uuid             not null, primary key
#  sheet_type  :integer
#  tenant_id   :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_type :string
#  target_id   :uuid
#  book_type   :integer          default("not_set"), not null
#  metadata    :jsonb
#
