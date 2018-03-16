import React, { Component } from 'react'
import PropTypes from '../../prop-types'

// import styles from './BookingSummary.scss'

export default class BookingSummary extends Component {
  shouldComponentUpdate (nextProps) {
    return !!(nextProps.shipmentData && nextProps.shipmentData.shipment)
  }
  render () {
    const { theme, shipmentData } = this.props
    console.log(theme)
    console.log(shipmentData)
    console.log(shipmentData.shipment)
    if (!shipmentData || !shipmentData.shipment) return ''
    return (
      <div className="flex-50 layout-row">
        { shipmentData.shipment.origin_hub_id }
        { shipmentData.shipment.destination_hub_id }
      </div>
    )
  }
}

BookingSummary.propTypes = {
  theme: PropTypes.theme,
  shipmentData: PropTypes.shipmentData
}

BookingSummary.defaultProps = {
  theme: null,
  shipmentData: null
}
