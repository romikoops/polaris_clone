super_tenant_data = {
    theme: {
      colors: {
        primary: "#0D5BA9",
        secondary: "#23802A",
        brightPrimary: "#2491FD",
        brightSecondary: "#25ED36"
      },
      logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
      logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
      logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png'
    },
    addresses: {
      main:"Brooktorkai 7, 20457 Hamburg, Germany"
    },
    phones:{
      main:"+46 31-85 32 00",
      support: "0173042031020"
    },
    emails: {
      sales: "sales@itsmycargo.com",
      support: "support@itsmycargo.com"
    },
    subdomain: "itsmycargo",
    name: "ItsMyCargo",
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
      detailed_billing: true,
      cargo_info_level: 'text',
      has_insurance: true,
      has_customs: false,
      incoterm_info_level: 'text'
    }
  }
super_tenant = Tenant.create!(super_tenant_data)
super_admin = super_tenant.users.new(
    role: Role.find_by_name('super_admin'),

    company_name: "ItsMyCargo",
    first_name: "Someone",
    last_name: "Staff",
    phone: "123456789",

    email: "info@itsmycargo.com",
    password: "stafflogin1",
    password_confirmation: "stafflogin1",

    confirmed_at: DateTime.new(2017, 1, 20)
  )
super_admin.save!