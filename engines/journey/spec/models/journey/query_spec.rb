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

    describe "#update" do
      context "when the query has no client or creator" do
        let(:query) { FactoryBot.create(:journey_query, client: nil, creator: nil) }
        let(:client) { FactoryBot.create(:users_client, organization: query.organization) }

        before do
          query.update(client: client, creator: client)
          query.reload
        end

        it "updates the creator and client", :aggregate_failures do
          expect(query.client_id).to eq(client.id)
          expect(query.creator_id).to eq(client.id)
        end
      end

      context "when the query has a client and creator" do
        let(:query) { FactoryBot.create(:journey_query, client: client, creator: client) }
        let(:client) { FactoryBot.create(:users_client) }
        let(:other_client) { FactoryBot.create(:users_client) }

        it "raises an error", :aggregate_failures do
          expect { query.update!(client: other_client, creator: other_client) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(query.errors.messages[:client_id]).to include("Client id can only be added, not edited")
        end
      end

      context "when the query has no client but a  creator" do
        let(:query) { FactoryBot.create(:journey_query, client: nil, creator: client) }
        let(:client) { FactoryBot.create(:users_client) }
        let(:other_client) { FactoryBot.create(:users_client) }

        it "raises an error", :aggregate_failures do
          expect { query.update!(client: other_client, creator: other_client) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(query.errors.messages[:base]).to include("Client and Creator must be added together")
        end
      end

      context "when the the update only tries to change the client" do
        let(:query) { FactoryBot.create(:journey_query, client: nil, creator: nil) }
        let(:client) { FactoryBot.create(:users_client, organization: query.organization) }

        it "raises an error", :aggregate_failures do
          expect { query.update!(client: client) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(query.errors.messages[:base]).to include("Client and Creator must be added together")
        end
      end

      context "when the the update tries to change anything else" do
        let(:query) { FactoryBot.create(:journey_query) }

        it "raises an error", :aggregate_failures do
          expect { query.update!(origin: "test") }.to raise_error(ActiveRecord::RecordInvalid)
          expect(query.errors.messages[:base]).to include("Only status, client, company and creator can be updated")
        end
      end
    end
  end
end
