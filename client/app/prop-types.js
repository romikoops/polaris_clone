import PropTypes from 'prop-types'

PropTypes.theme = PropTypes.shape({
  colors: PropTypes.shape({
    primary: PropTypes.string,
    secondary: PropTypes.string
  })
})

PropTypes.user = PropTypes.shape({
  guest: PropTypes.bool
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

export default PropTypes
