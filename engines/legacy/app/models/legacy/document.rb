module Legacy
  class Document < ApplicationRecord
    self.table_name = 'documents'
    
    has_one_attached :file
    belongs_to :shipment, optional: true
    belongs_to :user, optional: true
    belongs_to :tenant
    belongs_to :quotation, optional: true
  end
end

# == Schema Information
#
# Table name: documents
#
#  id               :bigint(8)        not null, primary key
#  user_id          :integer
#  shipment_id      :integer
#  doc_type         :string
#  url              :string
#  text             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  approved         :string
#  approval_details :jsonb
#  tenant_id        :integer
#  quotation_id     :integer
#  sandbox_id       :uuid
#
