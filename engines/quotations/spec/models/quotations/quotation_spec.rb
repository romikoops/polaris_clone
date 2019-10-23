# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe Quotations::Quotation, type: :model do
    subject { FactoryBot.build :quotations_quotation }

    context 'Associations' do
      %i(tenant user origin_nexus destination_nexus sandbox).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'Validity' do
      it { is_expected.to be_valid }
    end
    
  end
end
