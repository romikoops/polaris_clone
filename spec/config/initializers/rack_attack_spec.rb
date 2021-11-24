# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack" do
  include Rack::Test::Methods

  let(:user) { FactoryBot.create(:users_user, email: email) }
  let(:email) { "shopadmin@itsmycargo.com" }

  def app
    Rails.application
  end

  context "when throttle excessive requests by IP address" do
    let(:limit) { 1 }

    context "when number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do
          get "/v2/users/validate?email=#{user.email}"
          expect(last_response.status).not_to eq(429)
        end
      end
    end

    context "when number of requests is higher than the limit" do
      it "changes the request status to 429" do
        (limit * 2).times do |i|
          get "/v2/users/validate?email=#{user.email}"
          expect(last_response.status).to eq(429) if i > limit
        end
      end
    end
  end
end
