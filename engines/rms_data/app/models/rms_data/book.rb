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
