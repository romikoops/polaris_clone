import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { v4 } from 'node-uuid'
import styles from './Admin.scss'
import { gradientTextGenerator, capitalize } from '../../helpers'

export default class AdminItineraryRow extends Component {
  constructor (props) {
    super(props)
    this.selectItinerary = this.selectItinerary.bind(this)
  }
  switchIcon (itinerary) {
    const { theme } = this.props
    const iconStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    let icon
    switch (itinerary.mode_of_transport) {
      case 'ocean':
        icon = <i style={iconStyle} className={`clip fa fa-ship ${styles.icon_buffer}`} />
        break
      case 'air':
        icon = <i style={iconStyle} className={`clip fa fa-plane ${styles.icon_buffer}`} />
        break
      case 'train':
        icon = <i style={iconStyle} className={`clip fa fa-train ${styles.icon_buffer}`} />
        break
      default:
        icon = <i style={iconStyle} className={`clip fa fa-ship ${styles.icon_buffer}`} />
        break
    }
    return icon
  }
  selectItinerary () {
    const { itinerary, handleClick } = this.props
    handleClick(itinerary)
  }

  render () {
    const { itinerary, theme } = this.props
    const iconStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    return (
      <div
        key={v4()}
        className={`flex-100 layout-row layout-align-space-between-center pointy ${styles.itinerary_row}`}
        onClick={this.selectItinerary}
      >
        <div className="flex-none layout-row layout-align-start-center">
          <i style={iconStyle} className={`clip fa fa-flag ${styles.icon_buffer}`} />
          <div className="flex-5" />
          <p className="flex-none">{itinerary.name}</p>
        </div>
        <div className="flex-none layout-row layout-align-end-center">
          <div className="flex-none layout-row layout-align-center-center">
            {this.switchIcon(itinerary)}
            <p className="flex-none">{itinerary.mode_of_transport ? capitalize(itinerary.mode_of_transport) : ''}</p>
          </div>
        </div>
      </div>
    )
  }
}
AdminItineraryRow.propTypes = {
  theme: PropTypes.theme.isRequired,
  handleClick: PropTypes.func.isRequired,
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminItineraryRow.defaultPropTypes = {
}
