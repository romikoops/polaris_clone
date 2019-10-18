# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe Quotations::Quotation, type: :model do
    subject { described_class.new }

    context 'Associations' do
      %i(tenant user origin_nexus destination_nexus sandbox).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end
  end
end
