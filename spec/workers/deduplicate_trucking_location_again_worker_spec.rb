# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeduplicateTruckingLocationAgainWorker, type: :worker do
  describe "#perform" do
    context "when the Location has the wrong upsert_id" do
      let!(:location) { FactoryBot.build(:trucking_location, upsert_id: SecureRandom.uuid).tap { |loc| loc.save!(validate: false) } }
      let(:expected_upsert_id) do
        ::UUIDTools::UUID.sha1_create(
          ::UUIDTools::UUID.parse(::Trucking::Location::UUID_V5_NAMESPACE),
          [
            location.data,
            location.query,
            location.country_id
          ].map(&:to_s).join
        ).to_s
      end

      before do
        described_class.new.perform
      end

      it "corrects the upsert_id" do
        expect(location.reload.upsert_id.to_s).to eq(expected_upsert_id)
      end
    end
  end
end
