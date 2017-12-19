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
      logoSmall: "https://assets.itsmycargo.com/assets/images/logos/logo_black_small.png"
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
    name: "Greencarrier"
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
      logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png'
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
    name: "Demo"
  }
]

# Create tenants
tenant_data.each do |tenant_attr|
  Tenant.create(tenant_attr)
end
