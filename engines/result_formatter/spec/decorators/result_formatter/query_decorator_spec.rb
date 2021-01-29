# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::QueryDecorator do
  include_context "organization"
  include_context "journey_pdf_setup"
  let(:scope) { {default_currency: "EUR"} }
  let(:decorated_query) { ResultFormatter::QueryDecorator.new(query, context: {scope: scope}) }

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
end
