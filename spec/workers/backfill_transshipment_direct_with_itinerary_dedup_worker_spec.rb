# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillTransshipmentDirectWithItineraryDedupWorker, type: :worker do
  let(:backfill_instance) { described_class.new }

  describe "#perform" do
    context "when itinerary with 'DIRECT' exists" do
      let!(:itinerary) { FactoryBot.create(:itinerary, transshipment: "DIRECT") }

      before { backfill_instance.perform }

      it "backfills itineraries transshipment with null" do
        itinerary.reload
        expect(itinerary.transshipment).to be_nil
      end
    end

    context "when there are itineraries with duplicate `direkt` and 'DIRECT'" do
      let!(:itinerary) { FactoryBot.create(:itinerary, transshipment: "DIRECT") }
      let!(:itinerary_direkt) { FactoryBot.create(:itinerary, transshipment: "direkt") }
      let(:nil_itinerary) do
        Legacy::Itinerary.find_by(
          origin_hub_id: itinerary.origin_hub_id,
          destination_hub_id: itinerary.destination_hub_id,
          mode_of_transport: itinerary.mode_of_transport,
          transshipment: nil,
          organization_id: itinerary.organization_id
        )
      end

      before { backfill_instance.perform }

      it "backfills itineraries transshipment with null" do
        itinerary.reload
        itinerary_direkt.reload
        expect(nil_itinerary).to be_present
      end

      it "updated itinerary associations with the de-duped itinerary id" do
        BackfillTransshipmentDirectWithItineraryDedupWorker::MODELS_WHICH_NEED_UPDATE.each do |model|
          expect(model.where(itinerary_id: nil_itinerary.id).pluck(:id)).to match_array(model.all.pluck(:id))
        end
      end
    end

    context "when there are itineraries with `direkt` and nil" do
      let!(:note) { FactoryBot.create(:legacy_note, header: "direkt header", itinerary: itinerary_direkt) }
      let(:itinerary_direkt) { FactoryBot.create(:itinerary, transshipment: "direkt") }
      let!(:itinerary_nil) do
        FactoryBot.create(:itinerary,
          origin_hub_id: itinerary_direkt.origin_hub_id,
          destination_hub_id: itinerary_direkt.destination_hub_id,
          mode_of_transport: itinerary_direkt.mode_of_transport,
          transshipment: nil,
          organization_id: itinerary_direkt.organization_id)
      end

      before { backfill_instance.perform }

      it "updated itinerary associations with the de-duped itinerary id" do
        BackfillTransshipmentDirectWithItineraryDedupWorker::MODELS_WHICH_NEED_UPDATE.each do |model|
          expect(model.where(itinerary_id: itinerary_nil.id).pluck(:id)).to match_array(model.all.pluck(:id))
        end
      end

      it "updates itinerary id for `journey notes`" do
        note.reload
        expect(note.itinerary_id).to eq(itinerary_nil.id)
      end

      it "destroys itineraries transshipment with `DIRECT`" do
        expect { itinerary_direkt.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "does not destroy nil itinerary" do
        itinerary_nil.reload

        expect(itinerary_nil).to be_present
      end
    end

    context "when transshipment with `direct` is present after perform" do
      before do
        allow(backfill_instance).to receive(:unsupported_type_exist?).and_return(true)
      end

      it "raises `FailedTransshipmentBackFill`" do
        expect { backfill_instance.perform }.to raise_error(BackfillTransshipmentDirectWithItineraryDedupWorker::FailedTransshipmentBackFill)
      end
    end
  end
end
