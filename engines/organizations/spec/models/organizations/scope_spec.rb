# frozen_string_literal: true

require "rails_helper"

module Organizations
  RSpec.describe Scope, type: :model do
    context "when updating content attributes directly as the model's" do
      let(:scope) { FactoryBot.create(:organizations_scope, closed_shop: true) }

      it "uses the dynamic setter safely" do
        expect(scope.content["closed_shop"]).to eq true
      end

      context "when updating content values" do
        let(:scope) { FactoryBot.create(:organizations_scope, terms: "specific terms") }

        it "parses '0' as false" do
          scope.update(closed_shop: "0")
          expect(scope.reload.content["closed_shop"]).to eq false
        end

        it "parses '1' as true" do
          scope.update(closed_shop: "1")
          expect(scope.reload.content["closed_shop"]).to eq true
        end

        it "parses '1' as 1" do
          scope.update(search_buffer: "1")
          expect(scope.reload.content["search_buffer"]).to eq 1
        end

        it "sets '' as nil for NilClass" do
          scope.update(validity_period: "")
          expect(scope.reload.content["validity_period"]).to eq nil
        end
      end
    end
  end
end
