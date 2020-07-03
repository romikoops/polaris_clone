# frozen_string_literal: true

class CustomsFee < ApplicationRecord
  has_paper_trail
  belongs_to :hub
  belongs_to :organization, class_name: 'Organizations::Organization'
end

# == Schema Information
#
# Table name: customs_fees
#
#  id                 :bigint           not null, primary key
#  direction          :string
#  fees               :jsonb
#  load_type          :string
#  mode_of_transport  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  hub_id             :integer
#  organization_id    :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#
# Indexes
#
#  index_customs_fees_on_organization_id  (organization_id)
#  index_customs_fees_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
