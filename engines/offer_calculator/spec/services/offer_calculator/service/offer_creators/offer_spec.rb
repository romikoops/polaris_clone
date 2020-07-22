# frozen_string_literal: true

require "rails_helper"
require_relative "../../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreators::Offer do
  include_context "full_offer"

  let(:valid_from) { offer.charges.map { |charge_section| charge_section.validity.first }.max }
  let(:valid_until) { offer.charges.map { |charge_section| charge_section.validity.last }.min }

  describe ".valid_from" do
    it "returns a the valid from date" do
      expect(offer.valid_from).to eq(valid_from)
    end
  end

  describe ".valid_until" do
    context "without custom period" do
      it "returns a the valid until date" do
        expect(offer.valid_until).to eq(valid_until)
      end
    end

    context "with custom period" do
      before do
        FactoryBot.create(:organizations_scope, target: organization, content: {validity_period: 14})
      end

      it "returns a the valid until date" do
        expect(offer.valid_until).to eq(14.days.from_now.to_date)
      end
    end
  end
end
