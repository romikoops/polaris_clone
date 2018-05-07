import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from '../Card.scss'

class CardRoutesPricing extends Component {
  static switchIcon (itinerary) {
    let icon
    switch (itinerary.mode_of_transport) {
      case 'ocean':
        icon = <i className="fa fa-anchor" />
        break
      case 'air':
        icon = <i className="fa fa-paper-plane" />
        break
      case 'rail':
        icon = <i className="fa fa-train" />
        break
      default:
        icon = <i className="fa fa-anchor" />
        break
    }
    return icon
  }
  constructor (props) {
    super(props)
    this.state = {}
    this.selectItinerary = this.selectItinerary.bind(this)
  }

  selectItinerary () {
    const { itinerary, handleClick } = this.props
    handleClick(itinerary)
  }

  render () {
    const {
      handleClick, onDisabledClick, disabled, itinerary
    } = this.props
    const disabledClass = disabled ? styles.disabled : ''
    const [originNexus, destinationNexus] = itinerary.name.split(' - ')
    return (
      <div
        className={`${styles.card_route_pricing} ${disabledClass} flex-100`}
        onClick={disabled ? onDisabledClick : () => handleClick(itinerary.id)}
      >
        <div className={styles.top_routes}>
          <div>
            <p>
              From:{' '}
              <strong>
                <span> {originNexus} </span>
              </strong>
            </p>
            <p>
              To:{' '}
              <strong>
                <span> {destinationNexus} </span>
              </strong>
            </p>
          </div>
          {CardRoutesPricing.switchIcon(itinerary)}
        </div>
        <div className={styles.bottom_routes}>
          <p>
            <strong> {itinerary.users_with_pricing} </strong> clients
          </p>
          <p>
            <strong> {itinerary.pricing_count} </strong> pricings
          </p>
        </div>
      </div>
    )
  }
}

CardRoutesPricing.propTypes = {
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  handleClick: PropTypes.func.isRequired,
  onDisabledClick: PropTypes.func.isRequired,
  disabled: PropTypes.bool
}
CardRoutesPricing.defaultProps = {
  disabled: false
}

export default CardRoutesPricing
