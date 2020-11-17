# frozen_string_literal: true

require 'rails_helper'

module Ledger
  RSpec.describe Fee, type: :model do
    it 'builds a valid object' do
      expect(FactoryBot.build(:ledger_fee).valid?).to eq(true)
    end

    ## Requires code from PR - Temporarily lowering coverage to pass

    describe '.carriage' do
      let(:line_service) { FactoryBot.create(:routing_line_service) }
      let(:pre_carriage_route) { FactoryBot.create(:pre_carriage_route, all_mots: true) }
      let(:pre_carriage_rls_target) { FactoryBot.create(:routing_route_line_service, route: pre_carriage_route, line_service: line_service) }
      let(:pre_carriage_rls_rate) { FactoryBot.create(:lcl_rate, target: pre_carriage_rls_target) }
      let(:pre_carriage_rls_fee) { pre_carriage_rls_rate.fees.first }

      let(:on_carriage_route) { FactoryBot.create(:on_carriage_route, all_mots: true) }
      let(:on_carriage_rls_target) { FactoryBot.create(:routing_route_line_service, route: on_carriage_route, line_service: line_service) }
      let(:on_carriage_rls_rate) { FactoryBot.create(:lcl_rate, target: on_carriage_rls_target) }
      let(:on_carriage_rls_fee) { on_carriage_rls_rate.fees.first }

      let(:ocean_route) { FactoryBot.create(:ocean_route) }
      let(:ocean_rls_target) { FactoryBot.create(:routing_route_line_service, route: ocean_route, line_service: line_service) }
      let(:ocean_rls_rate) { FactoryBot.create(:lcl_rate, target: ocean_rls_target) }
      let(:ocean_rls_fee) { ocean_rls_rate.fees.first }

      let(:conn_target) { FactoryBot.create(:tenant_routing_connection, inbound: pre_carriage_rls_target, outbound: ocean_rls_target) }
      let(:conn_rate) { FactoryBot.create(:lcl_rate, target: conn_target) }
      let(:conn_fee) { conn_rate.fees.first }

      it 'returns the correct carriage for the route' do
        expect(pre_carriage_rls_fee.carriage).to eq(:pre)
        expect(on_carriage_rls_fee.carriage).to eq(:on)
        expect(conn_fee.carriage).to eq(nil)
        expect(ocean_rls_fee.carriage).to eq(nil)
      end
    end
  end
end

# == Schema Information
#
# Table name: ledger_fees
#
#  id                  :uuid             not null, primary key
#  action              :integer          default("nothing")
#  applicable          :integer          default("self")
#  base                :decimal(, )      default(0.000001)
#  cargo_class         :bigint           default("00")
#  cargo_type          :bigint           default("LCL")
#  category            :integer          default(0)
#  code                :string
#  load_meterage_limit :decimal(, )      default(0.0)
#  load_meterage_logic :integer          default("regular")
#  load_meterage_ratio :decimal(, )      default(0.0)
#  load_meterage_type  :integer          default("height")
#  order               :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rate_id             :uuid
#
# Indexes
#
#  index_ledger_fees_on_cargo_class  (cargo_class)
#  index_ledger_fees_on_cargo_type   (cargo_type)
#  index_ledger_fees_on_category     (category)
#  index_ledger_fees_on_rate_id      (rate_id)
#
