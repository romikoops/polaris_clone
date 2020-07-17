# frozen_string_literal: true

require "rails_helper"
require_relative "../../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreators::Offer do
  include_context "full_offer"

  let(:valid_from) { offer.charges.map { |charge_section| charge_section.validity.first }.max }

  describe ".valid_from" do
    it "returns a the valid from date" do
      expect(offer.valid_from).to eq(valid_from)
    end
  end
end
