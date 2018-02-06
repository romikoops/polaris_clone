import PropTypes from 'prop-types'

PropTypes.theme = PropTypes.shape({
  colors: PropTypes.shape({
    primary: PropTypes.string,
    secondary: PropTypes.string
  })
})

export default PropTypes
