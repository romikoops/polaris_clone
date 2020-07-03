import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import moment from 'moment'
import { get } from 'lodash'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './ShipmentCard.scss'
import adminStyles from '../Admin/Admin.scss'
import {
  gradientTextGenerator,
  switchIcon,
  humanizeSnakeCase
} from '../../helpers'

class ShipmentQuotationCard extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  handleView () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }

  render () {
    const {
      shipment,
      theme,
      t
    } = this.props

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const deselectedStyle = {
      ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
    }

    return (
      <div
        key={v4()}
        className={
          `flex-100 layout-align-start-stretch
          ${styles.container}`
        }
      >
        <div className={`layout-row flex-15 layout-align-center-center ${styles.topRight}`}>
          <p className={`${styles.check} pointy`}>{t('common:viewDetails')}</p>
        </div>
        <hr className={`flex-100 layout-row ${styles.hr_divider}`} />
        <div className={adminStyles.card_link} onClick={() => this.handleView()} />

        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.top_box}`}
        >
          <div className={`layout-row flex-10 layout-align-center-center ${styles.routeIcon}`}>
            {switchIcon(shipment.mode_of_transport, gradientFontStyle)}
          </div>
          <div className={`flex-60 layout-row layout-align-start-center ${styles.hub_name}`}>
            <div className="layout-column layout-align-center-start">
              <p>
                {t('common:from')}
                :&nbsp;
                <span>{get(shipment, 'origin_hub.name')}</span>
              </p>
              <p>
                {t('common:to')}
                :&nbsp;
                <span>{get(shipment, 'destination_hub.name')}</span>
              </p>
            </div>
          </div>
          <div className={`layout-row flex-20 layout-align-start-center ${styles.ett}`}>
            { shipment.planned_eta ? (
              <div>
                <b>
                  {moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')}
                  {' '}
                  {t('common:days')}
                </b>
                <br />
                <span className={`${styles.grey}`}>
                  {t('shipment:estimatedTransitTime')}
                </span>
              </div>
            ) : '' }
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.middle_top_box} ${styles.middle_top_box_quote}`}
        >
          <div className="layout-row flex-35 layout-align-center-center">
            <div className=" flex-100">
              <b className={styles.ref_row_card}>
                {t('common:ref')}
                :&nbsp;
                {shipment.imc_reference}
              </b>
              <p>
                {t('shipment:placedAt')}
&nbsp;
                {shipment.booking_placed_at
                  ? moment(shipment.booking_placed_at).format('DD/MM/YYYY | HH:mm') : '-'}
              </p>
            </div>
          </div>
          <span className="flex-25 layout-align-center-center layout-row">
            <i
              className="fa fa-check-square clip"
              style={shipment.has_pre_carriage ? gradientFontStyle : deselectedStyle}
            />
            <p>{t('shipment:preCarriage')}</p>
          </span>
          <span className="flex-25 layout-align-center-center layout-row">
            <i
              className="fa fa-check-square clip"
              style={shipment.has_on_carriage ? gradientFontStyle : deselectedStyle}
            />
            <p>{t('shipment:onCarriage')}</p>
          </span>
        </div>

        <div className={`layout-row flex-100 layout-align-space-between-center
            ${styles.bottom_box}`}
        >
          <div className="layout-row flex-65 layout-align-start-center">
            <div className="layout-row flex-10">
              <div className="layout-row layout-align-center-center">
                <span className={`${styles.smallText}`}>
                  <b>x</b>
                  <span className={`${styles.bigText}`}>{shipment.cargo_count}</span>
                </span>
              </div>
            </div>
            <span className="flex-35">{shipment.load_type ? humanizeSnakeCase(shipment.load_type) : t('cargo:cargoItem') }</span>
          </div>
        </div>
      </div>
    )
  }
}

ShipmentQuotationCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func),
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme
}

ShipmentQuotationCard.defaultProps = {
  shipment: {},
  dispatches: {},
  theme: {}
}

export default withNamespaces(['cargo', 'common'])(ShipmentQuotationCard)
