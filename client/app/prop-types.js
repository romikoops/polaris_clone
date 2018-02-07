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

export default PropTypes
