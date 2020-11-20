# frozen_string_literal: true

FactoryBot.define do
  factory :margin_preview_result, class: "Hash" do
    transient do
      margin { nil }
      target { nil }
      target_name { nil }
      service_level { nil }
    end

    initialize_with do
      data.deep_dup
    end

    data do
      {
        "freight" => {
          "fees" => {
            "bas" => {
              "original" => {
                "rate" => "25.0",
                "base" => "0.000001",
                "rate_basis" => "PER_WM",
                "currency" => "EUR",
                "hw_threshold" => nil,
                "hw_rate_basis" => nil,
                "min" => "1.0",
                "range" => []
              },
              "margins" => [
                {"source_id" => margin&.id,
                 "source_type" => margin&.class&.to_s,
                 "margin_value" => "0.1",
                 "operator" => "%",
                 "data" => {
                   "rate" => "27.5",
                   "base" => "0.000001",
                   "rate_basis" => "PER_WM",
                   "currency" => "EUR",
                   "hw_threshold" => nil,
                   "hw_rate_basis" => nil,
                   "min" => "1.1",
                   "range" => []
                 },
                 "target_name" => target_name,
                 "target_id" => target&.id,
                 "target_type" => target.class.to_s,
                 "url_id" => target.id}
              ],
              "flatMargins" => [],
              "final" => {
                "rate" => "27.5",
                "base" => "0.000001",
                "rate_basis" => "PER_WM",
                "currency" => "EUR",
                "hw_threshold" => nil,
                "hw_rate_basis" => nil,
                "min" => "1.1",
                "range" => []
              },
              "rate_origin" => nil
            }
          },
          "service_level" => service_level&.name
        }
      }
    end
  end
end
