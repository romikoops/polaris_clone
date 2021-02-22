# frozen_string_literal: true
require "rails_helper"

module Trucking
  RSpec.describe HubAvailability, class: "Trucking::HubAvailability", type: :model do
    context "validations" do
      it "is valid with valid attributes" do
        expect(FactoryBot.create(:trucking_hub_availability)).to be_valid
      end
    end

    context "database validations" do
      let(:existing) { FactoryBot.create(:trucking_hub_availability) }

      it "iraises an error when duplicate" do
        expect { existing.dup.save!(validate: false) }.to raise_error(
          ActiveRecord::RecordNotUnique
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_hub_availabilities
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hub_id               :integer
#  sandbox_id           :uuid
#  type_availability_id :uuid
#
# Indexes
#
#  index_trucking_hub_availabilities_on_hub_id                (hub_id)
#  index_trucking_hub_availabilities_on_sandbox_id            (sandbox_id)
#  index_trucking_hub_availabilities_on_type_availability_id  (type_availability_id)
#
