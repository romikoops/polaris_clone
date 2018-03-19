import React from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import PropTypes from '../../prop-types'

// import styles from './BookingSummary.scss'

function BookingSummary (props) {
  const {
    theme, scope, totalWeight, totalVolume, selectedDay, hubs
  } = props
  console.log(theme)
  console.log(scope)
  return (
    <div className="flex-50 layout-row">
      { totalWeight }
      { totalVolume }
      { selectedDay }
      { hubs.origin }
      { hubs.destination }
    </div>
  )
}

BookingSummary.propTypes = {
  theme: PropTypes.theme,
  scope: PropTypes.objectOf(PropTypes.any),
  totalWeight: PropTypes.number,
  totalVolume: PropTypes.number,
  selectedDay: PropTypes.string,
  hubs: PropTypes.shape({
    origin: PropTypes.string,
    destination: PropTypes.string
  })
}

BookingSummary.defaultProps = {
  theme: null,
  scope: null,
  totalWeight: 0,
  totalVolume: 0,
  selectedDay: null,
  hubs: {
    origin: '',
    destination: ''
  }
}

function mapStateToProps (state) {
  const {
    tenant, bookingSummary
  } = state
  const {
    theme, scope
  } = tenant.data
  return {
    ...bookingSummary,
    theme,
    scope
  }
}

export default withRouter(connect(mapStateToProps)(BookingSummary))
