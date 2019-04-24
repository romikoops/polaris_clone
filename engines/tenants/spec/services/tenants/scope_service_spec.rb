# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenants::ScopeService do
  describe '#fetch' do
    let(:legacy_user) { FactoryBot.create(:legacy_user) }
    let(:tenants_user) { ::Tenants::User.find_by(legacy_id: legacy_user.id) }
    let!(:scope) { FactoryBot.create(:tenants_scope, target: tenants_user) }

    context 'no key given' do
      let(:expected_scope) do
        {
          cargo_info_level: 'text',
          cargo_overview_only: false,
          carriage_options: { on_carriage: { export: 'optional', import: 'optional' }, pre_carriage: { export: 'optional', import: 'optional' } },
          chargeable_weight_view: 'dynamic',
          closed_after_map: false,
          closed_quotation_tool: false,
          closed_registration: false,
          closed_shop: false,
          condense_local_fees_pdf: false,
          consolidation: { cargo: { backend: false, frontend: false }, trucking: { calculation: false, load_meterage_only: false } },
          continuous_rounding: false,
          currency_conversion: true,
          customs_export_paper: false,
          dangerous_goods: false,
          dedicated_pricings_only: false,
          default_direction: false,
          detailed_billing: true,
          email_all_quotes: false,
          email_on_registration: true,
          feature_uploaders: false,
          fee_detail: 'key_and_name',
          fine_fee_detail: true,
          fixed_currency: false,
          fixed_exchange_rate: false,
          fixed_exchange_rates: true,
          freight_in_original_currency: false,
          hard_trucking_limit: true,
          has_customs: false,
          has_insurance: false,
          hide_converted_grand_total: false,
          hide_grand_total: false,
          hide_sub_totals: false,
          incoterm_info_level: 'text',
          links: { about: '', legal: '' },
          mandatory_form_fields: false,
          modes_of_transport: { air: { cargo_item: true, container: true }, ocean: { cargo_item: true, container: true }, rail: { cargo_item: true, container: true } },
          no_aggregated_cargo: false,
          non_stackable_goods: true,
          offer_disclaimers: false,
          open_quotation_tool: false,
          quote_notes: 'Quote Notes from the FactoryBot Factory',
          require_full_address: true,
          send_email_on_quote_download: false,
          show_beta_features: false,
          show_chargeable_weight: false,
          terms: ['You verify that all the information provided above is true', 'You agree to the presented terms and conditions.', 'The Shop Operator is to discuss the validity of the presented prices with the product owners.'],
          total_dimensions: true,
          translation_overrides: false
        }
      end

      it 'returns the entire correct scope' do
        expect(described_class.new(user: legacy_user).fetch).to eq(expected_scope.with_indifferent_access)
      end
    end

    context 'key given' do
      let(:key) { :quote_notes }

      it 'returns correct value of the correct scope' do
        expect(described_class.new(user: legacy_user).fetch(key)).to eq(
          'Quote Notes from the FactoryBot Factory'
        )
      end
    end
  end
end
