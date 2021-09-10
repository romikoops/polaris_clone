# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe Query, type: :model do
    let(:query) do
      FactoryBot.build(:journey_query,
        cargo_ready_date: cargo_ready_date,
        delivery_date: delivery_date)
    end
    let(:cargo_ready_date) { Time.zone.tomorrow }
    let(:delivery_date) { 2.weeks.from_now }

    it "validates that the currency attribute is present" do
      expect(query.currency).to be_present
    end

    it "validates that the status attribute is present" do
      expect(query.status).to be_present
    end

    context "when cargo ready date preceeds delivery date" do
      it "passes validation" do
        expect(query).to be_valid
      end
    end

    context "when cargo ready date follows delivery date" do
      let(:delivery_date) { Time.zone.yesterday }

      it "fails validation" do
        expect(query).not_to be_valid
      end
    end

    context "when cargo ready date is in the past" do
      let(:cargo_ready_date) { Time.zone.yesterday }

      it "fails validation" do
        expect(query).not_to be_valid
      end
    end

    context "when query is created for a parent query" do
      let(:child_query) do
        FactoryBot.create(:journey_query, parent: query)
      end
      let(:grand_child_query) { FactoryBot.create(:journey_query, parent: child_query) }

      it "parent_id is present" do
        expect(child_query.parent_id).to eq query.id
      end

      describe "#query_root" do
        it "returns the root query" do
          expect(grand_child_query.query_root.id).to eq query.id
        end

        it "returned root query should not have a parent" do
          expect(grand_child_query.query_root.parent_id).to be_nil
        end

        it "returns the same query when root query is called on query without parent" do
          expect(query.query_root).to eq query
        end

        describe "#parent" do
          it "returns the parent query" do
            expect(grand_child_query.parent).to eq child_query
          end

          it "returns nil if parent is not present" do
            expect(query.parent).to be_nil
          end
        end
      end
    end
  end
end
