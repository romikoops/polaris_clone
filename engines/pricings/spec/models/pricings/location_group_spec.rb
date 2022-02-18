# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe LocationGroup, type: :model do
    it "builds a valid LocationGroup" do
      expect(FactoryBot.build(:pricings_location_group)).to be_valid
    end

    it "is invalid when the name is missing" do
      expect { FactoryBot.create(:pricings_location_group, name: nil) }.to raise_error(/Name can't be blank/)
    end

    it "is invalid when the nexus is missing" do
      expect { FactoryBot.create(:pricings_location_group, nexus: nil) }.to raise_error(/Nexus must exist/)
    end

    it "raises an error when the name exists for the Organization and Nexus already (aka duplicate)" do
      expect { FactoryBot.create(:pricings_location_group).dup.save! }.to raise_error(/duplicate key value violates unique constraint "index_organization_location_groups"/)
    end

    it "raises an error when the name exists (different case) for the Organization and Nexus already (aka duplicate)" do
      expect {
        FactoryBot.create(:pricings_location_group).dup.tap { |new_location_group| new_location_group.update(name: new_location_group.name.downcase) }
      }.to raise_error(/duplicate key value violates unique constraint "index_organization_location_groups"/)
    end
  end
end
