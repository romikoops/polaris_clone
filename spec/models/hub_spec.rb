# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hub, type: :model do
  it "builds  a valid hub" do
    expect(FactoryBot.build(:hub)).to be_valid
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint           not null, primary key
#  free_out            :boolean          default(FALSE)
#  hub_code            :string
#  hub_status          :string           default("active")
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  point               :geometry         geometry, 4326
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  organization_id     :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  index_hubs_on_organization_id  (organization_id)
#  index_hubs_on_point            (point) USING gist
#  index_hubs_on_sandbox_id       (sandbox_id)
#  index_hubs_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
