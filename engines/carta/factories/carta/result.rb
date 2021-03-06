# frozen_string_literal: true

FactoryBot.define do
  factory :carta_result, class: "Carta::Result" do
    skip_create

    id { "itsmycargo:123456789" }
    type { "locode" }
    address { "DEHAM, DE" }
    latitude { "57.694253" }
    longitude { "11.854048" }
    street { "" }
    street_number { "" }
    postal_code { "20457" }
    locality { "Hamburg" }
    administrative_area { "" }
    country { "DE" }
    function { "ocean" }

    trait :address do
      id { "here:123456789" }
      type { "address" }
      address { "Brooktorkai 7, Hamburg, DE" }
      function { nil }
    end

    initialize_with do
      new(attributes)
    end
  end
end
