# frozen_string_literal: true
require "rails_helper"

RSpec.describe Api::Query, type: :model do
  context "sorting" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:asc_client) do
      FactoryBot.build(:users_client,
        organization: organization,
        profile: FactoryBot.build(:users_client_profile, last_name: "AAAA"))
    end
    let(:desc_client) do
      FactoryBot.build(:users_client,
        organization: organization,
        profile: FactoryBot.build(:users_client_profile, last_name: "BBBB"))
    end

    let!(:asc_query) do
      FactoryBot.create(:journey_query,
        client: asc_client,
        load_type: "lcl",
        cargo_ready_date: 2.days.from_now,
        origin: "a",
        destination: "a",
        organization: organization)
    end
    let!(:desc_query) do
      FactoryBot.create(:journey_query,
        client: desc_client,
        load_type: "fcl",
        organization: organization,
        origin: "b",
        destination: "b",
        cargo_ready_date: 3.days.from_now)
    end

    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_queries) { described_class.sorted_by(sort_by) }

    before do
      Organizations.current_id = organization.id
    end

    context "sorted by load_type" do
      let(:sort_key) { "load_type" }

      context "sorted by load_type asc" do
        let(:direction_key) { "asc" }

        it "sorts quotation load types in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "sorted by load_type desc" do
        let(:direction_key) { "desc" }

        it "sorts quotationload types in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "sorted by user last name" do
      let(:sort_key) { "last_name" }

      context "sorted by user last name asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their users first name in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "sorted by user last name desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their users first name in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "origin" do
      let(:sort_key) { "origin" }

      context "sorted by origin asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their origins in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "sorted by origin desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their origin in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "sort by destination" do
      let(:sort_key) { "destination" }

      context "sorted by destination asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their destination in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "sorted by destination desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their destination in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "sort by selected_date" do
      let(:sort_key) { "selected_date" }

      context "sorted by selected_date asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their selected date in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "sorted by selected_date desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their selected date in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "without matching sort_by scope" do
      let(:sort_key) { "nonsense" }
      let(:direction_key) { "desc" }

      it "returns default direction" do
        expect { sorted_queries }.to raise_error(ArgumentError)
      end
    end

    context "without proper direction scope" do
      let(:sort_key) { "selected_date" }
      let(:direction_key) { nil }

      it "returns default direction" do
        expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
      end
    end
  end
end
