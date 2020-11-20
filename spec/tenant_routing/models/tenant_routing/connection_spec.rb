require "rails_helper"

module TenantRouting
  RSpec.describe Connection, type: :model do
    it "creates a valid object" do
      connection = FactoryBot.build(:tenant_routing_connection)
      expect(connection.valid?).to eq(true)
    end
  end
end

# == Schema Information
#
# Table name: tenant_routing_connections
#
#  id                :uuid             not null, primary key
#  mode_of_transport :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  inbound_id        :uuid
#  line_service_id   :uuid
#  organization_id   :uuid
#  outbound_id       :uuid
#  tenant_id         :uuid
#
# Indexes
#
#  index_tenant_routing_connections_on_inbound_id       (inbound_id)
#  index_tenant_routing_connections_on_organization_id  (organization_id)
#  index_tenant_routing_connections_on_outbound_id      (outbound_id)
#  index_tenant_routing_connections_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
