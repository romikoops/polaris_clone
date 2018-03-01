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
  #   cargo_info_level: 'text'
  # },
  # # The following data is not a attribute of the Tenant model
  # # only being used for seeding purposes
  # other_data: {
  #   trucking_availability: [
  #     # values
  #     #   an array (a list) of the values that match your upload_mode
  #     #   by default the upload_mode is :nexus_names (name of the city) 
  #     #
  #     # options
  #     #     if you would like to list hubs with trucking available rather than cities
  #     #   (example: 'Hamburg Airport'), you can set the option upload_mode to :hub_names
  #     #     if you would like to list cities or hubs with only trucking available only
  #     #   for a particular load type you can set the option load_type to
  #     #   :container or :cargo_item. By default you set both available
  #     #  
  #     # You can are able to set as many availability setting as you deem fit
  #     # Here is an example:
  #     #     
  #     {        
  #       values: ['Gothenburg', 'Shanghai']
  #     },
  #     {        
  #       values: ['Rotterdam Port'],
  #       options: {
  #         upload_mode: :hub_names,
  #         load_type: :container
  #       }
  #     },
  #     {        
  #       values: ['Mumbai'],
  #       options: {
  #         load_type: :cargo_item
  #       }
  #     }   
  #   ],
  #   # Cargo item types can be set in one of the 3 following ways:
  #   #   1. Choose a default option (Either :all, or :no_dimensions)
  #   #   2. An array (a list) of categories with no dimentions or area.
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
          primary: "#0EAF50",
          secondary: "#008ACB",
          brightPrimary: "#06CA52",
          brightSecondary: "#0CA7F7"
        },
        logoLarge: "https://assets.itsmycargo.com/assets/images/logos/logo_black.png",
        logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png",
        background: "https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg"
      },
      addresses: {
        main:"Torgny Segerstedtsgatan 80 426 77 Västra Frölunda"
      },
      phones:{
        main:"+46 31-85 32 00",
        support: "0173042031020"
      },
      emails: {
        sales: "sales@greencarrier.com",
        support: "support@greencarrier.com"
      },
      subdomain: "greencarrier",
      name: "Greencarrier",
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
        cargo_info_level: 'text'
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai']
          }   
        ],
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
          primary: "#0D5BA9",
          secondary: "#23802A",
          brightPrimary: "#2491FD",
          brightSecondary: "#25ED36"
        },
        logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
        logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
        background: "https://assets.itsmycargo.com/assets/backgrounds/bg_nordic_consolidators.jpg"
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
        support: "support@demo.com"
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
        cargo_info_level: 'hs_codes'
      },
      # The following data is not a attribute of the Tenant model
      # only being used for seeding purposes
      other_data: {
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
        ],
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
        support: "info@nordicconsolidators.com"
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
        cargo_info_level: 'hs_codes'
      },
      other_data: {
        cargo_item_types: :all,
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
        ]
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
        support: "support@easyshipping.dk"
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
        cargo_info_level: 'hs_codes'
      },
      other_data: {
        cargo_item_types: :all,
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
        ]
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
        support: "info@tantumshipping.com"
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
        cargo_info_level: 'hs_codes'
      },
      other_data: {
        cargo_item_types: :all,
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
        ]
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
        support: "info@isa.dk"
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
        cargo_info_level: 'hs_codes'
      },
      other_data: {
        cargo_item_types: :all,
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
        ]
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
        support: "service@eimskip.is"
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
        cargo_info_level: 'hs_codes'
      },
      other_data: {
        cargo_item_types: :all,
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
        ]
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
        support: "info@belglobe.com"
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
        cargo_info_level: 'hs_codes'
      },
      other_data: {
        cargo_item_types: :all,
        trucking_availability: [
          {        
            values: ['Gothenburg', 'Shanghai'],
            options: {
              load_type: :cargo_item
            }
          }   
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
      TruckingAvailability.update_hubs_trucking_availability!(tenant, other_data[:trucking_availability])  
    end

    Location.update_all_trucking_availabilities
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
end
