# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ScopeSerializer do
    let(:scope) { Api::Scope.new(content: Organizations::DEFAULT_SCOPE) }
    let(:serialized_scope) { described_class.new(scope).serializable_hash }
    let(:target) { serialized_scope.dig(:data, :attributes) }

    it "returns the correct scope attributes", :aggregate_failures do
      expect(target[:links]).to eq(Organizations::DEFAULT_SCOPE["links"])
      expect(target[:loginMandatory]).to eq(Organizations::DEFAULT_SCOPE["closed_shop"])
    end
  end
end
