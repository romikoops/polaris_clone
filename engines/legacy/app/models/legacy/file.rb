# frozen_string_literal: true

module Legacy
  class File < ApplicationRecord
    has_one_attached :file
    belongs_to :shipment, optional: true
    belongs_to :user, class_name: "Organizations::User", optional: true
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :quotation, optional: true
    belongs_to :target, polymorphic: true, optional: true

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
#  target_type      :string
#  text             :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  legacy_user_id   :integer
#  organization_id  :uuid
#  quotation_id     :integer
#  sandbox_id       :uuid
#  shipment_id      :integer
#  target_id        :uuid
#  tenant_id        :integer
#  user_id          :uuid
#
# Indexes
#
#  index_legacy_files_on_organization_id            (organization_id)
#  index_legacy_files_on_quotation_id               (quotation_id)
#  index_legacy_files_on_sandbox_id                 (sandbox_id)
#  index_legacy_files_on_shipment_id                (shipment_id)
#  index_legacy_files_on_target_type_and_target_id  (target_type,target_id)
#  index_legacy_files_on_tenant_id                  (tenant_id)
#  index_legacy_files_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
