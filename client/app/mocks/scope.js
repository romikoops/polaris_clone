export const scope = {
  links: { about: '', legal: '' },
  terms: ['You verify that all the information provided above is true', 'You agree to the presented terms and conditions.', 'Demo is to discuss the validity of the presented prices with the product owners.'],
  fee_detail: 'key_and_name',
  closed_shop: false,
  has_customs: true,
  has_insurance: true,
  fixed_currency: false,
  dangerous_goods: false,
  cargo_info_level: 'hs_codes',
  carriage_options: { on_carriage: { export: 'optional', import: 'optional' }, pre_carriage: { export: 'optional', import: 'optional' } },
  detailed_billing: false,
  total_dimensions: true,
  consolidate_cargo: false,
  modes_of_transport: {
    air: { container: true, cargo_item: true }, rail: { container: true, cargo_item: true }, ocean: { container: true, cargo_item: true }, truck: { container: false, cargo_item: false }
  },
  show_beta_features: true,
  closed_registration: false,
  continuous_rounding: false,
  incoterm_info_level: 'text',
  non_stackable_goods: true,
  open_quotation_tool: false,
  customs_export_paper: false,
  fixed_exchange_rates: false,
  require_full_address: true,
  closed_quotation_tool: false,
  values: {
    weight: {
      unit: 'kg',
      decimals: 2
    }
  },
  user_restrictions: {
    profile: {
      name: false,
      email: false,
      phone: false,
      company: false,
      password: false
    }
  }
}
