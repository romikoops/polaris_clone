# frozen_string_literal: true

require "rails_helper"

module TenantRouting
  RSpec.describe Visibility, type: :model do
    it "creates a valid object" do
      connection = FactoryBot.build(:tenant_routing_visibility)
      expect(connection.valid?).to eq(true)
    end
  end
end

# == Schema Information
#
# Table name: tenant_routing_visibilities
#
#  id            :uuid             not null, primary key
#  target_type   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  connection_id :uuid
#  target_id     :uuid
#
# Indexes
#
#  visibility_connection_index  (connection_id)
#  visibility_target_index      (target_type,target_id)
#
