# Template for new Tenant Data
# 
# theme: {
#   colors: {
#     # Colors can be in RGB or HEX format
# 
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
#       values: ['Gothenburg, Shanghai'],
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
#   ]
# }


tenant_data = [
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
          values: [''],
          options: {
            upload_mode: :nexus_names,
            only_container: true
          }
        }
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
    }
  }
]


# Cargo Item Types

CARGO_ITEM_TYPES = CargoItemType.all
CARGO_ITEM_TYPES_NO_DIMENSIONS = CargoItemType.where(dimension_x: nil, dimension_y: nil)

def update_cargo_item_types!(tenant)
  if %w(demo greencarrier).include? tenant.subdomain 
    tenant.cargo_item_types << CARGO_ITEM_TYPES_NO_DIMENSIONS
  else
    tenant.cargo_item_types << CARGO_ITEM_TYPES
  end
end


# Trucking Availability

def find_trucking_availability(setting)
  load_types = [:container, :cargo_item]
  if (load_type = load_types.delete(setting.dig(:options, :load_type))).nil?        
    trucking_availability_attr = {
      container: true,
      cargo_item: true
    }
  else
    trucking_availability_attr = {
      load_type        => false,
      load_types.first => true
    }
  end

  trucking_availability = TruckingAvailability.find_by(trucking_availability_attr)
end

def hubs_to_update
  if setting.dig(:options, :hub_names)
    tenant.hubs.where(name: setting[:values])
  else
    nexus_ids = setting[:values].map do |value|
      Location.find_by(location_type: "nexus", name: value).id
    end
    
    tenant.hubs.where(nexus_id: nexus_ids)
  end
end

def update_hubs_trucking_availability!(tenant, trucking_availability_settings)
  if trucking_availability_settings.nil?
    puts "no trucking availability for tenant #{tenant.subdomain}"
    return
  end

  trucking_availability_settings.each do |setting|
    trucking_availability = find_trucking_availability(setting)

    hubs_to_update(setting).each do |hub|
      hub.trucking_availability = trucking_availability
      hub.save!
    end
  end
end


# Create or update tenants 

tenant_data.each do |tenant_attr|
  tenant = Tenant.find_by(subdomain: tenant_attr[:subdomain])  
  tenant = tenant ? tenant.update!(tenant_attr) : Tenant.create!(tenant_attr)
  update_cargo_item_types!(tenant)
  update_hubs_trucking_availability!(tenant, tenant_attr[:other_data][:trucking_availability])
end

Location.update_all_trucking_availabilities
