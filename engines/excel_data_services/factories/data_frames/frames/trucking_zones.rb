# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_zones_frame, class: "Rover::DataFrame" do
    transient do
      zone_count { 3 }
      country_code { "DE" }
      sheet_name { "Zones" }
    end

    initialize_with do
      new(zones, types: ExcelDataServices::DataFrames::DataProviders::Trucking::Zones.column_types)
    end

    trait :alphanumeric do
      after(:build) do
        %w[AB10 AB19 AB20 SW1 SW2 SW3 SW4 SW5 SW6 SW7 SW8 SW9 SW10 SW11].each do |postal_code|
          FactoryBot.create(:trucking_location,
            :with_location,
            data: postal_code,
            country: factory_country_from_code(code: "GB"),
            location: FactoryBot.create(:locations_location, name: postal_code, country_code: "GB"))
        end
        Locations::Name.reindex
      end

      zones do
        [
          {"sheet_name" => sheet_name,
           "zone" => 1.0,
           "primary" => "AB10",
           "secondary" => nil,
           "identifier" => "postal_code",
           "country_code" => "GB",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 2.0,
           "primary" => "AB19",
           "secondary" => nil,
           "identifier" => "postal_code",
           "country_code" => "GB",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 3.0,
           "primary" => nil,
           "identifier" => "postal_code",
           "secondary" => "SW1-SW11",
           "country_code" => "GB",
           "query_method" => "location"}
        ]
      end
    end

    trait :zipcode do
      zones do
        [
          {"sheet_name" => sheet_name,
           "zone" => 1.0,
           "primary" => "20457",
           "secondary" => nil,
           "country_code" => "ZA",
           "identifier" => "zipcode",
           "query_method" => "zipcode"},
          {"sheet_name" => sheet_name,
           "zone" => 2.0,
           "primary" => nil,
           "secondary" => "30000 - 30025",
           "country_code" => "ZA",
           "identifier" => "zipcode",
           "query_method" => "zipcode"},
          {"sheet_name" => sheet_name,
           "zone" => 3.0,
           "primary" => nil,
           "secondary" => "10000 - 10025",
           "country_code" => "ZA",
           "identifier" => "zipcode",
           "query_method" => "zipcode"}
        ]
      end
    end

    trait :distance do
      zones do
        [
          {"sheet_name" => sheet_name,
           "zone" => 1.0,
           "primary" => "10",
           "secondary" => nil,
           "country_code" => "ZA",
           "identifier" => "distance",
           "query_method" => "distance"},
          {"sheet_name" => sheet_name,
           "zone" => 2.0,
           "primary" => nil,
           "secondary" => "20 - 50",
           "country_code" => "ZA",
           "identifier" => "distance",
           "query_method" => "distance"},
          {"sheet_name" => sheet_name,
           "zone" => 3.0,
           "primary" => nil,
           "secondary" => "60-130",
           "country_code" => "ZA",
           "identifier" => "distance",
           "query_method" => "distance"}
        ]
      end
    end

    trait :postal_code do
      zones do
        [
          {"sheet_name" => sheet_name,
           "zone" => 1.0,
           "primary" => "20457",
           "secondary" => nil,
           "country_code" => "DE",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 2.0,
           "primary" => nil,
           "secondary" => "30000 - 30555",
           "country_code" => "DE",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 3.0,
           "primary" => nil,
           "secondary" => "10000 - 10200",
           "country_code" => "DE",
           "query_method" => "location"}
        ]
      end
    end

    trait :city do
      after(:build) do
        [
          {city: "Cape Town", province: "Western Cape"},
          {city: "Durban", province: "KwaZulu Natal"},
          {city: "Johannesburg", province: "Gauteng"}
        ].each do |data|
          FactoryBot.create(:locations_name,
            name: [data[:city], data[:province]].join(", "),
            city: data[:city],
            country: "Republic of South Africa",
            country_code: "ZA",
            location: FactoryBot.create(:locations_location,
              name: [data[:city], data[:province]].join(", "),
              country_code: "ZA"))
        end
        Locations::Name.reindex
      end

      zones do
        [
          {"sheet_name" => sheet_name,
           "zone" => 1.0,
           "primary" => "Cape Town",
           "secondary" => "Western Cape",
           "country_code" => "ZA",
           "identifier" => "city",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 2.0,
           "primary" => "Durban",
           "secondary" => "KwaZulu Natal",
           "country_code" => "ZA",
           "identifier" => "city",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 3.0,
           "primary" => "Johannesburg",
           "secondary" => "Gauteng",
           "country_code" => "ZA",
           "identifier" => "city",
           "query_method" => "location"}
        ]
      end
    end

    trait :locode do
      after(:build) do
        %w[DEHAM DEBRV DEFRA].each do |locode|
          FactoryBot.create(:locations_name,
            locode: locode,
            location: FactoryBot.create(:locations_location, name: locode, country_code: "DE"))
        end
        Locations::Name.reindex
      end

      zones do
        [
          {"sheet_name" => sheet_name,
           "zone" => 1.0,
           "primary" => "DEHAM",
           "secondary" => nil,
           "country_code" => "DE",
           "identifier" => "locode",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 2.0,
           "primary" => "DEBRV",
           "secondary" => nil,
           "country_code" => "DE",
           "identifier" => "locode",
           "query_method" => "location"},
          {"sheet_name" => sheet_name,
           "zone" => 3.0,
           "primary" => "DEFRA",
           "secondary" => nil,
           "country_code" => "DE",
           "identifier" => "locode",
           "query_method" => "location"}
        ]
      end
    end

    trait :invalid do
      zones do
        [
          {
            "sheet_name" => sheet_name,
            "zone" => 1.0,
            "zipcode" => nil,
            "secondary" => "234www",
            "country_code" => "ghfy"
          }
        ]
      end
    end
  end
end
