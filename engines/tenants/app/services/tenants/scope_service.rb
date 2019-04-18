# frozen_string_literal: true

module Tenants
  class ScopeService
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
          load_meterage_only: false
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
          container: true,
          cargo_item: true
        },
        rail: {
          container: true,
          cargo_item: true
        },
        ocean: {
          container: true,
          cargo_item: true
        }
      },
      closed_registration: false,
      continuous_rounding: false,
      incoterm_info_level: 'text',
      non_stackable_goods: true,
      open_quotation_tool: false,
      customs_export_paper: false,
      fixed_exchange_rates: true,
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
      mandatory_form_fields: false,
      translation_overrides: false,
      offer_disclaimers: false,
      closed_after_map: false,
      feature_uploaders: false,
      email_on_registration: true,
      dedicated_pricings_only: false
    }.freeze

    def initialize(user:)
      @hierarchy = HierarchyService.new(user: user).perform
    end

    def perform
      hierarchy_result_scope = hierarchy.each_with_object({}) do |obj, result_scope|
        result_scope.merge!(obj.scope)
      end

      DEFAULT_SCOPE.merge(hierarchy_result_scope)
    end

    private

    attr_reader :hierarchy
  end
end
