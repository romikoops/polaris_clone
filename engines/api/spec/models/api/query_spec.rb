# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Query, type: :model do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  context "when sorting" do
    let(:asc_client) do
      FactoryBot.build(:api_client,
        organization: organization,
        profile: FactoryBot.build(:users_client_profile, last_name: "AAAA"))
    end
    let(:desc_client) do
      FactoryBot.build(:api_client,
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

    context "when sorted by load_type" do
      let(:sort_key) { "load_type" }

      context "when sorted by load_type asc" do
        let(:direction_key) { "asc" }

        it "sorts quotation load types in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "when sorted by load_type desc" do
        let(:direction_key) { "desc" }

        it "sorts quotationload types in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "when sorted by user last name" do
      let(:sort_key) { "last_name" }

      context "when sorted by user last name asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their users first name in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "when sorted by user last name desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their users first name in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "when sort_key is 'origin'" do
      let(:sort_key) { "origin" }

      context "when sorted by origin asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their origins in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "when sorted by origin desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their origin in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "when sort_key is 'destination'" do
      let(:sort_key) { "destination" }

      context "when sorted by destination asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their destination in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "when sorted by destination desc" do
        let(:direction_key) { "desc" }

        it "sorts quotations by their destination in descending direction" do
          expect(sorted_queries.ids).to eq([desc_query.id, asc_query.id])
        end
      end
    end

    context "when sort by selected_date" do
      let(:sort_key) { "selected_date" }

      context "when sorted by selected_date asc" do
        let(:direction_key) { "asc" }

        it "sorts quotations by their selected date in ascending direction" do
          expect(sorted_queries.ids).to eq([asc_query.id, desc_query.id])
        end
      end

      context "when sorted by selected_date desc" do
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

  context "when searching" do
    let(:client) { FactoryBot.build(:api_client, organization: organization) }
    let!(:query) { FactoryBot.create(:api_query,  result_count: 1, client: client, organization: organization) }

    before do
      FactoryBot.create_list(:api_query, 2, organization: organization, client: client)
      Organizations.current_id = organization.id
    end

    describe ".reference_search" do
      let!(:line_item_set) { FactoryBot.create(:journey_line_item_set, result: query.results.first) }

      it "finds the correct Query" do
        expect(described_class.reference_search(line_item_set.reference).ids).to match_array([query.id])
      end
    end

    describe ".client_email_search" do
      let!(:query) { FactoryBot.create(:api_query, organization: organization) }

      it "finds the correct Query for the client email" do
        expect(described_class.client_email_search(query.client.email)).to match_array([query])
      end
    end

    describe ".client_name_search" do
      let(:target_client) do
        FactoryBot.create(:api_client,
          organization: organization,
          profile: FactoryBot.build(:users_client_profile, first_name: "Bob", last_name: "Dylan"))
      end
      let!(:query) { FactoryBot.create(:api_query, client: target_client, organization: organization) }

      it "finds the correct Query for the client first name" do
        expect(described_class.client_name_search(target_client.profile.first_name).ids).to match_array([query.id])
      end

      it "finds the correct Query for the client last name" do
        expect(described_class.client_name_search(target_client.profile.last_name).ids).to match_array([query.id])
      end
    end

    describe ".company_name_search" do
      it "finds the correct Query" do
        expect(described_class.company_name_search(query.company.name).ids).to match_array([query.id])
      end
    end

    describe ".origin_search" do
      let!(:query) { FactoryBot.create(:api_query, origin: "Cape Town", organization: organization) }

      it "finds the correct Query" do
        expect(described_class.origin_search(query.origin).ids).to match_array([query.id])
      end
    end

    describe ".destination_search" do
      let!(:query) { FactoryBot.create(:api_query, destination: "Cape Town", organization: organization) }

      it "finds the correct Query" do
        expect(described_class.destination_search(query.destination).ids).to match_array([query.id])
      end
    end

    describe ".imo_class_search" do
      let!(:commodity_info) { FactoryBot.create(:journey_commodity_info, :imo_class, cargo_unit: query.cargo_units.first) }

      it "finds the correct Query" do
        expect(described_class.imo_class_search(commodity_info.description[0..5]).ids).to match_array([query.id])
      end
    end

    describe ".hs_code_search" do
      let!(:commodity_info) { FactoryBot.create(:journey_commodity_info, :hs_code, cargo_unit: query.cargo_units.first) }

      it "finds the correct Query" do
        expect(described_class.hs_code_search(commodity_info.description[0..5]).ids).to match_array([query.id])
      end
    end
  end
end
