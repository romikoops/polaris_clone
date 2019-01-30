import { theme } from './theme'

const modes_of_transport = {
  air: {
    AIR_LOAD_TYPE: 0
  },
  ocean: {
    OCEAN_LOAD_TYPE: 2
  },
  rail: {
    RAIL_LOAD_TYPE: 0
  },
  truck: {
    TRUCK_LOAD_TYPE: 0
  }
}

const mandatory_form_fields = {
  total_goods_value: 3370,
  description_of_goods: 'MANDATORY_FIELDS_DESCRIPTION'
}
const carriage_options = {
  on_carriage: {
    import: 'mandatory',
    export: 'mandatory'
  },
  pre_carriage: {
    import: 'optional',
    export: 'optional'
  }
}

const scope = {
  carriage_options,
  cargo_info_level: 'text',
  closed_quotation_tool: true,
  customs_export_paper: false,
  detailed_billing: true,
  has_customs: true,
  has_insurance: true,
  hide_grand_total: true,
  mandatory_form_fields,
  modes_of_transport,
  terms: ['FOO_TERM', 'BAR_TERM']
}

export const emails = {
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
}

const phones = {
  support: 'TENANT_SUPPORT_PHONE'
}

export const tenant = {
  emails,
  id: 123,
  name: 'TENANT_NAME',
  phones,
  scope,
  subdomain: 'TENANT_SUBDOMAIN',
  theme
}
