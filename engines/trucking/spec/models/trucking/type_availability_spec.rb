# frozen_string_literal: true

require "rails_helper"

module Trucking
  RSpec.describe TypeAvailability, class: "Trucking::TypeAvailability", type: :model do
    it "is valid with valid attributes" do
      expect(FactoryBot.build(:trucking_type_availability)).to be_valid
    end

    context "raises a data base error when attributes violate constraint" do
      let!(:existing) { FactoryBot.create(:trucking_type_availability) }

      it "raises an database error" do
        expect { existing.dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it "is invalid with duplciate attributes" do
        expect(existing.dup).not_to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_type_availabilities
#
#  id           :uuid             not null, primary key
#  carriage     :string
#  load_type    :string
#  query_method :integer
#  truck_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_type_availabilities_on_load_type     (load_type)
#  index_trucking_type_availabilities_on_query_method  (query_method)
#  index_trucking_type_availabilities_on_sandbox_id    (sandbox_id)
#  index_trucking_type_availabilities_on_truck_type    (truck_type)
#
