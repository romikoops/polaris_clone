# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::FilterParamValidator do
  let(:options) do
    { sort_by: sort_by, direction: direction, search_by: search_by, search_query: search_query, before_date: before_date, after_date: after_date }
  end

  let(:direction) { "asc" }
  let(:filter_param_validator) { described_class.new(%w[name country activity], %w[name country activity], options: options) }
  let(:sort_by) { "name" }
  let(:search_by) { "country" }
  let(:search_query) { "Germany" }
  let(:before_date) { Time.zone.today.to_s }
  let(:after_date) { 2.weeks.ago.to_s }

  describe "search_by validation" do
    let(:search_by_error_codes) { filter_param_validator.errors.messages[:search_by].pluck(:error_code) }

    context "when search_by is present" do
      let(:search_by) { "invalid_option" }
      let(:search_query) { "" }

      before { filter_param_validator.valid? } # This call is required to trigger validation on `Api::FilterParamValidator` instance

      it "adds error with error code `INVALID_SEARCH_BY_OPTION` with invalid search by option" do
        expect(search_by_error_codes).to include("INVALID_SEARCH_BY_OPTION")
      end

      it "adds error with error code `SEARCH_QUERY_MISSING` with valid search by but search query is missing" do
        expect(search_by_error_codes).to include("SEARCH_QUERY_MISSING")
      end
    end

    context "when search_by is not present" do
      let(:search_by) { "" }

      it "returns filter params to be valid" do
        expect(filter_param_validator.valid?).to be true
      end
    end
  end

  describe "sort_by validation" do
    let(:sort_by_error_codes) { filter_param_validator.errors.messages[:sort_by].pluck(:error_code) }

    context "when sort_by is present" do
      let(:sort_by) { "invalid_sort_by" }
      let(:direction) { "" }

      before { filter_param_validator.valid? } # This call is required to trigger validation on `Api::FilterParamValidator` instance

      it "adds error with error code `INVALID_SORT_BY_OPTION` with invalid sort by" do
        expect(sort_by_error_codes).to include("INVALID_SORT_BY_OPTION")
      end

      it "adds error with error code `DIRECTION_MISSING` with valid sort by but missing direction" do
        expect(sort_by_error_codes).to include("DIRECTION_MISSING")
      end
    end

    context "when sort_by is not present, but other params are valid" do
      let(:sort_by) { "" }

      it "returns filter params to be valid" do
        expect(filter_param_validator.valid?).to be true
      end
    end
  end

  describe "activity validation" do
    context "when both before_date and after_date is present" do
      it "returns filter params to be valid" do
        expect(filter_param_validator.valid?).to be true
      end
    end

    context "when only before_date is present" do
      let(:after_date) { nil }

      it "returns filter params to be valid" do
        expect(filter_param_validator.valid?).to be true
      end
    end

    context "when only after_date is present" do
      let(:before_date) { nil }

      it "returns filter params to be valid" do
        expect(filter_param_validator.valid?).to be true
      end
    end
  end

  describe "#to_h" do
    let(:expected_params) do
      {
        sorted_by: "name_asc",
        country_search: "Germany",
        activity_search: Range.new(Date.strptime(after_date, described_class::REQUIRED_DATE_FORMAT), Date.strptime(before_date, described_class::REQUIRED_DATE_FORMAT))
      }
    end

    it "returns filter param as a hash" do
      expect(filter_param_validator.to_h).to eq(expected_params)
    end

    context "when sort_by is not specified" do
      let(:sort_by) { nil }

      it "returns params that does not contain sorted_by key" do
        expect(filter_param_validator.to_h).not_to have_key :sorted_by
      end
    end

    context "when after_date and before_date does not exist" do
      let(:before_date) { nil }
      let(:after_date) { nil }

      it "returns params that does not contain sorted_by key" do
        expect(filter_param_validator.to_h).not_to have_key :activity_search
      end
    end

    context "when search_by is not specified" do
      let(:search_by) { nil }

      it "returns params that does not contain key created by search_by" do
        expect(filter_param_validator.to_h).not_to have_key :country_search
      end
    end

    context "when before_date is not specified but after_date exist" do
      let(:before_date) { nil }

      it "returns params that contain activity date with before date in todays date by default" do
        expect(filter_param_validator.to_h[:activity_search]).to eq Range.new(Date.strptime(after_date, described_class::REQUIRED_DATE_FORMAT), described_class::DEFAULT_BEFORE_DATE)
      end
    end

    context "when after_date is not specified but before_date exist" do
      let(:after_date) { nil }

      it "returns params that contain activity date with default after date" do
        expect(filter_param_validator.to_h[:activity_search]).to eq Range.new(described_class::DEFAULT_AFTER_DATE, Date.strptime(before_date, described_class::REQUIRED_DATE_FORMAT))
      end
    end
  end
end
