# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::CargoDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }

  let(:load_type) { "cargo_item" }
  let!(:shipment) do
    FactoryBot.create(:complete_legacy_shipment,
      organization: organization,
      user: user,
      load_type: load_type,
      with_breakdown: true,
      with_tenders: true,
      with_full_breakdown: true)
  end
  let(:chargeable_weight_view) { "volume" }
  let(:scope) { {"show_chargeable_weight" => true, "chargeable_weight_view" => chargeable_weight_view} }
  let(:tender) { Quotations::Tender.last }
  let(:cargo) { tender.cargo }
  let(:klass) { described_class.decorate(cargo, context: {scope: scope, tender: tender}) }

  before do
    Draper::ViewContext.controller = Pdf::ApplicationController.new

    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
    shipment.charge_breakdowns.map(&:tender).each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
  end

  describe ".determine_chargeable_weight_row" do
    context "when chargeable_weight_view is volume" do
      let(:chargeable_weight_view) { "volume" }

      it "generates the quote pdf" do
        expect(klass.determine_chargeable_weight_row).to include tender.cargo.volume.value.to_s
      end
    end

    context "when chargeable_weight_view is weight" do
      let(:chargeable_weight_view) { "weight" }

      it "generates the quote pdf" do
        expect(klass.determine_chargeable_weight_row).to include "1344.0 kg"
      end
    end

    context "when chargeable_weight_view is dynamic" do
      let(:chargeable_weight_view) { "dynamic" }

      before do
        allow(cargo).to receive(:volume).and_return(Measured::Volume.new(0.4, :m3))
      end

      it "generates the quote pdf" do
        expect(klass.determine_chargeable_weight_row).to include "500.0 kg"
      end
    end
  end

  describe ".cargo_item_type_description" do
    context "when legacy cargo is present" do
      let(:cargo) { Cargo::Unit.last }

      before do
        cargo.update(legacy: FactoryBot.create(:legacy_cargo_item))
      end

      it "generates the quote pdf" do
        expect(klass.cargo_item_type_description).to include "Pallet"
      end
    end
  end
end
