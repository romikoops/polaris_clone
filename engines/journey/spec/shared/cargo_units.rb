# frozen_string_literal: true

RSpec.shared_context "journey_cargo_units" do
  let(:cargo_unit_params) do
    [
      {
        cargo_class: "lcl",
        height_value: 1,
        length_value: 1,
        quantity: 1,
        stackable: true,
        weight_value: 1000,
        width_value: 1
      }
    ]
  end

  let(:cargo_units) do
    cargo_unit_params.map do |cargo_unit_param|
      FactoryBot.build(:journey_cargo_unit, **cargo_unit_param)
    end
  end
end
