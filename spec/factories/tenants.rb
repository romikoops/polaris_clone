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
        fixed_currency: true,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
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
        }
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
  end
end
