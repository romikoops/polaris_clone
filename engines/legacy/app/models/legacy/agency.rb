# frozen_string_literal: true

module Legacy
  class Agency < ApplicationRecord
    self.table_name = "agencies"

    has_paper_trail

    has_many :users, class_name: "Users::Client"
    belongs_to :agency_manager, class_name: "Users::Client", optional: true
    belongs_to :organization, class_name: "Organizations::Organization"
  end
end

# == Schema Information
#
# Table name: agencies
#
#  id                :bigint           not null, primary key
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  agency_manager_id :integer
#  organization_id   :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_agencies_on_organization_id  (organization_id)
#  index_agencies_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
