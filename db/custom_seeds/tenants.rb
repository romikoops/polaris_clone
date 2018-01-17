# Define data for two tenants
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
      }
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
      background: "https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg"
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
      }
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
      logoSmall: "https://assets.itsmycargo.com/assets/logos/nordiclogosmall.png"
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
    subdomain: "nordicconsolidators1",
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
      }
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
      logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_easy_shipping.png"
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
      }
    }
  }
]

# Create tenants
tenant_data.each do |tenant_attr|
  Tenant.create(tenant_attr)
end
