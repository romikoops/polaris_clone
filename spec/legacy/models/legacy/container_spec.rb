# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Container, type: :model do
    let(:container) { FactoryBot.build(:legacy_container, weight_class: nil, size_class: 'fcl') }
    let(:container_attributes) { FactoryBot.attributes_for(:legacy_container) }

    describe '.extract' do
      it 'initialize the model from the attributes' do
        containers = described_class.extract([container_attributes])

        expect(containers.first.cargo_class).to eq(container_attributes[:cargo_class])
      end
    end

    describe '#size' do
      it 'splits the size_class and returns the size' do
        expect(container.size).to eq('fcl')
      end
    end

    describe '#validate!' do
      let(:container) { FactoryBot.build(:legacy_container, weight_class: nil, size_class: 'fcl') }

      it 'populates the model before the validation' do
        expect(container.validate!).to eq(true)
      end
    end
  end
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint           not null, primary key
#  cargo_class     :string
#  contents        :string
#  customs_text    :string
#  dangerous_goods :boolean
#  gross_weight    :decimal(, )
#  hs_codes        :string           default([]), is an Array
#  payload_in_kg   :decimal(, )
#  quantity        :integer
#  size_class      :string
#  tare_weight     :decimal(, )
#  unit_price      :jsonb
#  weight_class    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sandbox_id      :uuid
#  shipment_id     :integer
#
# Indexes
#
#  index_containers_on_sandbox_id  (sandbox_id)
#
