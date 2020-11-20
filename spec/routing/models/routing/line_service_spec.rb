require "rails_helper"

module Routing
  RSpec.describe LineService, type: :model do
    it "creates a valid object" do
      line_service = FactoryBot.create(:routing_line_service)
      expect(line_service.valid?).to eq(true)
    end
  end
end

# == Schema Information
#
# Table name: routing_line_services
#
#  id         :uuid             not null, primary key
#  category   :integer          default(NULL), not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  carrier_id :uuid
#
# Indexes
#
#  index_routing_line_services_on_carrier_id  (carrier_id)
#  line_service_unique_index                  (carrier_id,name) UNIQUE
#
