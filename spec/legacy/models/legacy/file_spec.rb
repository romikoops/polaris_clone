# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe File, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:file) { FactoryBot.create(:legacy_file, :with_file, organization_id: organization.id) }

    describe ".local_file_path" do
      it "returns the path to the file" do
        file_path = file.local_file_path

        aggregate_failures do
          expect(file_path).to be_truthy
          expect(file_path).to include("/tmp/storage/")
        end
      end
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
#  old_user_id      :integer
#  organization_id  :uuid
#  quotation_id     :integer
#  sandbox_id       :uuid
#  shipment_id      :integer
#  tenant_id        :integer
#  user_id          :uuid
#
# Indexes
#
#  index_legacy_files_on_organization_id  (organization_id)
#  index_legacy_files_on_quotation_id     (quotation_id)
#  index_legacy_files_on_sandbox_id       (sandbox_id)
#  index_legacy_files_on_shipment_id      (shipment_id)
#  index_legacy_files_on_tenant_id        (tenant_id)
#  index_legacy_files_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
