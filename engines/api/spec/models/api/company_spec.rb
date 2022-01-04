# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Company, type: :model do
  describe "with sorting" do
    let(:journey_query_2_days_ago) { FactoryBot.create(:journey_query, company: company_a, created_at: 2.days.ago, updated_at: 2.days.ago) }
    let(:journey_query_yesterday) { FactoryBot.create(:journey_query, company: company_c, created_at: Time.zone.yesterday, updated_at: Time.zone.yesterday) }
    let(:company_a) { FactoryBot.create(:companies_company, name: "abc cargo", country: FactoryBot.create(:country_cn)) }
    let(:company_c) { FactoryBot.create(:companies_company, country: FactoryBot.create(:country_uk)) }
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_api_company) { described_class.sorted_by(sort_by) }

    before do
      journey_query_2_days_ago
      journey_query_yesterday
    end

    context "when sorting companies by name" do
      let(:sort_key) { "name" }

      context "when sorting in ascending order" do
        let(:direction_key) { "asc" }

        it "returns companies with name in ascending order" do
          expect(sorted_api_company.ids).to eq([company_a.id, company_c.id])
        end
      end

      context "when sorting in descending order" do
        let(:direction_key) { "desc" }

        it "returns companies with name in descending order" do
          expect(sorted_api_company.ids).to eq([company_c.id, company_a.id])
        end
      end
    end

    context "when sorting companies by country" do
      let(:sort_key) { "country" }

      context "when sorting in descending order" do
        let(:direction_key) { "desc" }

        it "returns companies with country in ascending order" do
          expect(sorted_api_company.ids).to eq([company_c.id, company_a.id])
        end
      end

      context "when sorting in ascending order" do
        let(:direction_key) { "asc" }

        it "returns companies with country in descending order" do
          expect(sorted_api_company.ids).to eq([company_a.id, company_c.id])
        end
      end
    end

    context "when sorting companies by activity" do
      let(:sort_key) { "activity" }

      context "when sorting in descending order" do
        let(:direction_key) { "desc" }

        it "returns companies with country in descending order" do
          expect(sorted_api_company.ids).to eq([company_c.id, company_a.id])
        end
      end

      context "when sorting in ascending order" do
        let(:direction_key) { "asc" }

        it "returns companies with country in ascending order" do
          expect(sorted_api_company.ids).to eq([company_a.id, company_c.id])
        end
      end

      context "with invalid sort option" do
        let(:sort_key) { "crypto_coins" }
        let(:direction_key) { "asc" }

        it "returns companies with country in ascending order" do
          expect { sorted_api_company.ids }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "with filtering" do
    let(:journey_query_1_week_ago) { FactoryBot.create(:journey_query, company: company, created_at: 1.week.ago, updated_at: 1.week.ago) }
    let(:journey_query_2_days_ago) { FactoryBot.create(:journey_query, company: company_a, created_at: 2.days.ago, updated_at: 2.days.ago) }
    let(:journey_query_yesterday) { FactoryBot.create(:journey_query, company: company_c, created_at: Time.zone.yesterday, updated_at: Time.zone.yesterday) }
    let(:company_a) { FactoryBot.create(:companies_company, name: "abc cargo", country: FactoryBot.create(:country_cn)) }
    let(:company_c) { FactoryBot.create(:companies_company, country: FactoryBot.create(:country_uk)) }
    let(:company) { FactoryBot.create(:companies_company) }
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_api_company) { described_class.sorted_by(sort_by) }

    before do
      journey_query_1_week_ago
      journey_query_2_days_ago
      journey_query_yesterday
    end

    context "when filtering companies by name" do
      let(:filter_name_search) { described_class.name_search("abc") }

      it "returns companies with name `abc cargo`" do
        expect(filter_name_search.ids).to eq([company_a.id])
      end
    end

    context "when filtering companies by country" do
      let(:filter_country_search) { described_class.country_search("United Kingdom") }

      it "returns companies with country `United Kingdom`" do
        expect(filter_country_search.ids).to eq([company_c.id])
      end
    end

    context "when filtering companies by activity between dates" do
      it "returns companies with queries updated between starting 3 days ago until today" do
        expect(described_class.activity_search(3.days.ago..Time.zone.today).ids).to match_array([company_a.id, company_c.id])
      end

      it "returns companies with queries updated between starting last couple of weeks until 2 days ago" do
        expect(described_class.activity_search(2.weeks.ago..2.days.ago).ids).to match_array([company_a.id, company.id])
      end
    end
  end
end
