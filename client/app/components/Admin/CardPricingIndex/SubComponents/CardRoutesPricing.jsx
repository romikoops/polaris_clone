import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from '../Card.scss'
import { gradientTextGenerator, switchIcon } from '../../../../helpers'

class CardRoutesPricing extends Component {
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
      handleClick, onDisabledClick, disabled, itinerary, theme, t
    } = this.props
    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
    const disabledClass = disabled ? styles.disabled : ''
    const [originNexus, destinationNexus] = itinerary.name.split(' - ')

    return (
      <div
        className="card_padding flex-100 flex-md-50 flex-gt-md-33"
        onClick={disabled ? onDisabledClick : () => handleClick(itinerary.id)}
      >
        <div
          className={`${styles.card_route_pricing} ${disabledClass} margin_bottom flex`}

        >
          <div className={styles.top_routes}>
            <div>
              <p>
                {t('common:from')}:{' '}
                <strong>
                  <span> {originNexus} </span>
                </strong>
              </p>
              <p>
                {t('common:to')}:{' '}
                <strong>
                  <span> {destinationNexus} </span>
                </strong>
              </p>
            </div>
            {switchIcon(itinerary.mode_of_transport, gradientFontStyle)}
          </div>
          <div className={styles.bottom_routes}>
            {itinerary.users_with_pricing ? <p>
              <strong> {itinerary.users_with_pricing} </strong> {t('admin:clients')}
            </p> : '' }
            { itinerary.pricing_count ? <p>
              <strong> {itinerary.pricing_count} </strong> {t('admin:pricingsSC')}
            </p> : '' }
          </div>
        </div>
      </div>
    )
  }
}

CardRoutesPricing.propTypes = {
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  handleClick: PropTypes.func.isRequired,
  onDisabledClick: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme
}
CardRoutesPricing.defaultProps = {
  disabled: false,
  theme: {}
}

export default withNamespaces(['admin', 'common'])(CardRoutesPricing)
