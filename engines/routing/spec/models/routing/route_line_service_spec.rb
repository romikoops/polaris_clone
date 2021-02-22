# frozen_string_literal: true
require "rails_helper"

module Routing
  RSpec.describe RouteLineService, type: :model do
    it "creates a valid object" do
      rls = FactoryBot.create(:routing_route_line_service)
      expect(rls.valid?).to eq(true)
    end
  end
end

# == Schema Information
#
# Table name: routing_route_line_services
#
#  id              :uuid             not null, primary key
#  transit_time    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  line_service_id :uuid
#  route_id        :uuid
#
# Indexes
#
#  route_line_service_index  (route_id,line_service_id) UNIQUE
#
