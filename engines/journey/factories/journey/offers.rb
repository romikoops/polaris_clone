# frozen_string_literal: true

FactoryBot.define do
  factory :journey_offer, class: "Journey::Offer" do
    association :query, factory: :journey_query
    results { [association(:journey_result)] }

    after(:build) do |offer|
      offer.file.attach(io: StringIO.new, filename: "offer.pdf")
    end
    file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/logo-blue.png", __dir__), "image/png") }
  end
end
