# frozen_string_literal: true

class TenantSeeder
  # Template for new Tenant Data

  # theme: {
  #   colors: {
  #     # Colors can be in RGB or HEX format

  #     primary: "#0EAF50",
  #     secondary: "#008ACB",
  #     brightPrimary: "#06CA52",
  #     brightSecondary: "#0CA7F7"
  #   },
  #   logoLarge: "https://assets.itsmycargo.com/assets/images/logos/logo_black.png",
  #   logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png",
  #   background: "https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg"
  # },
  # addresses: {
  # components: [],
  #   main:"Torgny Segerstedtsgatan 80 426 77 Västra Frölunda"
  # },
  # phones:{
  #   main:"+46 31-85 32 00",
  #   support: "0173042031020"
  # },
  # emails: {
  #   sales: "sales@greencarrier.com",
  #   support: "support@greencarrier.com"
  # },
  # subdomain: "greencarrier",
  # name: "Greencarrier",
  # scope: {
  #   modes_of_transport: {
  #     ocean: {
  #       container: true,
  #       cargo_item: true
  #     },
  #     rail: {
  #       container: true,
  #       cargo_item: true
  #     },
  #     air: {
  #       container: true,
  #       cargo_item: true
  #     }
  #   },
  #   dangerous_goods: false,
  # detailed_billing: false,
  # incoterm_info_level: 'text',
  #   cargo_info_level: 'text'
  # },
  # # The following data is not a attribute of the Tenant model
  # # only being used for seeding purposes
  # other_data: {
  #
  #   # Cargo item types can be set in one of the 3 following ways:
  #   #   1. Choose a default option (Either :all, or :no_dimensions)
  #   #   2. An array (a list) of categories with no dimensions or area.
  #   #   3. An array (a list) of hashes (key/value pair groups)
  #
  #
  #   # Method 1:
  #
  #   cargo_item_types: :all
  #
  #
  #   # Method 2:
  #
  #   cargo_item_types: [
  #     "Pallet",
  #     "Carton",
  #     "Crate",
  #     "Bottle",
  #     "Stack",
  #     "Drum",
  #     "Skid",
  #     "Barrel"
  #   ]
  #
  #
  #   # Method 3:
  #
  #   cargo_item_types: [
  #     {
  #       category: 'Pallet',
  #       dimension_x: 101.6,
  #       dimension_y: 121.9,
  #       area: 'North America'
  #     },
  #     {
  #       category: 'Pallet',
  #       dimension_x: 100.0,
  #       dimension_y: 120.0,
  #       area: 'Europe, Asia'
  #     }
  #   ]
  # }

  TENANT_DATA = [
    {
      theme: {
        colors: {
          primary: '#0db14b',
          secondary: '#008ACB',
          brightPrimary: '#06CA52',
          brightSecondary: '#0CA7F7'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/images/logos/logo_black.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/images/logos/logo_white.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      },
      addresses: {
        main: 'Torgny Segerstedtsgatan 80 426 77 Västra Frölunda',
        components: ['Torgny Segerstedtsgatan 80', 'P.O Box 1037', 'SE-405 22 Gothenburg', 'Visiting adress: Redegatan 1B']
      },
      phones: {
        main: '+46 31-85 32 00',
        support: '+46 8 470 4970'
      },
      emails: {
        sales: {
          air: 'imc.air.se@greencarrier.se',
          ocean: 'imc.sea.se@greencarrier.se',
          general: 'imc.sea.se@greencarrier.se'
        },
        support: {
          general: 'support@greencarrier.com',
          air: 'imc.air.se@greencarrier.se',
          ocean: 'imc.sea.se@greencarrier.se'
        }
      },
      email_links: {
        confirmation_instructions: [
          {
            href: 'https://freightservices.greencarrier.com/solution/tools/',
            link_text: 'Nordic Association of Freight Forwarders',
            text: 'All assignments will be performed in accordance with the General Conditions of the Nordic Association of Freight Forwarders (NSAB 2015)'
          },
          {
            href: 'https://freightservices.greencarrier.com/added-services/claims/',
            link_text: 'Claims Policy',
            text: "In the event you suffer a loss or damage to your goods, please refer to Greencarrier Freight Services' Claims Policy."
          },
          {
            href: 'https://greencarrier.itsmycargo.com/terms_and_conditions',
            link_text: 'Terms and Conditions',
            text: 'For more information, please refer to the Terms and Conditions.'
          }
        ]
      },
      subdomain: 'greencarrier',
      name: 'Greencarrier',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: true
          }
        },
        links: {
          about: 'https://freightservices.greencarrier.com/about-us/',
          legal: 'https://freightservices.greencarrier.com/contact/'
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: true,
        fixed_exchange_rates: true,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid.'
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
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          CFR
          DDP
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#0D5BA9',
          secondary: '#23802A',
          brightPrimary: '#2491FD',
          brightSecondary: '#25ED36'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      },
      addresses: {
        main: 'Brooktorkai 7, 20457 Hamburg, Germany',
        components: []
      },
      phones: {
        main: '+46 31-85 32 00',
        support: '0173042031020'
      },
      emails: {
        sales: {
          general: 'sales@demo.com',
          air: 'sales@demo.com',
          ocean: 'sales@demo.com',
          rail: 'sales@demo.com'
        },
        support: {
          general: 'support@demo.com',
          air: 'imc.air@demo.com',
          ocean: 'imc.sea@demo.com',
          rail: 'imc.rail@demo.com'
        }
      },
      email_links: {
        confirmation_instructions: [
          {
            href: 'www.example.com',
            link_text: 'Nordic Association of Freight Forwarders',
            text: 'All assignments will be performed in accordance with the General Conditions of the Nordic Association of Freight Forwarders (NSAB 2015)'
          },
          {
            href: 'www.example2.com',
            link_text: 'example2',
            text: 'This is just an example2.'
          }
        ]
      },
      subdomain: 'demo',
      name: 'Demo',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: true,
            cargo_item: true
          }
        },
        links: {
          about: '',
          legal: ''
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        show_beta_features: true,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: true,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Demo is to discuss the validity of the presented prices with the product owners.'
        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#1E5495',
          secondary: '#8FB4DC',
          brightPrimary: '#2588f9',
          brightSecondary: '#9FDAFC'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/nordiclogosmall.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/nordiclogosmall.png',
        background: 'https://assets.itsmycargo.com/assets/backgrounds/bg_nordic_consolidators.jpg'
      },
      addresses: {
        main: 'Bataljonsgatan 12,553 05 Jönköping, Sweden',
        components: []
      },
      phones: {
        main: '+46 36 291 40 04',
        support: '0173042031020'
      },
      emails: {
        sales: {
          general: 'sales@nordicconsolidators.com'
        },
        support: {
          general: 'info@nordicconsolidators.com'
        }
      },
      subdomain: 'nordicconsolidators',
      name: 'Nordic Consolidators',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: true,
            cargo_item: true
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        links: {
          about: '',
          legal: ''
        },
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '#FF9B0A',
          secondary: '#427FAF',
          brightPrimary: '#FFAC36',
          brightSecondary: '#539ED7'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/images/logos/logo_easy_shipping.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/images/logos/logo_easy_shipping.png',
        background: 'https://assets.itsmycargo.com/assets/backgrounds/bg_easy_shipping.jpg'
      },
      addresses: {
        components: [],
        main: 'Industrivej 2 DK-7860 Spøttrup Denmark'
      },
      phones: {
        main: '+45 5353 0300',
        support: '+45 5353 0300'
      },
      emails: {
        sales: {
          general: 'sales@easyshipping.dk'
        },
        support: {
          general: 'support@easyshipping.dk'
        }
      },
      web: {
        tld: 'dk'
      },
      subdomain: 'easyshipping',
      name: 'Easyshipping',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        links: {
          about: '',
          legal: ''
        },
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'disabled'
          },
          pre_carriage: {
            import: 'disabled',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '#4E9095',
          secondary: '#DDDDDD',
          brightPrimary: '#5bb8bf',
          brightSecondary: '#FFFFFF'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/integrail.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/integrail.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/integrail_wide.png'
      },
      addresses: {
        components: [],
        main: 'Révész utca 27. (575.11 mi)Budapest, Hungary 1138'
      },
      phones: {
        main: '+36 1 270 9330',
        support: '+36 1 270 9330'
      },
      emails: {
        sales: {
          general: 'sales@integrail.hu'
        },
        support: {
          general: 'info@tantumshipping.com'
        }
      },
      subdomain: 'integrail',
      name: 'Integrail',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: false,
            cargo_item: false
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        links: {
          about: '',
          legal: ''
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '#252D5C',
          secondary: '#C42D35',
          brightPrimary: '#4655aa',
          brightSecondary: '#fc353e'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/interscan-freight-logo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/interscan-freight-logo.png',
        background: 'https://assets.itsmycargo.com/assets/backgrounds/bg_isa.jpg'
      },
      addresses: {
        components: [],
        main: 'Kirstinehøj 8 / Copenhagen Airport, Post Office Box 134, DK-2770 Kastrup, Denmark'
      },
      phones: {
        main: '0045 32 51 60 22',
        support: '0045 32 51 60 22'
      },
      emails: {
        sales: {
          general: 'info@isa.dk'
        },
        support: {
          general: 'info@isa.dk'
        }
      },
      web: {
        tld: 'dk'
      },
      subdomain: 'isa',
      name: 'Inter-Scan Sea & Air',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: true
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        links: {
          about: '',
          legal: ''
        },
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '#006bc2',
          secondary: '#174b90',
          brightPrimary: '#006bc2',
          brightSecondary: '#174b90'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_eimskip_2.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_eimskip_2.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/logo_eimskip.png',
        background: 'https://assets.itsmycargo.com/assets/backgrounds/bg_nordic_consolidators.jpg'
      },
      addresses: {
        components: [],
        main: 'Korngardar 2, 104 Reykjavík, Iceland'
      },
      phones: {
        main: '+354 525 - 7000',
        support: '+354 525 - 7000'
      },
      emails: {
        sales: {
          general: 'service@eimskip.is'
        },
        support: {
          general: 'service@eimskip.is'
        }
      },
      subdomain: 'eimskip',
      name: 'Eimskip',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        links: {
          about: '',
          legal: ''
        },
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '#252D5C',
          secondary: '##C42D35',
          brightPrimary: '#4655aa',
          brightSecondary: '#fc353e'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/belglobe.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/belglobe.png'
      },
      addresses: {
        components: [],
        main: 'Route de la Plaine 45, CH-1580 Avenches, SWITZERLAND'
      },
      phones: {
        main: '+41 (0)26 409 76 80',
        support: '0173042031020'
      },
      emails: {
        sales: {
          general: 'info@belglobe.com'
        },
        support: {
          general: 'info@belglobe.com'
        }
      },
      subdomain: 'belglobe',
      name: 'Belglobe',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          air: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        links: {
          about: '',
          legal: ''
        },
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '##373838',
          secondary: '#CCCCCC',
          brightPrimary: '#E9E9E9',
          brightSecondary: '#54DC84'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/images/logos/gw.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/images/logos/gw.png'
      },
      addresses: {
        components: [],
        main: 'Krohnskamp 22, 22301 Hamburg, Deutschland'
      },
      phones: {
        main: '+ 49 172 543 0 576',
        support: '+ 49 172 543 0 576'
      },
      emails: {
        sales: {
          general: 'jan.glembocki@gw-freight.com'
        },
        support: {
          general: 'support@gw-freight.com'
        }
      },
      subdomain: 'gwforwarding',
      name: 'GW Forwarding',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          air: {
            container: false,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: false,
        terms: [],
        links: {
          about: '',
          legal: ''
        },
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: :all
      }
    },
    {
      theme: {
        colors: {
          primary: '#DB0025',
          secondary: '#008ACB',
          brightPrimary: '#e0708c',
          brightSecondary: '#4368b7'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/images/logos/hartrodt_logo_wide.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/images/logos/hartrodt_logo_white.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/images/logos/hartrodt_logo_small.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      },
      addresses: {
        components: [],
        main: 'Hoegerdamm 35, 20097 Hamburg'
      },
      phones: {
        main: '+49 40 23 90-0',
        support: '+49 172 4203 1020'
      },
      emails: {
        sales: {
          general: 'sales@hartrodt.com'
        },
        support: {
          general: 'ah_ham@hartrodt.com'
        }
      },
      subdomain: 'hartrodt',
      name: 'a.hartrodt',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'a.hartrodt is to discuss the validity of the presented prices with the product owners.'

        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#D5006A',
          secondary: '#1C2F5D',
          brightPrimary: '#D5009F',
          brightSecondary: '#4984B4'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/images/logos/saco_logo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/images/logos/saco_logo.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg',
        welcome_text: 'online freight calculator'
      },
      addresses: {
        components: [],
        main: 'Wollkämmereistraße 1, 21107 Hamburg'
      },
      phones: {
        main: '+49 40 311706-0',
        support: '+49 173 4203 1020'
      },
      emails: {
        sales: {
          general: 'sales@saco.de'
        },
        support: {
          general: 'support@saco.de'
        }
      },
      subdomain: 'saco',
      name: 'SACO Shipping GmbH',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: false
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        links: {
          about: '',
          legal: ''
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: true,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Saco Shipping is to discuss the validity of the presented prices with the product owners.'

        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#0053a0',
          secondary: '#00AACC',
          brightPrimary: '#1491FF',
          brightSecondary: '#77E6FC'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_logo.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_white.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_logo.png',
        background: 'https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_background.jpg'
      },
      addresses: {
        components: [],
        main: 'Wahlerstr. 20 40472 Düsseldorf'
      },
      phones: {
        main: '+49-(0)211 4188 30',
        support: '+49-(0)40 5005 810'
      },
      emails: {
        sales: {
          general: 'sales@mol-logistics.com'
        },
        support: {
          general: 'support@mol-logistics.com',
          air: 'air@mol-logistics.com',
          ocean: 'sea@mol-logistics.com'
        }
      },
      subdomain: 'mol-logistics',
      name: 'MOL Logistics',
      currency: 'EUR',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: true,
            cargo_item: true
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid.'

        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          CFR
          DDP
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#223b7a',
          secondary: '#fc0d1b',
          brightPrimary: '#238BDB',
          brightSecondary: '#FF4C55'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_logo.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_white.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_logo.png',
        background: 'https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_background.jpg'
      },
      addresses: {
        components: [],
        main: 'Martinistraße 58 28195 Bremen'
      },
      phones: {
        main: '+49 (0)421 1760-282',
        support: '+49 (0)421 1760-280'
      },
      emails: {
        sales: {
          general: 'sales@gs-logistics.com'
        },
        support: {
          general: 'support@gs-logistics.com',
          air: 'air@gs-logistics.com',
          ocean: 'sea@gs-logistics.com'
        }
      },
      subdomain: 'gs-logistics',
      name: 'Geuther & Schnitger Logistic',
      currency: 'EUR',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
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
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid.'

        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          CFR
          DDP
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#585878',
          secondary: '#d82e38',
          brightPrimary: '#8C93DD',
          brightSecondary: '#FD8187'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_logo.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_white.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_logo.png',
        background: 'https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_background.jpg'
      },
      addresses: {
        components: [],
        main: 'Nagelsweg 26 20097 Hamburg'
      },
      phones: {
        main: '+49 40 524 766 880',
        support: '+49 40 524 766 881'
      },
      emails: {
        sales: {
          general: 'sales@gtg-seefracht.com'
        },
        support: {
          general: 'support@gtg-seefracht.com'
        }
      },
      subdomain: 'gtg-seefracht',
      name: 'GTG Seefracht',
      currency: 'EUR',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
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
        links: {
          about: '',
          legal: ''
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid.'
        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          CFR
          DDP
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#FEF937',
          secondary: '#E14C43',
          brightPrimary: '#FFFFF',
          brightSecondary: '#f94c43'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/igs-itermodal/IGS-Logistics.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/igs-itermodal/IGS-Logistics.png',
        background: 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'
      },
      addresses: {
        components: [],
        main: 'Afrikastraße 3, 20457 Hamburg'
      },
      phones: {
        main: '+49 40 74 0020',
        support: '49 40 74 0020'
      },
      emails: {
        sales: {
          general: 'sales@igs-intermodal.de'
        },
        support: {
          general: 'sales@igs-intermodal.de'
        }
      },
      subdomain: 'igs-logistics',
      name: 'IGS Logistics Group GmbH',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: true,
            cargo_item: true
          },
          rail: {
            container: true,
            cargo_item: true
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'IGS Logistics is to discuss the validity of the presented prices with the product owners.'
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
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#4FAACA',
          secondary: '#270C77',
          brightPrimary: '#4FAACA',
          brightSecondary:  '#270C77'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/speedtrans/speedtranslogo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/speedtrans/speedtranslogo.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/speedtrans/speedtrans_logo_white.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      },
      addresses: {
        components: [],
        main: 'Am Spitzwald 9 D-21509 Glinde'
      },
      phones: {
        main: '+49 040 - 530 366 7 - 0',
        support: '49 040 - 530 366 7 - 0'
      },
      emails: {
        sales: {
          ocean: 'mkuester@speedtrans.com',
          general: 'mkuester@speedtrans.com'
        },
        support: {
          general: 'mkuester@speedtrans.com',
          ocean: 'mkuester@speedtrans.com'
        }
      },
      email_links: {
        confirmation_instructions: [
          {
            href: '',
            link_text: '',
            text: ''
          },
          {
            href: '',
            link_text: '',
            text: ''
          },
          {
            href: '',
            link_text: '',
            text: ''
          }
        ]
      },
      subdomain: 'speedtrans',
      name: 'Küster Speedtrans Übersee Spedition GmbH',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          truck: {
            container: false,
            cargo_item: false
          },
          ocean: {
            container: false,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        links: {
          about: 'http://www.speedtrans.com/ueberuns.php',
          legal: 'http://www.speedtrans.com/impressum.php'
        },
        continuous_rounding: true,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: false,
        consolidate_cargo: true,
        customs_export_paper: true,
        fixed_currency: true,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: true,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        links: {
          about: '',
          legal: ''
        },
        has_insurance: false,
        has_customs: false,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid.'
        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          CFR
          DDP
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#0D5BA9',
          secondary: '#23802A',
          brightPrimary: '#2491FD',
          brightSecondary: '#25ED36'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png',
        background: 'https://assets.itsmycargo.com/assets/logos/trucking/trucking_background.jpg'
      },
      addresses: {
        components: [],
        main: 'Brooktorkai 7, 20457 Hamburg, Germany'
      },
      phones: {
        main: '+46 31-85 32 00',
        support: '0173042031020'
      },
      emails: {
        sales: {
          general: 'sales@trucking.com',
          air: 'sales@trucking.com',
          ocean: 'sales@trucking.com',
          rail: 'sales@trucking.com'
        },
        support: {
          general: 'support@trucking.com',
          air: 'imc.air@trucking.com',
          ocean: 'imc.sea@trucking.com',
          rail: 'imc.rail@trucking.com'
        }
      },
      email_links: {
        confirmation_instructions: [
          {
            href: 'www.example.com',
            link_text: 'Nordic Association of Freight Forwarders',
            text: 'All assignments will be performed in accordance with the General Conditions of the Nordic Association of Freight Forwarders (NSAB 2015)'
          },
          {
            href: 'www.example2.com',
            link_text: 'example2',
            text: 'This is just an example2.'
          }
        ]
      },
      subdomain: 'trucking',
      name: 'Trucking',
      scope: {
        modes_of_transport: {
          truck: {
            container: true,
            cargo_item: true
          },
          ocean: {
            container: false,
            cargo_item: false
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: false,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Trucking is to discuss the validity of the presented prices with the product owners.'
        ],
        carriage_options: {
          on_carriage: {
            import: 'mandatory',
            export: 'mandatory'
          },
          pre_carriage: {
            import: 'mandatory',
            export: 'mandatory'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#687F93',
          secondary: '#F3f3f3',
          brightPrimary: '#C1C9D0',
          brightSecondary: '#7D8C9A'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/german-shipping/German_Shipping_logo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/german-shipping/German_Shipping_logo.png',
        background: 'https://assets.itsmycargo.com/assets/logos/truck_bg_1.jpg'
      },
      addresses: {
        components: [],
        main: 'Marlowring 19, 22525 Hamburg'
      },
      phones: {
        main: '+49 40 370 89 188',
        support: '+49 40 370 89 188'
      },
      emails: {
        sales: {
          general: 'info@german-shipping.com'
        },
        support: {
          general: 'info@german-shipping.com'
        }
      },
      subdomain: 'german-shipping',
      name: 'German Shipping GmbH & Co. KG',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          ocean: {
            container: false,
            cargo_item: false
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: false
          },
          truck: {
            container: true,
            cargo_item: true
          }
        },
        dangerous_goods: false,
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'German Shipping GmbH & Co. KG is to discuss the validity of the presented prices with the product owners.'
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
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#2458AB',
          secondary: '#5496f9',
          brightPrimary: '#3586BA',
          brightSecondary: '#1C98FC'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/austral/Austral_Logo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/austral/Austral_Logo.png',
        background: 'https://assets.itsmycargo.com/assets/logos/air_bg_1.jpg'
      },
      addresses: {
        components: [],
        main: 'Südportal 3, 6th floor, 22848 Norderstedt'
      },
      phones: {
        main: '+49 40 94362200',
        support: '+49 40 94362200'
      },
      emails: {
        sales: {
          general: 'service@austral-logistics.de'
        },
        support: {
          general: 'service@austral-logistics.de'
        }
      },
      subdomain: 'austral-logistics',
      name: 'Austral Logistics GmbH',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          ocean: {
            container: false,
            cargo_item: false
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: true
          }
        },
        dangerous_goods: false,
        detailed_billing: false,
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        links: {
          about: '',
          legal: ''
        },
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Austral Logistics GmbH is to discuss the validity of the presented prices with the product owners.'

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
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#e10f21',
          secondary: '#1d1d1b',
          brightPrimary: '#e10f21',
          brightSecondary: '#1d1d1b'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/tenants/gateway/gateway_logo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/tenants/gateway/gateway_logo.png',
        background: 'https://assets.itsmycargo.com/assets/logos/air_bg_1.jpg'
      },
      addresses: {
        components: [],
        main: 'Niendorfer Str. 170, 22848 Norderstedt, Germany'
      },
      phones: {
        main: '+49 (0)40 85 40 68-0',
        support: '+49 (0)40 85 40 68-0'
      },
      emails: {
        sales: {
          general: 'cglitscher@gatewaycargo.de'
        },
        support: {
          general: 'cglitscher@gatewaycargo.de'
        }
      },
      subdomain: 'gateway',
      name: 'Gateway Cargo Systems GmbH',
      currency: 'USD',
      scope: {
        modes_of_transport: {
          ocean: {
            container: false,
            cargo_item: true
          },
          rail: {
            container: false,
            cargo_item: false
          },
          air: {
            container: false,
            cargo_item: false
          }
        },
        dangerous_goods: true,
        links: {
          about: '',
          legal: ''
        },
        quote_notes: "1) Prices subject to change
        2) All fees are converted at the time of quotation
        using that day's European Central bank exchange rates and are an approximation
        of the final amount ot be paid. The amount paid at the time of settlement
        will reflect the exchange rates of the day.",
        detailed_billing: false,
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: true,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        default_direction: 'export',
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: false,
        has_customs: false,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Gateway Cargo Systems GmbH is to discuss the validity of the presented prices with the product owners.'

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
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          FCA
          FOB
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#192673',
          secondary: '#FFA514',
          brightPrimary: '#1A31B1',
          brightSecondary: '#FCB645'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/tenants/schryver/schryver_logo_dark.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/tenants/schryver/schryver_logo_dark.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/tenants/schryver/schryver_white.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      },
      addresses: {
        components: [],
        main: 'Sachsenstrasse 5, 20097, Hamburg, Germany '
      },
      phones: {
        main: '+49-40-2 36 33- 272',
        support: '+49-40-2 36 33- 272'
      },
      emails: {
        sales: {
          general: 'support@schryver.com'
        },
        support: {
          general: 'support@schryver.com'
        }
      },
      subdomain: 'schryver',
      name: 'Schryver International Freight Forwarders GmbH',
      currency: 'EUR',
      scope: {
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
            container: false,
            cargo_item: false
          }
        },
        links: {
          about: '',
          legal: ''
        },
        dangerous_goods: false,
        detailed_billing: true,
        continuous_rounding: false,
        closed_shop: true,
        closed_registration: true,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: false,
        has_customs: false,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Schryver International Freight Forwarders GmbH is to discuss the validity of the presented prices with the product owners.'

        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          FCA
          FOB
          FAS
        )
      }
    },
    {
      theme: {
        colors: {
          primary: '#30317C',
          secondary: '#7A8AC2',
          brightPrimary: '#30317C',
          brightSecondary: '#7A8AC2'
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/tenants/normanglobal/normanglobal_logo.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/tenants/normanglobal/normanglobal_logo.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/tenants/normanglobal/normanglobal_logo_white.png',
        background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
      },
      addresses: {
        components: [],
        main: 'Norman Global Logistics, Tower 1, 8/F, Unit 811, Cheung Sha Wan Plaza, 833 Cheung Sha Wan Rd, Kowloon, Hong Kong S.A.R'
      },
      phones: {
        main: '+852 3582 3440',
        support: '+852 3582 3440'
      },
      emails: {
        sales: {
          general: 'test_hongkong@normanglobal.com'
        },
        support: {
          general: 'test_hongkong@normanglobal.com'
        }
      },
      subdomain: 'normanglobal',
      name: 'Norman Global Logistics',
      currency: 'EUR',
      scope: {
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
            container: false,
            cargo_item: false
          }
        },
        links: {
          about: '',
          legal: ''
        },
        dangerous_goods: false,
        detailed_billing: false,
        continuous_rounding: false,
        closed_shop: false,
        closed_registration: false,
        closed_quotation_tool: false,
        open_quotation_tool: false,
        require_full_address: true,
        consolidate_cargo: false,
        customs_export_paper: false,
        fixed_currency: false,
        fixed_exchange_rates: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: false,
        has_customs: false,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Norman Global Logistics is to discuss the validity of the presented prices with the product owners.'

        ],
        carriage_options: {
          on_carriage: {
            import: 'optional',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'optional'
          }
        }
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        cargo_item_types: %w(
          Pallet
          Carton
          Crate
          Bottle
          Stack
          Drum
          Skid
          Barrel
        ),
        incoterms: %w(
          EXW
          FCA
          FOB
          FAS
        )
      }
    }
  ].freeze

  def self.sandbox_exec(tenant_attr, other_data)
    tenant_attr[:subdomain] = "#{tenant_attr[:subdomain]}-sandbox"
    tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])
    tenant_attr[:scope][:modes_of_transport] = {
      air: {
        cargo_item: true,
        container: true
      },
      ocean: {
        cargo_item: true,
        container: true
      },
      rail: {
        cargo_item: true,
        container: true
      }
    }
    tenant ? tenant.assign_attributes(tenant_attr) : tenant = Tenant.new(tenant_attr)
    tenant.save!

    update_cargo_item_types!(tenant, other_data[:cargo_item_types])
    update_tenant_incoterms!(tenant, other_data[:incoterms])
    update_max_dimensions!(tenant)
  end

  def self.perform(filter = {})
    puts 'Seeding Tenants...'
    TENANT_DATA.each do |tenant_attr|
      next unless should_perform?(tenant_attr, filter)

      puts "  - #{tenant_attr[:subdomain]}..."
      other_data = tenant_attr.delete(:other_data) || {}

      tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])
      tenant ? tenant.assign_attributes(tenant_attr) : tenant = Tenant.new(tenant_attr)
      tenant.save!

      update_cargo_item_types!(tenant, other_data[:cargo_item_types])
      update_tenant_incoterms!(tenant, other_data[:incoterms])
      update_max_dimensions!(tenant)
      TenantSeeder.sandbox_exec(tenant_attr, other_data)
    end
  end

  private

  def self.should_perform?(tenant_attr, filter)
    filter.all? do |filter_key, filter_value|\
      tenant_attr_value = tenant_attr[filter_key]

      tenant_attr_value == filter_value ||
        (filter_value.is_a?(Array) && filter_value.include?(tenant_attr_value))
    end
  end

  # Cargo Item Types

  CARGO_ITEM_TYPES = CargoItemType.all
  CARGO_ITEM_TYPES_NO_DIMENSIONS = CargoItemType.where(dimension_x: nil, dimension_y: nil)

  def self.update_cargo_item_types!(tenant, cargo_item_types_attr)
    return if cargo_item_types_attr.nil?

    if cargo_item_types_attr == :all
      CARGO_ITEM_TYPES.each do |cargo_item_type|
        TenantCargoItemType.find_or_create_by(tenant: tenant, cargo_item_type: cargo_item_type)
      end
      return
    end

    if cargo_item_types_attr == :no_dimensions
      CARGO_ITEM_TYPES_NO_DIMENSIONS.each do |cargo_item_type|
        TenantCargoItemType.find_or_create_by(tenant: tenant, cargo_item_type: cargo_item_type)
      end
      return
    end

    tenant.tenant_cargo_item_types.destroy_all
    cargo_item_types_attr.each do |cargo_item_type_attr|
      cargo_item_type =
        if cargo_item_type_attr.is_a? Hash
          CargoItemType.find_by(cargo_item_type_attr)
        else
          CargoItemType.find_by(
            category: cargo_item_type_attr,
            dimension_x: nil,
            dimension_y: nil,
            area: nil
          )
        end
      TenantCargoItemType.find_or_create_by(tenant: tenant, cargo_item_type: cargo_item_type)
    end
  end

  def self.update_tenant_incoterms!(tenant, incoterm_array)
    tenant.tenant_incoterms.destroy_all
    if incoterm_array
      incoterm_array.each do |code|
        incoterm = Incoterm.find_by_code(code)
        tenant.tenant_incoterms.find_or_create_by!(incoterm: incoterm)
      end
    else
      Incoterm.all.each do |incoterm|
        tenant.tenant_incoterms.find_or_create_by!(incoterm: incoterm)
      end
    end
  end

  def self.update_max_dimensions!(tenant)
    modes_of_transport = %i(general)
    modes_of_transport += %i(air ocean rail).select do |mot|
      tenant.mode_of_transport_in_scope? mot
    end
    MaxDimensionsBundle.create_defaults_for(
      tenant,
      modes_of_transport: modes_of_transport,
      all: true # Creates for aggregate and unit
    )
  end
end
