# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_tenant, class: 'Legacy::Tenant' do # rubocop:disable Metrics/BlockLength
    subdomain { 'demo' }
    name { 'Demo' }
    addresses do
      {
        main: 'Brooktorkai 7, 20457 Hamburg, Germany',
        components: []
      }
    end
    phones do
      {
        main: '+46 31-85 32 00',
        support: '0173042031020'
      }
    end
    theme do
      {
        colors: {
          primary: '#0D5BA9',
          secondary: '#23802A',
          brightPrimary: '#2491FD',
          brightSecondary: '#25ED36'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        emailLogo: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      }
    end
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
        consolidation: {
          cargo: false,
          trucking: false
        },
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
          'Demo is to discuss the validity of the presented prices with the product owners.'
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
          general: 'sales.general@demo.com'
        },
        support: {
          general: 'support@demo.com'
        }
      }
    end

    trait :with_mot_emails do
      emails do
        {
          sales: {
            air: 'sales.air@demo.com',
            ocean: 'sales.ocean@demo.com',
            rail: 'sales.rail@demo.com',
            general: 'sales.general@demo.com'
          },
          support: {
            general: 'support@demo.com',
            air: 'support.air@demo.com',
            ocean: 'support.sea@demo.com',
            rail: 'support.rail@demo.com'
          }
        }
      end
    end

    transient do
      no_max_dimensions { false }
    end

    after(:create) do |tenant, evaluator|
      unless evaluator.no_max_dimensions || tenant.max_dimensions_bundles.present?
        tenant.max_dimensions_bundles << build(:legacy_max_dimensions_bundle, tenant: tenant)
        tenant.max_dimensions_bundles << build(:aggregated_max_dimensions_bundle, tenant: tenant)
      end
    end

  end
end

# == Schema Information
#
# Table name: tenants
#
#  id          :bigint           not null, primary key
#  addresses   :jsonb
#  currency    :string           default("EUR")
#  email_links :jsonb
#  emails      :jsonb
#  name        :string
#  phones      :jsonb
#  scope       :jsonb
#  subdomain   :string
#  theme       :jsonb
#  web         :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
