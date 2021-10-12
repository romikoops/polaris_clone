# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::QueryDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) { FactoryBot.create(:journey_query, organization: organization, status: status) }
  let(:decorated_query) { described_class.new(query) }

  describe "#completed" do
    context "when the status is 'completed'" do
      let(:status) { "completed" }

      it "returns true" do
        expect(decorated_query.completed).to eq(true)
      end
    end

    context "when the status is 'running'" do
      let(:status) { "running" }

      it "returns false" do
        expect(decorated_query.completed).to eq(false)
      end
    end
  end
end
