import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { switchIcon, gradientTextGenerator } from '../../../helpers'

class ItineraryRow extends PureComponent {
  viewSchedules () {
    const { adminDispatch, itinerary } = this.props
    adminDispatch.loadItinerarySchedules(itinerary.id, true)
  }
  viewPricings () {
    const { adminDispatch, itinerary } = this.props
    adminDispatch.getItineraryPricings(itinerary.id, true)
  }

  render () {
    const {
      t,
      theme,
      itinerary
    } = this.props

    const [startCity, endCity] = itinerary.name.split(' - ')
    const gradientIcon = {
      ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    }

    return (
      <div className={`flex-100 layout-row layout-align-start-start ${styles.itinerary_row}`} key={v4()} >
        <div className={`flex-15 layout-row layout-align-center-center height_100 ${styles.mot_icon}`}>
          {switchIcon(itinerary.mode_of_transport, gradientIcon, 'flex-none')}
        </div>

        <div className={`flex-45 layout-row layout-align-space-around-center ${styles.itinerary_row_box}`}>
          <div className={`flex-none ${styles.divider}`} />
          <div className={`flex layout-row layout-wrap layout-align-center-center ${styles.itinerary_row_city}`}>
            <p className={`flex-100 ${styles.city_name}`}>{startCity}</p>
            <p className={`flex-100 ${styles.city_context}`}>{t('admin:departure')}</p>
          </div>
          <div className={`flex-15 layout-row layout-align-center-center ${styles.chevron_icon}`}>
            <i
              className="flex-none fa fa-angle-double-right clip"
              style={gradientIcon}
            />
          </div>
          <div className={`flex layout-row layout-wrap layout-align-center-center ${styles.itinerary_row_city}`}>
            <p className={`flex-100 ${styles.city_name}`}>{endCity}</p>
            <p className={`flex-100 ${styles.city_context}`}>{t('admin:arrival')}</p>
          </div>
        </div>
        <div className={`flex layout-row layout-align-center-center pointy ${styles.itinerary_row_box} ${styles.itinerary_row_btn}`} onClick={() => this.viewSchedules()} >
          <div className={`flex-none ${styles.divider}`} />
          <p className="flex-none">{t('admin:viewSchedules')}</p>
        </div>

        <div className={`flex layout-row layout-align-center-center pointy ${styles.itinerary_row_box} ${styles.itinerary_row_btn}`} onClick={() => this.viewPricings()}>
          <div className={`flex-none ${styles.divider}`} />
          <p className="flex-none">{t('admin:viewPricings')}</p>
        </div>
      </div>
    )
  }
}

ItineraryRow.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired
}
ItineraryRow.defaultProps = {
  theme: {}
}
export default withNamespaces('admin')(ItineraryRow)
