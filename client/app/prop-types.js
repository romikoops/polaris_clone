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
  clientName: PropTypes.string,
  planned_etd: PropTypes.number,
  imc_reference: PropTypes.string,
  schedule_set: PropTypes.array
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

PropTypes.address = PropTypes.shape({
  id: PropTypes.number,
  street_number: PropTypes.string,
  street: PropTypes.string,
  city: PropTypes.string,
  zip_code: PropTypes.string,
  country: PropTypes.country
})

PropTypes.hub = PropTypes.shape({
  location: PropTypes.location,
  name: PropTypes.string
})

PropTypes.client = PropTypes.shape({
  first_name: PropTypes.string,
  last_name: PropTypes.string,
  email: PropTypes.string,
  company_name: PropTypes.string,
  password: PropTypes.string
})

PropTypes.route = PropTypes.shape({
  id: PropTypes.number
})

PropTypes.vehicleType = PropTypes.shape({
  id: PropTypes.number,
  name: PropTypes.string,
  mode_of_transport: PropTypes.string
})

PropTypes.schedule = PropTypes.shape({
  hub_route_key: PropTypes.string,
  id: PropTypes.number,
  eta: PropTypes.number
})

PropTypes.charge = PropTypes.shape({
  id: PropTypes.number
})

PropTypes.locations = PropTypes.shape({
  origin: PropTypes.object,
  destination: PropTypes.object
})

PropTypes.gMaps = PropTypes.shape({
  Point: PropTypes.func,
  Size: PropTypes.func,
  Marker: PropTypes.func,
  LatLngBounds: PropTypes.func,
  MapTypeId: PropTypes.objectOf(PropTypes.string),
  Map: PropTypes.func,
  places: PropTypes.object,
  InfoWindow: PropTypes.func
})

export default PropTypes
