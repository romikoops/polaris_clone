# frozen_string_literal: true

FactoryBot.define do
  factory :tenant do
    subdomain 'demo'
    scope do
      {
        modes_of_transport: {
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: true,
            cargo_item: true
          }
        },
        closed_shop: false,
        continuous_rounding: false,
        closed_registration: false,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: true,
        dangerous_goods: false,
        non_stackable_goods: true,
        detailed_billing: false,
        fee_detail: 'key_and_name',
        require_full_address: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        fixed_exchange_rates: true,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Greencarrier is to discuss the validity of the presented prices with the product owners.'
        ],
        carriage_options: {
          on_carriage: {
            import: 'mandatory',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'mandatory'
          }
        },
        open_quotation_tool: true,
        closed_quotation_tool: true,
        total_dimensions: true
      }
    end

    emails do
      {
        sales: {
          general: "sales.general@demo.com"
        },
        support: {
          general: "support@demo.com",
        }
      }
    end

    trait :with_mot_emails do
      emails do
        {
          sales: {
            air: "sales.air@demo.com",
            ocean: "sales.ocean@demo.com",
            rail: "sales.rail@demo.com",
            general: "sales.general@demo.com"
          },
          support: {
            general: "support@demo.com",
            air: "support.air@demo.com",
            ocean: "support.sea@demo.com",
            rail: "support.rail@demo.com"
          }
        }
      end
    end

    before(:create) do |tenant|
      if tenant.max_dimensions.empty?
        MaxDimensionsBundle.create_defaults_for(tenant, all: true)
      end
    end
  end
end
