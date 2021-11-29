# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Operations::CounterpartHubExpander do
  include_context "for excel_data_services setup"

  let(:extracted_table) { described_class.state(state: state_arguments).frame }
  let(:base_rows) do
    [{ "carrier_code" => "ssc",
        "row" => 2,
        "sheet_name" => "Local Charges",
        "service" => "standard",
        "group_id" => "372b2784-c689-4a1e-937b-eac61376950d",
        "group_name" => "Local Charges Group One",
        "effective_date" => Date.parse("Sat, 01 May 2021"),
        "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
        "locode" => "DEHAM",
        "hub" => "Hamburg",
        "country" => "Germany",
        "counterpart_locode" => nil,
        "counterpart_hub" => nil,
        "counterpart_country" => nil,
        "mode_of_transport" => "ocean",
        "carrier" => "SSC",
        "direction" => "export",
        "service_level" => "standard",
        "cargo_class" => "lcl",
        "load_type" => "lcl",
        "min" => nil,
        "max" => nil,
        "fee_name" => "B/L Fee",
        "fee_code" => "bl",
        "currency" => "EUR",
        "rate_basis" => "PER_TON",
        "range_min" => nil,
        "range_max" => nil,
        "base" => nil,
        "ton" => 0.4e1,
        "organization_id" => "3a9e8e43-9906-43be-b023-a3f50f8a832f" },
      { "carrier_code" => "ssc",
        "row" => 3,
        "sheet_name" => "Local Charges",
        "service" => "standard",
        "group_id" => "372b2784-c689-4a1e-937b-eac61376950d",
        "group_name" => "Local Charges Group One",
        "effective_date" => Date.parse("Sat, 01 May 2021"),
        "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
        "locode" => "DEHAM",
        "hub" => "Hamburg",
        "country" => "Germany",
        "counterpart_locode" => "ZACPT",
        "counterpart_hub" => nil,
        "counterpart_country" => nil,
        "mode_of_transport" => "ocean",
        "carrier" => "SSC",
        "direction" => "export",
        "service_level" => "standard",
        "cargo_class" => "lcl",
        "load_type" => "lcl",
        "min" => nil,
        "max" => nil,
        "fee_name" => "THC",
        "fee_code" => "thc",
        "currency" => "EUR",
        "rate_basis" => "PER_TON",
        "range_min" => nil,
        "range_max" => nil,
        "base" => nil,
        "ton" => 20,
        "organization_id" => "3a9e8e43-9906-43be-b023-a3f50f8a832f" },
      { "carrier_code" => "ssc",
        "row" => 4,
        "sheet_name" => "Local Charges",
        "service" => "standard",
        "group_id" => "372b2784-c689-4a1e-937b-eac61376950d",
        "group_name" => "Local Charges Group One",
        "effective_date" => Date.parse("Sat, 01 May 2021"),
        "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
        "locode" => "DEHAM",
        "hub" => "Hamburg",
        "country" => "Germany",
        "counterpart_locode" => nil,
        "counterpart_hub" => "Johannesburg",
        "counterpart_country" => nil,
        "mode_of_transport" => "ocean",
        "carrier" => "SSC",
        "direction" => "export",
        "service_level" => "standard",
        "cargo_class" => "lcl",
        "load_type" => "lcl",
        "min" => nil,
        "max" => nil,
        "fee_name" => "IFPS",
        "fee_code" => "ifps",
        "currency" => "EUR",
        "rate_basis" => "PER_TON",
        "range_min" => nil,
        "range_max" => nil,
        "base" => nil,
        "ton" => 30,
        "organization_id" => "3a9e8e43-9906-43be-b023-a3f50f8a832f" }]
  end

  describe "#data" do
    let(:rows) { base_rows}

    it "returns the rows without counterpart_hub or counterpart_locode as they were" do
      expect(extracted_table[(extracted_table["counterpart_hub"].missing) & extracted_table["counterpart_locode"].missing]["fee_code"].to_a).to match_array(["bl"])
    end

    it "returns adds the general fee to the rows with counterpart_locode == 'ZACPT'" do
      expect(extracted_table[extracted_table["counterpart_locode"] == "ZACPT"]["fee_code"].to_a).to match_array(%w[bl thc])
    end

    it "returns adds the general fee to the rows with counterpart_hub == 'Johannesburg'" do
      expect(extracted_table[extracted_table["counterpart_hub"] == "Johannesburg"]["fee_code"].to_a).to match_array(%w[bl ifps])
    end

    context "when the counterpart assigned fees overlaps with general fees" do
      let(:rows) do
        base_rows + [
          { "carrier_code" => "ssc",
            "row" => 5,
            "sheet_name" => "Local Charges",
            "service" => "standard",
            "group_id" => "372b2784-c689-4a1e-937b-eac61376950d",
            "group_name" => "Local Charges Group One",
            "effective_date" => Date.parse("Sat, 01 May 2021"),
            "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
            "locode" => "DEHAM",
            "hub" => "Hamburg",
            "country" => "Germany",
            "counterpart_locode" => "ZACPT",
            "counterpart_hub" => nil,
            "counterpart_country" => nil,
            "mode_of_transport" => "ocean",
            "carrier" => "SSC",
            "direction" => "export",
            "service_level" => "standard",
            "cargo_class" => "lcl",
            "load_type" => "lcl",
            "min" => nil,
            "max" => nil,
            "fee_name" => "B/L Fee",
            "fee_code" => "bl",
            "currency" => "EUR",
            "rate_basis" => "PER_TON",
            "range_min" => nil,
            "range_max" => nil,
            "base" => nil,
            "ton" => 8,
            "organization_id" => "3a9e8e43-9906-43be-b023-a3f50f8a832f" }
        ]
      end

      it "returns overwrties the general fee to the rows with counterpart_locode == 'ZACPT'" do
        expect(extracted_table[extracted_table["counterpart_locode"] == "ZACPT"]["ton"].to_a).to match_array([8, 20])
      end
    end
  end
end
