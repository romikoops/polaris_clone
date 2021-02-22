# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe Result, type: :model do
    subject { FactoryBot.build(:journey_result, expiration_date: expiration_date) }

    context "with a valid expiration date" do
      let(:expiration_date) { Time.zone.tomorrow }

      it { is_expected.to be_valid }
    end

    context "with an invalid expiration date" do
      let(:expiration_date) { Time.zone.yesterday }

      it { is_expected.not_to be_valid }
    end

    context "sorting" do
      before do
        Organizations.current_id = organization.id
      end

      let(:organization) { FactoryBot.create(:organizations_organization) }
      let!(:asc_route_section) do
        FactoryBot.create(:journey_route_section,
          result: asc_result,
          from: FactoryBot.build(:journey_route_point, name: "AAA", locode: "AAAA1"),
          to: FactoryBot.build(:journey_route_point, name: "AAA", locode: "AAAA1"))
      end
      let!(:desc_route_section) do
        FactoryBot.create(:journey_route_section,
          result: desc_result,
          from: FactoryBot.build(:journey_route_point, name: "BBB", locode: "BBBB1"),
          to: FactoryBot.build(:journey_route_point, name: "BBB", locode: "BBBB1"))
      end
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
      let(:asc_query) do
        FactoryBot.build(:journey_query,
          client: asc_client,
          cargo_ready_date: 2.days.from_now,
          organization: organization,
          cargo_units: [FactoryBot.create(:journey_cargo_unit, :fcl)])
      end
      let(:desc_query) do
        FactoryBot.build(:journey_query,
          client: desc_client,
          organization: organization,
          cargo_ready_date: 3.days.from_now,
          cargo_units: [FactoryBot.create(:journey_cargo_unit)])
      end

      let(:asc_result_set) { FactoryBot.build(:journey_result_set, query: asc_query, result_count: 0) }
      let(:desc_result_set) { FactoryBot.build(:journey_result_set, query: desc_query, result_count: 0) }
      let(:asc_result) { FactoryBot.build(:journey_result, result_set: asc_result_set, route_sections: []) }
      let(:desc_result) { FactoryBot.build(:journey_result, result_set: desc_result_set, route_sections: []) }
      let(:sorted_results) { described_class.sorted(sort_by: sort_key, direction: direction_key) }

      context "sorted by load_type" do
        let(:sort_key) { "load_type" }

        context "sorted by load_type asc" do
          let(:direction_key) { "asc" }

          it "sorts quotation load types in ascending direction" do
            expect(sorted_results).to eq([asc_result, desc_result])
          end
        end

        context "sorted by load_type desc" do
          let(:direction_key) { "desc" }

          it "sorts quotationload types in descending direction" do
            expect(sorted_results).to eq([desc_result, asc_result])
          end
        end
      end

      context "sorted by user last name" do
        let(:sort_key) { "last_name" }

        context "sorted by user last name asc" do
          let(:direction_key) { "asc" }

          it "sorts quotations by their users first name in ascending direction" do
            expect(sorted_results).to eq([asc_result, desc_result])
          end
        end

        context "sorted by user last name desc" do
          let(:direction_key) { "desc" }

          it "sorts quotations by their users first name in descending direction" do
            expect(sorted_results).to eq([desc_result, asc_result])
          end
        end
      end

      context "origin" do
        let(:sort_key) { "origin" }

        context "sorted by origin asc" do
          let(:direction_key) { "asc" }

          it "sorts quotations by their origins in ascending direction" do
            expect(sorted_results).to eq([asc_result, desc_result])
          end
        end

        context "sorted by origin desc" do
          let(:direction_key) { "desc" }

          it "sorts quotations by their origin in descending direction" do
            expect(sorted_results).to eq([desc_result, asc_result])
          end
        end
      end

      context "sort by destination" do
        let(:sort_key) { "destination" }

        context "sorted by destination asc" do
          let(:direction_key) { "asc" }

          it "sorts quotations by their destination in ascending direction" do
            expect(sorted_results).to eq([asc_result, desc_result])
          end
        end

        context "sorted by destination desc" do
          let(:direction_key) { "desc" }

          it "sorts quotations by their destination in descending direction" do
            expect(sorted_results).to eq([desc_result, asc_result])
          end
        end
      end

      context "sort by selected_date" do
        let(:sort_key) { "selected_date" }

        context "sorted by selected_date asc" do
          let(:direction_key) { "asc" }

          it "sorts quotations by their selected date in ascending direction" do
            expect(sorted_results).to eq([asc_result, desc_result])
          end
        end

        context "sorted by selected_date desc" do
          let(:direction_key) { "desc" }

          it "sorts quotations by their selected date in descending direction" do
            expect(sorted_results).to eq([desc_result, asc_result])
          end
        end
      end

      context "without matching sort_by scope" do
        let(:sort_key) { "nonsense" }
        let(:direction_key) { "desc" }

        it "returns default direction" do
          expect(sorted_results).to eq([asc_result, desc_result])
        end
      end

      context "without proper direction scope" do
        let(:sort_key) { "selected_date" }
        let(:direction_key) { nil }

        it "returns default direction" do
          expect(sorted_results).to eq([asc_result, desc_result])
        end
      end
    end
  end
end
