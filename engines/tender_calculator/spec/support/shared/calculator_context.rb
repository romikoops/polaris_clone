# frozen_string_literal: true

module TenderCalculator
  RSpec.shared_context 'when calculator' do
    let(:cargo_unit) { FactoryBot.create(:lcl_unit, weight_value: 30, volume_value: 40) }
    let(:targeted_rate) do
      FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate,
                        :with_target, cargo: cargo_unit)
    end
    let(:cargo_rate) { targeted_rate.object }
    let(:target_cargo) { targeted_rate.targets.first }
  end
end
