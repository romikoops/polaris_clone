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
          primary: "#0db14b",
          secondary: "#008ACB",
          brightPrimary: "#06CA52",
          brightSecondary: "#0CA7F7"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/images/logos/logo_black.png",
        logoWhite: "https://assets.itsmycargo.com/assets/images/logos/logo_white.png",
        logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png",
        background: "https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg"
      },
      addresses: {
        main: 'Torgny Segerstedtsgatan 80 426 77 Västra Frölunda'
      },
      phones:{
        main:"+46 31-85 32 00",
        support: "0173042031020"
      },
      emails: {
        sales: "sales@greencarrier.com",
        support: {
          general: "support@greencarrier.com",
          air: "imc.air.se@greencarrier.se",
          ocean: "imc.sea.se@greencarrier.se"
        }
      },
      
      subdomain: "greencarrier",
      name: "Greencarrier",
      currency: 'USD',
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
            container: true,
            cargo_item: true
          }
        },
        links: {
          about: "https://freightservices.greencarrier.com/about-us/",
          legal: 'https://freightservices.greencarrier.com/contact/'
        },
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid."

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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ],
        incoterms: [
          "EXW",
          "CFR",
          "DDP",
          "FAS"
        ]
      }
    },
    {
      theme: {
        colors: {
          primary: "#0D5BA9",
          secondary: "#23802A",
          brightPrimary: "#2491FD",
          brightSecondary: "#25ED36"
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
        logoWhite: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png',
        background: "https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg"
      },
      addresses: {
        main:"Brooktorkai 7, 20457 Hamburg, Germany"
      },
      phones:{
        main:"+46 31-85 32 00",
        support: "0173042031020"
      },
      emails: {
        sales: "sales@demo.com",
        support: {
          general: "support@demo.com",
          air: "imc.air@demo.com",
          ocean: "imc.sea@demo.com"
        }
      },
      subdomain: "demo",
      name: "Demo",
      scope: {
        modes_of_transport: {
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
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'hs_codes',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "Demo is to discuss the validity of the presented prices with the product owners."
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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ]
      }
    },
    {
      theme: {
        colors: {
          primary: "#1E5495",
          secondary: "#8FB4DC",
          brightPrimary: "#2588f9",
          brightSecondary: "#9FDAFC"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/nordiclogosmall.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/nordiclogosmall.png",
        background: "https://assets.itsmycargo.com/assets/backgrounds/bg_nordic_consolidators.jpg"
      },
      addresses: {
        main: "Bataljonsgatan 12,553 05 Jönköping, Sweden"
      },
      phones:{
        main:"+46 36 291 40 04",
        support: "0173042031020"
      },
      emails: {
        sales: "sales@nordicconsolidators.com",
        support:{
          general: "info@nordicconsolidators.com"
        }
      },
      subdomain: "nordicconsolidators",
      name: "Nordic Consolidators",
      scope: {
        modes_of_transport: {
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
          primary: "#427FAF",
          secondary: "#FF9B0A",
          brightPrimary: "#539ED7",
          brightSecondary: "#FFAC36"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/images/logos/logo_easy_shipping.png",
        logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_easy_shipping.png",
        background: "https://assets.itsmycargo.com/assets/backgrounds/bg_easy_shipping.jpg"
      },
      addresses: {
        main:"Industrivej 2 DK-7860 Spøttrup Denmark"
      },
      phones:{
        main:"+45 5353 0300",
        support: "+45 5353 0300"
      },
      emails: {
        sales: "sales@easyshipping.dk",
        support: {
          general: "support@easyshipping.dk"
        }
      },
      web: {
        tld: "dk"
      },
      subdomain: "easyshipping",
      name: "Easyshipping",
      scope: {
        modes_of_transport: {
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
          primary: "#4E9095",
          secondary: "#DDDDDD",
          brightPrimary: "#5bb8bf",
          brightSecondary: "#FFFFFF"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/integrail.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/integrail.png",
        logoWide: "https://assets.itsmycargo.com/assets/logos/integrail_wide.png"
      },
      addresses: {
        main:"Révész utca 27. (575.11 mi)Budapest, Hungary 1138"
      },
      phones:{
        main: "+36 1 270 9330",
        support: "+36 1 270 9330"
      },
      emails: {
        sales: "sales@integrail.hu",
        support: {
          general: "info@tantumshipping.com"
        }
      },
      subdomain: "integrail",
      name: "Integrail",
      scope: {
        modes_of_transport: {
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
          primary: "#252D5C",
          secondary: "#C42D35",
          brightPrimary: "#4655aa",
          brightSecondary: "#fc353e"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/interscan-freight-logo.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/interscan-freight-logo.png",
        background: "https://assets.itsmycargo.com/assets/backgrounds/bg_isa.jpg"
      },
      addresses: {
        main: "Kirstinehøj 8 / Copenhagen Airport, Post Office Box 134, DK-2770 Kastrup, Denmark"
      },
      phones:{
        main:"0045 32 51 60 22",
        support: "0045 32 51 60 22"
      },
      emails: {
        sales: "info@isa.dk",
        support: {
          general: "info@isa.dk"
        }
      },
      web: {
        tld: "dk"
      },
      subdomain: "isa",
      name: "Inter-Scan Sea & Air",
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
            cargo_item: true
          }
        },
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
          primary: "#006bc2",
          secondary: "#174b90",
          brightPrimary: "#006bc2",
          brightSecondary: "#174b90"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/logo_eimskip_2.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/logo_eimskip_2.png",
        logoWide: "https://assets.itsmycargo.com/assets/logos/logo_eimskip.png",
        background: "https://assets.itsmycargo.com/assets/backgrounds/bg_nordic_consolidators.jpg"
      },
      addresses: {
        main: "Korngardar 2, 104 Reykjavík, Iceland"
      },
      phones:{
        main:"+354 525 - 7000",
        support: "+354 525 - 7000"
      },
      emails: {
        sales: "service@eimskip.is",
        support: {
          general: "service@eimskip.is"
        }
      },
      subdomain: "eimskip",
      name: "Eimskip",
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
          primary: "#252D5C",
          secondary: "##C42D35",
          brightPrimary: "#4655aa",
          brightSecondary: "#fc353e"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/belglobe.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/belglobe.png"
      },
      addresses: {
        main:"Route de la Plaine 45, CH-1580 Avenches, SWITZERLAND"
      },
      phones:{
        main:"+41 (0)26 409 76 80",
        support: "0173042031020"
      },
      emails: {
        sales: "info@belglobe.com",
        support: {
          general: "info@belglobe.com"
        }
      },
      subdomain: "belglobe",
      name: "Belglobe",
      scope: {
        modes_of_transport: {
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
        cargo_item_types: :all,
      }
    },
    {
      theme: {
        colors: {
          primary: "##373838",
          secondary: "#CCCCCC",
          brightPrimary: "#E9E9E9",
          brightSecondary: "#54DC84"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/images/logos/gw.png",
        logoSmall: "https://assets.itsmycargo.com/assets/images/logos/gw.png"
      },
      addresses: {
        main:"Krohnskamp 22, 22301 Hamburg, Deutschland"
      },
      phones:{
        main:"+ 49 172 543 0 576",
        support: "+ 49 172 543 0 576"
      },
      emails: {
        sales: "jan.glembocki@gw-freight.com",
        support: {
          general: "support@gw-freight.com"
        }
      },
      subdomain: "gwforwarding",
      name: "GW Forwarding",
      scope: {
        modes_of_transport: {
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
          primary: "#DB0025",
          secondary: "#008ACB",
          brightPrimary: "#e0708c",
          brightSecondary: "#4368b7"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/images/logos/hartrodt_logo_wide.png",
        logoWhite: "https://assets.itsmycargo.com/assets/images/logos/hartrodt_logo_white.png",
        logoSmall: "https://assets.itsmycargo.com/assets/images/logos/hartrodt_logo_small.png",
        background: "https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg"
      },
      addresses: {
        main:"Hoegerdamm 35, 20097 Hamburg"
      },
      phones:{
        main:"+49 40 23 90-0",
        support: "+49 172 4203 1020"
      },
      emails: {
        sales: "sales@hartrodt.com",
        support: {
          general: "ah_ham@hartrodt.com"
        }
      },
      subdomain: "hartrodt",
      name: "a.hartrodt",
      currency: 'USD',
      scope: {
        modes_of_transport: {
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
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "a.hartrodt is to discuss the validity of the presented prices with the product owners."

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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ]
      }
    },
    {
      theme: {
        colors: {
          primary: "#D5006A",
          secondary: "#1C2F5D",
          brightPrimary: "#D5009F",
          brightSecondary: "#4984B4"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/images/logos/saco_logo.png",
        logoSmall: "https://assets.itsmycargo.com/assets/images/logos/saco_logo.png",
        background: "https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg",
        welcome_text: "online freight calculator"
      },
      addresses: {
        main:"Wollkämmereistraße 1, 21107 Hamburg"
      },
      phones:{
        main:"+49 40 311706-0",
        support: "+49 173 4203 1020"
      },
      emails: {
        sales: "sales@saco.de",
        support: {
          general: "support@saco.de"
        }
      },
      subdomain: "saco",
      name: "SACO Shipping GmbH",
      currency: 'USD',
      scope: {
        modes_of_transport: {
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
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "Saco Shipping is to discuss the validity of the presented prices with the product owners."

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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ]
      }
    },
     {
      theme: {
        colors: {
          primary: "#0053a0",
          secondary: "#00AACC",
          brightPrimary: "#1491FF",
          brightSecondary: "#77E6FC"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_logo.png",
        logoWhite: "https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_white.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_logo.png",
        background: "https://assets.itsmycargo.com/assets/logos/mol-logistics/mol-logistics_background.jpg"
      },
      addresses: {
        main: "Wahlerstr. 20 40472 Düsseldorf"
      },
      phones:{
        main:"+49-(0)211 4188 30",
        support: "+49-(0)40 5005 810"
      },
      emails: {
        sales: "sales@mol-logistics.com",
        support: {
          general: "support@mol-logistics.com",
          air: "air@mol-logistics.com",
          ocean: "sea@mol-logistics.com"
        }
      },
      subdomain: "mol-logistics",
      name: "MOL Logistics",
      currency: 'EUR',
      scope: {
        modes_of_transport: {
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
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid."

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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ],
        incoterms: [
          "EXW",
          "CFR",
          "DDP",
          "FAS"
        ]
      }
    },
    {
      theme: {
        colors: {
          primary: "#223b7a",
          secondary: "#fc0d1b",
          brightPrimary: "#238BDB",
          brightSecondary: "#FF4C55"
        },
         logoLarge: "https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_logo.png",
        logoWhite: "https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_white.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_logo.png",
        background: "https://assets.itsmycargo.com/assets/logos/gs-logistics/gs-logistics_background.jpg"
      },
      addresses: {
        main: "Martinistraße 58 28195 Bremen"
      },
      phones:{
        main:"+49 (0)421 1760-282",
        support: "+49 (0)421 1760-280"
      },
      emails: {
        sales: "sales@gs-logistics.com",
        support: {
          general: "support@gs-logistics.com",
          air: "air@@gs-logistics.com",
          ocean: "sea@@gs-logistics.com"
        }
      },
      subdomain: "gs-logistics",
      name: "Geuther & Schnitger Logistic",
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
            container: true,
            cargo_item: true
          }
        },
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid."

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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ],
        incoterms: [
          "EXW",
          "CFR",
          "DDP",
          "FAS"
        ]
      }
    },
    {
      theme: {
        colors: {
          primary: "#585878",
          secondary: "#d82e38",
          brightPrimary: "#8C93DD",
          brightSecondary: "#FD8187"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_logo.png",
        logoWhite: "https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_white.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_logo.png",
        background: "https://assets.itsmycargo.com/assets/logos/gtg-seefracht/gtg-seefracht_background.jpg"
      },
      addresses: {
        main: "Nagelsweg 26 20097 Hamburg"
      },
      phones:{
        main:"+49 40 524 766 880",
        support: "+49 40 524 766 881"
      },
      emails: {
        sales: "sales@gtg-seefracht.com",
        support: {
          general: "support@gtg-seefracht.com",
          air: "",
          ocean: ""
        }
      },
      subdomain: "gtg-seefracht",
      name: "GTG Seefracht",
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
            container: true,
            cargo_item: true
          }
        },
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid."
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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ],
        incoterms: [
          "EXW",
          "CFR",
          "DDP",
          "FAS"
        ]
      }
    },
    {
      theme: {
        colors: {
          primary: "#FEF937",
          secondary: "#E14C43",
          brightPrimary: "#FFFFF",
          brightSecondary: "#f94c43"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/logos/igs-itermodal/IGS-Logistics.png",
        logoSmall: "https://assets.itsmycargo.com/assets/logos/igs-itermodal/IGS-Logistics.png",
        background: "https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg"
      },
      addresses: {
        main:"Afrikastraße 3, 20457 Hamburg"
      },
      phones:{
        main:"+49 40 74 0020",
        support: "49 40 74 0020"
      },
      emails: {
        sales: "sales@igs-intermodal.de",
        support: "support@igs-intermodal.de"
      },
      subdomain: "igs-logistics",
      name: "IGS Logistics Group GmbH",
      currency: 'USD',
      scope: {
        modes_of_transport: {
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
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          "You verify that all the information provided above is true",
          "You agree to the presented terms and conditions.",
          "IGS Logistics is to discuss the validity of the presented prices with the product owners."
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
        cargo_item_types: [
          "Pallet",
          "Carton",
          "Crate",
          "Bottle",
          "Stack",
          "Drum",
          "Skid",
          "Barrel"
        ]
      }
    }
]


  def self.exec(tenant_data = TENANT_DATA)
    tenant_data.each do |tenant_attr|
      other_data = tenant_attr.delete(:other_data) || {}

      tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])
      tenant ? tenant.assign_attributes(tenant_attr) : tenant = Tenant.new(tenant_attr)
      tenant.save!

      update_cargo_item_types!(tenant, other_data[:cargo_item_types])
      update_tenant_incoterms!(tenant, other_data[:incoterms])
    end
  end

  private

  # Cargo Item Types

  CARGO_ITEM_TYPES = CargoItemType.all
  CARGO_ITEM_TYPES_NO_DIMENSIONS = CargoItemType.where(dimension_x: nil, dimension_y: nil)

  def self.update_cargo_item_types!(tenant, cargo_item_types_attr)
    if cargo_item_types_attr.nil?
      puts "No cargo item types set for tenant #{tenant.subdomain}"
      return
    end

    if cargo_item_types_attr == :all
      CARGO_ITEM_TYPES.each do |cargo_item_type|
        TenantCargoItemType.create(tenant: tenant, cargo_item_type: cargo_item_type)
      end
      return
    end

    if cargo_item_types_attr == :no_dimensions
      CARGO_ITEM_TYPES_NO_DIMENSIONS.each do |cargo_item_type|
        TenantCargoItemType.create(tenant: tenant, cargo_item_type: cargo_item_type)
      end
      return
    end

    tenant.tenant_cargo_item_types.destroy_all
    cargo_item_types_attr.each do |cargo_item_type_attr|
      if cargo_item_type_attr.is_a? Hash
        cargo_item_type = CargoItemType.find_by(cargo_item_type_attr)
      else
        cargo_item_type = CargoItemType.find_by(
          category: cargo_item_type_attr,
          dimension_x: nil,
          dimension_y: nil,
          area: nil
        )
      end
      TenantCargoItemType.create(tenant: tenant, cargo_item_type: cargo_item_type)
    end
  end
  def self.update_tenant_incoterms!(tenant, incoterm_array)
    tenant.tenant_incoterms.destroy_all
    if incoterm_array
      incoterm_array.each do |code|
        incoterm = Incoterm.find_by_code(code)
        awesome_print code
        awesome_print incoterm
        tenant.tenant_incoterms.find_or_create_by!(incoterm: incoterm)
      end
    else
      Incoterm.all.each do |incoterm|
        tenant.tenant_incoterms.find_or_create_by!(incoterm: incoterm)
      end
    end
  end
end
