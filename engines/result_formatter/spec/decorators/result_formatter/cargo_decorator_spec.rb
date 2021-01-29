# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::CargoDecorator do
  include_context "organization"
  let(:result) { FactoryBot.create(:journey_result) }
  let(:decorated_result) { ResultFormatter::ResultDecorator.new(FactoryBot.create(:journey_result)) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }

  let(:cargo_unit) { FactoryBot.create(:journey_cargo_unit, weight_value: 500, quantity: 1) }
  let(:chargeable_weight_view) { "volume" }
  let(:scope_content) { {"show_chargeable_weight" => true, "chargeable_weight_view" => chargeable_weight_view} }
  let(:scope) { OrganizationManager::ScopeService.new(target: user, organization: organization).fetch }
  let(:klass) { described_class.decorate(cargo_unit, context: {scope: scope, result: decorated_result, wm_ratio: 1000}) }

  before do
    Draper::ViewContext.controller = Pdf::ApplicationController.new
  end

  describe ".gross_weight_per_item" do
    it "renders the correct gross weight per item" do
      expect(klass.gross_weight_per_item).to include cargo_unit.weight.convert_to("kg").humanize
    end
  end

  describe ".render_chargeable_weight_row" do
    context "when chargeable_weight_view is volume" do
      let(:chargeable_weight_view) { "volume" }

      it "renders the correct chargeable weight" do
        expect(klass.render_chargeable_weight_row).to include cargo_unit.volume.value.to_s
      end
    end

    context "when chargeable_weight_view is weight" do
      let(:chargeable_weight_view) { "weight" }

      it "renders the correct chargeable weight" do
        expect(klass.render_chargeable_weight_row).to include "1344.0 kg"
      end
    end

    context "when chargeable_weight_view is dynamic" do
      let(:chargeable_weight_view) { "dynamic" }

      before do
        allow(cargo_unit).to receive(:volume).and_return(Measured::Volume.new(0.4, :m3))
      end

      it "renders the correct chargeable weight" do
        expect(klass.render_chargeable_weight_row).to include "500.0 kg"
      end
    end

    context "when chargeable_weight_view is both" do
      let(:chargeable_weight_view) { "both" }

      before do
        allow(cargo_unit).to receive(:volume).and_return(Measured::Volume.new(0.4, :m3))
      end

      it "renders the correct chargeable weight" do
        expect(klass.render_chargeable_weight_row).to include "0.5  t|m"
      end
    end
  end

  describe ".cargo_item_type_description" do
    context "when legacy cargo is present" do
      it "generates the quote pdf" do
        expect(klass.cargo_item_type_description).to include "Pallet"
      end
    end
  end
end
