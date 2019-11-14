# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Unit, type: :model do
    it_behaves_like 'a Cargo Unit' do
      subject do
        unit = FactoryBot.build(:cargo_unit, :lcl, quantity: 2,
                                                   weight_value: 3000,
                                                   width_value: 1.20,
                                                   length_value: 0.80,
                                                   height_value: 1.40)
        unit.validate
        unit
      end
    end
  end
end
