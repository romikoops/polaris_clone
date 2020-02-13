# frozen_string_literal: true

module Legacy
  class File < ApplicationRecord
    has_one_attached :file
    belongs_to :shipment, optional: true
    belongs_to :user, optional: true
    belongs_to :tenant
    belongs_to :quotation, optional: true
    belongs_to :sandbox, optional: true, class_name: 'Tenants::Sandbox'

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
# Table name: legacy_files
#
#  id               :uuid             not null, primary key
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
#  index_legacy_files_on_quotation_id  (quotation_id)
#  index_legacy_files_on_sandbox_id    (sandbox_id)
#  index_legacy_files_on_shipment_id   (shipment_id)
#  index_legacy_files_on_tenant_id     (tenant_id)
#
