import React, { Component } from 'react'
import styles from '../Card.scss'
import { v4 } from 'node-uuid'
import PropTypes from 'prop-types'
import { gradientTextGenerator } from '../../../../helpers'
import AdminPromptConfirm from '../../Prompt/Confirm'


class CardRoutesPricing extends Component {
  constructor (props) {
    super(props)
    this.state = {
      confirm: false
    }
    this.selectItinerary = this.selectItinerary.bind(this)
  }

  selectItinerary () {
    const { itinerary, handleClick } = this.props
    handleClick(itinerary)
  }

  switchIcon (itinerary) {
    const { theme } = this.props
    const iconStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    let icon
    switch (itinerary.mode_of_transport) {
      case 'ocean':
        icon = <i className={`fa fa-anchor`} />
        break
      case 'air':
        icon = <i className={`fa fa-paper-plane`} />
        break
      case 'train':
        icon = <i className={`fa fa-train`} />
        break
      default:
        icon = <i className={`fa fa-anchor`} />
        break
    }
    return icon
  }

  render () {
    const { handleClick, onClick, onDisabledClick, disabled, itinerary, modeOfTransport  } = this.props
    const disabledClass = disabled ? styles.disabled : ''

    return (
      <div
        className={`${styles.card_route_pricing} ${disabledClass}`}
        onClick={disabled ? onDisabledClick : () => handleClick(itinerary.id)}
      >
        <div className={styles.top_routes}>
          <div>
            <p>From: <strong><span> {itinerary.origin_nexus} </span></strong></p>
            <p>To: <strong><span> {itinerary.destination_nexus} </span></strong></p>
          </div>
          {this.switchIcon(itinerary)}
        </div>
        <div className={styles.bottom_routes}>
          <p><strong> 3 </strong> clients</p>
          <p><strong> 2 </strong> fees</p>
        </div>

      </div>
      )
  }
}

CardRoutesPricing.propTypes = {
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  handleClick: PropTypes.func.isRequired,
}

export default CardRoutesPricing
