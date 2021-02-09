# frozen_string_literal: true

FactoryBot.define do
  factory :offer_calculator_request, class: "OfferCalculator::Request" do
    skip_create

    query { FactoryBot.create(:journey_query, organization: organization, client: client, creator: creator, load_type: cargo_trait) }
    params { FactoryBot.build(:journey_request_params, cargo_trait) }

    transient do
      organization { FactoryBot.create(:organizations_organization) }
      client { FactoryBot.create(:users_client) }
      creator { FactoryBot.create(:users_client) }
      cargo_trait { :lcl }
    end

    initialize_with do
      OfferCalculator::Request.new(query: query, params: params)
    end
  end
end
