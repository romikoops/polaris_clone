# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::QueryDecorator do
  include_context "organization"
  include_context "journey_pdf_setup"
  let(:scope) { { default_currency: "EUR" } }
  let(:decorated_query) { described_class.new(query, context: { scope: scope }) }

  describe ".references" do
    let(:refs) { decorated_query.references }

    it "generates the IMC Reference Numbers based on the timestamps" do
      expect(refs.length).to eq(1)
    end
  end

  describe ".currency" do
    let(:currency) { decorated_query.currency }

    it "returns the client's currency" do
      expect(currency).to eq(client.settings.currency)
    end

    context "when client is nil" do
      let(:client) { nil }

      it "returns the default currency currency" do
        expect(currency).to eq(scope[:default_currency])
      end
    end
  end

  describe "#load_type" do
    let(:query) { FactoryBot.create(:journey_query, organization: organization, load_type: load_type) }

    context "when fcl" do
      let(:load_type) { "fcl" }

      it "returns 'container'" do
        expect(decorated_query.load_type).to eq("container")
      end
    end

    context "when lcl" do
      let(:load_type) { "lcl" }

      it "returns 'cargo_item'" do
        expect(decorated_query.load_type).to eq("cargo_item")
      end
    end
  end
end
