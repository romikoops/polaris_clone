# frozen_string_literal: true

module Tenants
  class ScopeService # rubocop:disable Metrics/ClassLength
    DEFAULT_SCOPE = {
      links: {
        about: '',
        legal: ''
      },
      terms: ['You verify that all the information provided above is true', 'You agree to the presented terms ' \
              'and conditions.',
              'The Shop Operator is to discuss the validity of the presented prices with the product owners.'],
      fee_detail: 'key_and_name',
      closed_shop: false,
      has_customs: false,
      consolidation: {
        cargo: {
          backend: false,
          frontend: false
        },
        trucking: {
          calculation: false,
          load_meterage_only: false,
          comparative: false
        }
      },
      has_insurance: false,
      fixed_currency: false,
      dangerous_goods: false,
      cargo_info_level: 'text',
      carriage_options: {
        on_carriage: {
          export: 'optional',
          import: 'optional'
        },
        pre_carriage: {
          export: 'optional',
          import: 'optional'
        }
      },
      detailed_billing: true,
      total_dimensions: true,
      modes_of_transport: {
        air: {
          container: false,
          cargo_item: true
        },
        rail: {
          container: false,
          cargo_item: false
        },
        ocean: {
          container: true,
          cargo_item: true
        },
        truck: {
          container: false,
          cargo_item: false
        }
      },
      closed_registration: false,
      continuous_rounding: false,
      incoterm_info_level: 'text',
      non_stackable_goods: true,
      open_quotation_tool: false,
      hide_user_pricing_requests: true,
      customs_export_paper: false,
      fixed_exchange_rates: true,
      base_pricing: false,
      require_full_address: true,
      closed_quotation_tool: false,
      quote_notes: "1) Prices subject to change\n        2) All fees are converted at the time of quotation\n        " \
                    "using that day's European Central bank exchange rates and are an approximation\n        " \
                    "of the final amount ot be paid. The amount paid at the time of settlement\n        " \
                    'will reflect the exchange rates of the day.',
      fine_fee_detail: true,
      hide_sub_totals: false,
      email_all_quotes: false,
      hide_grand_total: false,
      default_direction: false,
      currency_conversion: true,
      chargeable_weight_view: 'dynamic',
      show_chargeable_weight: false,
      condense_local_fees_pdf: false,
      freight_in_original_currency: false,
      show_beta_features: false,
      fixed_exchange_rate: false,
      hard_trucking_limit: true,
      hide_converted_grand_total: false,
      send_email_on_quote_download: false,
      cargo_overview_only: false,
      no_aggregated_cargo: false,
      mandatory_form_fields: {
        total_value_goods: false,
        description_of_goods: false
      },
      translation_overrides: false,
      offer_disclaimers: false,
      closed_after_map: false,
      feature_uploaders: false,
      email_on_registration: true,
      dedicated_pricings_only: false,
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
      blacklisted_emails: []
    }.freeze

    def initialize(target: nil, tenant: nil, sandbox: nil)
      adjusted_target = determine_target(target)
      tenant = adjusted_target&.tenant if tenant.nil?
      @hierarchy = HierarchyService.new(target: adjusted_target, tenant: tenant).fetch
      @sandbox = sandbox
    end

    def fetch(key = nil)
      final_scope = hierarchy.each_with_object(DEFAULT_SCOPE.dup) do |obj, result_scope|
        scope_hsh = Tenants::Scope.find_by(target: obj, sandbox: @sandbox)&.content&.deep_symbolize_keys!
        result_scope.deep_merge!(scope_hsh) if scope_hsh
      end

      result = key ? final_scope.fetch(key.to_sym, nil) : final_scope

      result.is_a?(Hash) ? result.with_indifferent_access : result
    end

    private

    def determine_target(target)
      return ::Tenants::User.find_by(legacy_id: target.id) if %w(Legacy::User User).include?(target.class.to_s)

      target
    end
    attr_reader :hierarchy
  end
end
