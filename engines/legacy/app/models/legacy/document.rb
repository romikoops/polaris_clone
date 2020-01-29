module Legacy
  class Document < ApplicationRecord
    self.table_name = 'documents'

    has_one_attached :file
    belongs_to :shipment, optional: true
    belongs_to :user, class_name: 'Legacy::User', optional: true
    belongs_to :tenant
    belongs_to :quotation, optional: true

    def attachment
      file&.download
    end

    def local_file_path
      ActiveStorage::Blob.service.send(:path_for, file.key)
    end
  end
end

# == Schema Information
#
# Table name: documents
#
#  id               :bigint           not null, primary key
#  approval_details :jsonb
#  approved         :string
#  doc_type         :string
#  text             :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  quotation_id     :integer
#  sandbox_id       :uuid
#  shipment_id      :integer
#  tenant_id        :integer
#  user_id          :integer
#
# Indexes
#
#  index_documents_on_sandbox_id  (sandbox_id)
#  index_documents_on_tenant_id   (tenant_id)
#
