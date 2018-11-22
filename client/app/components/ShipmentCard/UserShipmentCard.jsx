import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import moment from 'moment'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './ShipmentCard.scss'
import adminStyles from '../Admin/Admin.scss'
import {
  gradientTextGenerator,
  switchIcon,
  numberSpacing,
  splitName
} from '../../helpers'

class UserShipmentCard extends Component {
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
    const plannedDate =
    shipment.has_pre_carriage ? shipment.planned_pickup_date : shipment.planned_origin_drop_off_date

    const destinationHubObj = splitName(shipment.destination_hub.name)
    const originHubObj = splitName(shipment.origin_hub.name)
    const timeRow = !!plannedDate && !!shipment.planned_etd && !!shipment.planned_eta
      ? (<div className={`layout-row flex-100 layout-align-start-center
    ${styles.middle_bottom_box} ${styles.smallText}`}
      >
        <div className="flex-20 layout-align-center-start">
          <span className="flex-100"><b>{t('common:pickupDate')}</b><br />
            <span className={`${styles.grey}`}>
              {moment(plannedDate).format('DD/MM/YYYY')}
            </span>
          </span>
        </div>
        <div className="flex-20 layout-align-center-start">
          <span className="flex-100"><b>{t('common:etd')}</b><br />
            <span className={`${styles.grey}`}>
              {moment(shipment.planned_etd).format('DD/MM/YYYY')}
            </span>
          </span>
        </div>
        <div className="flex-20 layout-align-center-start">
          <span className="flex-100"><b>{t('common:eta')}</b><br />
            <span className={`${styles.grey}`}>
              {moment(shipment.planned_eta).format('DD/MM/YYYY')}
            </span>
          </span>
        </div>
        <div className={`flex-40 layout-align-start-end ${styles.carriages}`}>
          <div className="layout-row layout-align-end-end">
            <i
              className={shipment.has_pre_carriage ? 'fa fa-check clip' : 'fa fa-times'}
              style={shipment.has_pre_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
            />
            <p>{t('shipment:preCarriageBase')}</p>
          </div>
          <div className="layout-row layout-align-end-end">
            <i
              className={shipment.has_on_carriage ? 'fa fa-check clip' : 'fa fa-times'}
              style={shipment.has_on_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
            />
            <p>{t('shipment:onCarriageBase')}</p>
          </div>
        </div>
      </div>) : (
        <div className={`layout-row flex-100 layout-align-start-center
      ${styles.middle_bottom_box} ${styles.smallText}`}
        >
          <div className="layout-row flex-100 layout-align-center-center">
            <i
              className={shipment.has_pre_carriage ? 'fa fa-check clip' : 'fa fa-times'}
              style={shipment.has_pre_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
            />
            <p>{t('shipment:preCarriageBase')}</p>
          </div>
          <div className="layout-row flex-100 layout-align-center-center">
            <i
              className={shipment.has_on_carriage ? 'fa fa-check clip' : 'fa fa-times'}
              style={shipment.has_on_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
            />
            <p>{t('shipment:onCarriageBase')}</p>
          </div>
        </div>
      )
    const cargoTypeString = shipment.load_type = 'container' ? t('cargo:container') : t('cargo:cargoItem')

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
              <p>{t('common:from')}:&nbsp;<span>{originHubObj.name}</span></p>
              <p>{t('common:to')}:&nbsp;<span>{destinationHubObj.name}</span></p>
            </div>
          </div>
          <div className={`layout-row flex-20 layout-align-start-center ${styles.ett}`}>
            {!!shipment.planned_etd && !!shipment.planned_eta ? (<div>
              <b>{moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')} {t('common:days')}</b><br />
              <span className={`${styles.grey}`}>
                {t('shipment:estimatedTransitTime')}
              </span>
            </div>) : '' }
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.middle_top_box}`}
        >
          <div className="layout-row flex-35 layout-align-center-center">
            <div className="flex-100">
              <b className={styles.ref_row_card}>{t('common:ref')}:&nbsp;{shipment.imc_reference}</b>
              <p>{t('shipment:placedAt')}&nbsp;{moment(shipment.booking_placed_at).format('DD/MM/YYYY | HH:mm')}</p>
            </div>
          </div>

          <hr />

          <div className="layout-row flex-60 layout-align-center-center">
            <div className=" flex-100">
              <div className="layout-row flex-50 layout-align-start-center">
                <div className="flex-10 layout-row layout-align-center-center">
                  <i className="fa fa-user clip" style={gradientFontStyle} />
                </div>
                <div className="flex-80 layout-row layout-align-start-start">
                  <h4>{shipment.clientName}</h4>
                </div>
              </div>
              <div className="layout-row flex-50 layout-align-start-center">
                <span className="flex-10 layout-row layout-align-center-center">
                  <i className="fa fa-building clip" style={gradientFontStyle} />
                </span>
                <span className={`flex-80 layout-row layout-align-start-center ${styles.grey}`}>
                  <p>{shipment.companyName}</p>
                </span>
              </div>
            </div>
          </div>

        </div>

        {shipment.status !== 'finished' ? timeRow : (
          <div className={`layout-row flex-40 layout-align-start-stretch
            ${styles.middle_bottom_box} ${styles.smallText}`}
          >
            <div className="flex-100 layout-row"><b>{t('shipment:arrivedOn')}:&nbsp;</b>
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_eta).format('DD/MM/YYYY')}
              </span>
            </div>
          </div>
        )}

        <div className={`layout-row flex-100 layout-align-space-between-center
            ${styles.bottom_box}`}
        >
          <div className="layout-row flex-65 layout-align-start-center">
            <div className="layout-row flex-10">
              <div className="layout-row layout-align-center-center">
                <span className={`${styles.smallText}`}>
                  <b>x</b><span className={`${styles.bigText}`}>{shipment.cargo_count}</span>
                </span>
              </div>
            </div>
            <span className="flex-35">{cargoTypeString}</span>
            <span className="flex-25 layout-row">
              <i
                className="fa fa-check-square clip"
                style={shipment.has_pre_carriage ? gradientFontStyle : deselectedStyle}
              />
              <p>{t('shipment:pickUp')}</p>
            </span>
            <span className="flex-25 layout row">
              <i
                className="fa fa-check-square clip"
                style={shipment.has_on_carriage ? gradientFontStyle : deselectedStyle}
              />
              <p>{t('shipment:delivery')}</p>
            </span>
          </div>
          <div className="layout-row flex layout-align-end-end">
            <span className={`${styles.bigText} ${styles.price_style}`}>
              <span>
                {shipment.edited_total
                  ? numberSpacing(shipment.edited_total.value, 2)
                  : numberSpacing(shipment.total_price.value, 2)}
              </span>
              <span>&nbsp;</span>
              <span> {shipment.total_price.currency} </span>
            </span>
          </div>
        </div>
      </div>
    )
  }
}

UserShipmentCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment),
  t: PropTypes.func.isRequired,
  dispatches: PropTypes.objectOf(PropTypes.func),
  theme: PropTypes.theme
}

UserShipmentCard.defaultProps = {
  shipment: {},
  dispatches: {},
  theme: {}
}

export default withNamespaces(['shipment', 'user', 'cargo'])(UserShipmentCard)
