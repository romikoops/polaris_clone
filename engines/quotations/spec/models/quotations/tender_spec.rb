# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe Tender, type: :model do
    subject { FactoryBot.build :quotations_tender }

    context 'Associations' do
      %i(quotation origin_hub destination_hub tenant_vehicle line_items).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'Validity' do
      it { is_expected.to be_valid }
    end

  end
end
