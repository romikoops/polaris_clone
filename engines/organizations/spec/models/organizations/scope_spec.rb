# frozen_string_literal: true

require "rails_helper"

module Organizations
  RSpec.describe Scope, type: :model do
    context "when updating content attributes directly as the model's" do
      let(:scope) { FactoryBot.create(:organizations_scope, closed_shop: true) }

      it "uses the dynamic setter safely" do
        expect(scope.content["closed_shop"]).to eq true
      end

      it "key can be accessed from the scope as a method" do
        expect(scope.closed_shop).to eq true
      end

      it "raises method missing when a non defined method is called" do
        expect { scope.random_method }.to raise_error(NoMethodError)
      end

      context "when key is not a part of the content but available in default scope" do
        it "value is fetched from the default scope" do
          expect(scope.terms).to be_present
        end
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

    context "when content attribute is a nested hash" do
      let(:scope) { FactoryBot.create(:organizations_scope, consolidation: { cargo: { backend: true } }) }

      it "nested hash value is accessable" do
        expect(scope.content.dig("consolidation", "cargo", "backend")).to eq true
      end

      it "defines pluralized method to return keys" do
        expect(scope.consolidations).to be_present
      end
    end

    context "when scope is not saved" do
      let(:scope) { FactoryBot.build(:organizations_scope, "consolidation" => { "cargo" => { "backend" => false } }) }

      it "contains extended key defined as a getter" do
        extended_key = "consolidation#{ContentSetter::SEPARATOR}cargo#{ContentSetter::SEPARATOR}backend"
        expect(scope.send(extended_key.to_sym)).to eq false
      end
    end

    context "when scope is saved" do
      let(:scope) { FactoryBot.build(:organizations_scope, "consolidation" => { "cargo" => { "backend" => false } }) }

      it "updates the value sent to the nested hash" do
        extended_key = "consolidation#{ContentSetter::SEPARATOR}cargo#{ContentSetter::SEPARATOR}backend"
        scope.send("#{extended_key}=", true)
        scope.save!
        expect(scope.reload.content.dig("consolidation", "cargo", "backend")).to eq true
      end
    end

    context "when nested hash is not a part of the scope" do
      let(:scope) { FactoryBot.build(:organizations_scope) }

      it "creates nested hash by copying from default when one of the key is set" do
        extended_key = "consolidation#{ContentSetter::SEPARATOR}cargo#{ContentSetter::SEPARATOR}backend"
        scope.send("#{extended_key}=", true)
        scope.save!
        expect(scope.reload.content.dig("consolidation", "cargo", "backend")).to be true
      end
    end

    describe "#key_name" do
      let(:scope) { FactoryBot.build(:organizations_scope) }

      it "returns readable key/label for the extended key" do
        extended_key = "consolidation#{ContentSetter::SEPARATOR}cargo#{ContentSetter::SEPARATOR}backend"
        expect(described_class.key_name(extended_key: extended_key)).to eq "Cargo Backend"
      end
    end
  end
end
