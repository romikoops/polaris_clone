import PropTypes from 'prop-types'

PropTypes.theme = PropTypes.shape({
  colors: PropTypes.shape({
    primary: PropTypes.string,
    secondary: PropTypes.string
  })
})

PropTypes.user = PropTypes.shape({
  guest: PropTypes.bool,
  company_name: PropTypes.string,
  first_name: PropTypes.string,
  last_name: PropTypes.string,
  email: PropTypes.string,
  phone: PropTypes.string
})

PropTypes.history = PropTypes.shape({
  push: PropTypes.func
})

PropTypes.tenant = PropTypes.shape({
  data: PropTypes.shape({
    id: PropTypes.number,
    theme: PropTypes.theme,
    subdomain: PropTypes.string
  })
})

PropTypes.req = PropTypes.shape({
  schedule: PropTypes.arrayOf(PropTypes.object),
  total: PropTypes.number,
  shipment: PropTypes.object
})

PropTypes.shipmentData = PropTypes.shape({
  contacts: PropTypes.array,
  shipment: PropTypes.object,
  documents: PropTypes.array,
  cargoItems: PropTypes.array,
  containers: PropTypes.array,
  schedules: PropTypes.array
})

PropTypes.match = PropTypes.shape({
  params: PropTypes.object
})

PropTypes.shipments = PropTypes.shape({
  open: PropTypes.array,
  requested: PropTypes.array,
  finished: PropTypes.array
})

PropTypes.shipment = PropTypes.shape({
  id: PropTypes.number,
  status: PropTypes.string,
  clientNmae: PropTypes.string,
  planned_etd: PropTypes.number,
  imc_reference: PropTypes.string
})

PropTypes.location = PropTypes.shape({
  primary: PropTypes.bool,
  id: PropTypes.number,
  street_number: PropTypes.string,
  street: PropTypes.string,
  city: PropTypes.string,
  zip_code: PropTypes.string,
  country: PropTypes.string
})

export default PropTypes
