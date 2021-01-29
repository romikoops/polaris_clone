require "rails_helper"

module Organizations
  RSpec.describe Scope, type: :model do
    context "When updating content attributes directly as the model's" do
      let(:scope) { FactoryBot.create(:organizations_scope, closed_shop: true) }

      it "uses the dynamic setter safely" do
        expect(scope.content["closed_shop"]).to eq true
      end
    end
  end
end
