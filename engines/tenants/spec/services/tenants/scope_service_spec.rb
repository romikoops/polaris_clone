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
          base_pricing: false,
          cargo_info_level: 'text',
          cargo_overview_only: false,
          carriage_options: { on_carriage: { export: 'optional', import: 'optional' }, pre_carriage: { export: 'optional', import: 'optional' } },
          chargeable_weight_view: 'dynamic',
          closed_after_map: false,
          closed_quotation_tool: false,
          closed_registration: false,
          closed_shop: false,
          condense_local_fees_pdf: false,
          consolidation: {
            cargo: {
              backend: false,
              frontend: false
            },
            trucking: {
              calculation: false,
              comparative: false,
              load_meterage_only: false
            }
          },
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
          hide_user_pricing_requests: true,
          hide_converted_grand_total: false,
          hide_grand_total: false,
          hide_sub_totals: false,
          incoterm_info_level: 'text',
          links: { about: '', legal: '' },
          mandatory_form_fields: {
            total_value_goods: false,
            description_of_goods: false,
            phone_for_signup: false
          },
          modes_of_transport: {
            air: { cargo_item: true, container: false },
            ocean: { cargo_item: true, container: true },
            rail: { cargo_item: false, container: false },
            truck: { container: false, cargo_item: false }
          },
          no_aggregated_cargo: false,
          non_stackable_goods: true,
          offer_disclaimers: false,
          open_quotation_tool: false,
          quote_card: {
            sub_totals: {
              import: true,
              export: true,
              cargo: true,
              trucking_pre: true,
              trucking_on: true
            },
            sections: {
              charge_icons: true,
              import: true,
              export: true,
              cargo: true,
              trucking_pre: true,
              trucking_on: true
            },
            consolidated_fees: false
          },
          quote_notes: 'Quote Notes from the FactoryBot Factory',
          require_full_address: true,
          send_email_on_quote_download: false,
          show_beta_features: false,
          show_chargeable_weight: false,
          terms: ['You verify that all the information provided above is true', 'You agree to the presented terms and conditions.', 'The Shop Operator is to discuss the validity of the presented prices with the product owners.'],
          total_dimensions: true,
          translation_overrides: false,
          values: {
            weight: {
              unit: 't',
              decimals: 3
            }
          },
          voyage_info: {
            carrier: true,
            voyage_code: true,
            vessel: true,
            service_level: true
          },
          side_nav: {
            agent: %w(dashboard shipments profile),
            admin: %w(dashboard shipments hubs pricing schedules clients routes currencies settings),
            shipper: %w(dashboard shipments profile contacts)
          },
          landing_page_video: nil,
          loading_image: nil,
          blacklisted_emails: [],
          validity_logic: 'vatos'
        }
      end

      it 'returns the entire correct scope' do
        expect(described_class.new(target: legacy_user).fetch).to eq(expected_scope.with_indifferent_access)
      end
    end

    context 'key given' do
      let(:key) { :quote_notes }

      it 'returns correct value of the correct scope' do
        expect(described_class.new(target: legacy_user).fetch(key)).to eq(
          'Quote Notes from the FactoryBot Factory'
        )
      end
    end

    context 'merging scope from user' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant_h) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
      let(:legacy_user_h) { FactoryBot.create(:legacy_user, tenant: tenant) }
      let(:tenants_user_h) { ::Tenants::User.find_by(legacy_id: legacy_user_h.id) }

      it 'returns true' do
        FactoryBot.create(:tenants_scope, target: tenants_tenant_h)
        FactoryBot.create(:tenants_scope, target: tenants_user_h, content: { one: true })
        expect(described_class.new(target: legacy_user_h).fetch(:one)).to eq(true)
      end
    end

    context 'merging scope from users company' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let!(:company) { FactoryBot.create(:tenants_company, tenant: tenants_tenant_h, name: 'One') }
      let(:tenants_tenant_h) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
      let(:legacy_user_h) { FactoryBot.create(:legacy_user, tenant: tenant) }
      let(:tenants_user_h) { ::Tenants::User.find_by(legacy_id: legacy_user_h.id) }

      it 'returns true' do
        tenants_user_h.update(company: company)
        FactoryBot.create(:tenants_scope, target: tenants_tenant_h)
        FactoryBot.create(:tenants_scope, target: company, content: { one: true })
        expect(described_class.new(target: legacy_user_h).fetch(:one)).to eq(true)
      end
    end

    context 'merging scope from users company groups' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant_h) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
      let!(:company) { FactoryBot.create(:tenants_company, tenant: tenants_tenant_h, name: 'One') }
      let(:legacy_user_h) { FactoryBot.create(:legacy_user, tenant: tenant) }
      let(:tenants_user_h) { ::Tenants::User.find_by(legacy_id: legacy_user_h.id) }
      let!(:group) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'Two') }
      let!(:membership) { FactoryBot.create(:tenants_membership, group: group, member: company) }

      it 'returns true' do
        tenants_user_h.update(company: company)
        FactoryBot.create(:tenants_scope, target: tenants_tenant_h)
        FactoryBot.create(:tenants_scope, target: company, content: { one: true })
        FactoryBot.create(:tenants_scope, target: group, content: { two: true })
        expect(described_class.new(target: legacy_user_h).fetch(:one)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:two)).to eq(true)
      end
    end

    context 'merging scope from users company groups of groups' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant_h) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
      let!(:company) { FactoryBot.create(:tenants_company, tenant: tenants_tenant_h, name: 'Zero') }
      let(:legacy_user_h) { FactoryBot.create(:legacy_user, tenant: tenant) }
      let(:tenants_user_h) { ::Tenants::User.find_by(legacy_id: legacy_user_h.id) }
      let!(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'One') }
      let!(:group_2) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'Two') }
      let!(:group_3) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'Three') }
      let!(:membership_1) { FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user_h) }
      let!(:membership_2) { FactoryBot.create(:tenants_membership, group: group_2, member: tenants_user_h) }
      let!(:membership_3) { FactoryBot.create(:tenants_membership, group: group_3, member: group_1) }

      it 'returns true' do
        tenants_user_h.update(company: company)
        FactoryBot.create(:tenants_scope, target: tenants_tenant_h)
        FactoryBot.create(:tenants_scope, target: company, content: { zero: true })
        FactoryBot.create(:tenants_scope, target: group_1, content: { one: true })
        FactoryBot.create(:tenants_scope, target: group_2, content: { two: true })
        FactoryBot.create(:tenants_scope, target: group_3, content: { three: true })
        expect(described_class.new(target: legacy_user_h).fetch(:zero)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:one)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:two)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:three)).to eq(true)
      end
    end

    context 'merging scope from users groups' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant_h) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
      let(:legacy_user_h) { FactoryBot.create(:legacy_user, tenant: tenant) }
      let(:tenants_user_h) { ::Tenants::User.find_by(legacy_id: legacy_user_h.id) }
      let!(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'One') }
      let!(:group_2) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'Two') }
      let!(:membership_1) { FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user_h) }
      let!(:membership_2) { FactoryBot.create(:tenants_membership, group: group_2, member: tenants_user_h) }

      it 'returns true' do
        FactoryBot.create(:tenants_scope, target: tenants_tenant_h)
        FactoryBot.create(:tenants_scope, target: group_1, content: { one: true })
        FactoryBot.create(:tenants_scope, target: group_2, content: { two: true })
        expect(described_class.new(target: legacy_user_h).fetch(:one)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:two)).to eq(true)
      end
    end

    context 'merging scope from users groups of groups' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant_h) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
      let(:legacy_user_h) { FactoryBot.create(:legacy_user, tenant: tenant) }
      let(:tenants_user_h) { ::Tenants::User.find_by(legacy_id: legacy_user_h.id) }
      let!(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'One') }
      let!(:group_2) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'Two') }
      let!(:group_3) { FactoryBot.create(:tenants_group, tenant: tenants_tenant_h, name: 'Three') }
      let!(:membership_1) { FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user_h) }
      let!(:membership_2) { FactoryBot.create(:tenants_membership, group: group_2, member: tenants_user_h) }
      let!(:membership_3) { FactoryBot.create(:tenants_membership, group: group_3, member: group_1) }

      it 'returns true' do
        FactoryBot.create(:tenants_scope, target: tenants_tenant_h)
        FactoryBot.create(:tenants_scope, target: group_1, content: { one: true })
        FactoryBot.create(:tenants_scope, target: group_2, content: { two: true })
        FactoryBot.create(:tenants_scope, target: group_3, content: { three: true })
        expect(described_class.new(target: legacy_user_h).fetch(:one)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:two)).to eq(true)
        expect(described_class.new(target: legacy_user_h).fetch(:three)).to eq(true)
      end
    end
  end
end
