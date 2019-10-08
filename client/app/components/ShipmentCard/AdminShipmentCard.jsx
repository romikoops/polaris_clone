import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import moment from 'moment'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './ShipmentCard.scss'
import adminStyles from '../Admin/Admin.scss'
import AdminPromptConfirm from '../Admin/Prompt/Confirm'
import {
  gradientTextGenerator,
  switchIcon,
  splitName,
  totalPrice,
  formattedPriceValue,
  cargoPlurals
} from '../../helpers'

class AdminShipmentCard extends Component {
  constructor (props) {
    super(props)

    this.state = {
      confirm: false
    }
    this.selectShipment = this.selectShipment.bind(this)
  }

  handleDeny () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'decline')
  }

  handleAccept () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'accept')
  }

  handleIgnore () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'ignore')
    this.closeConfirm()
  }

  handleEdit () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }

  handleView () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }

  handleFinished () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'finished')
  }

  confirmDelete () {
    this.setState({
      confirm: true
    })
  }

  closeConfirm () {
    this.setState({ confirm: false })
  }

  selectShipment () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }

  render () {
    const {
      shipment,
      theme,
      confirmShipmentData,
      t
    } = this.props

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const deselectedStyle = {
      ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
    }

    const { confirm } = this.state
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={`${t('shipment:rejectWarningHead')} ${shipment.imc_reference}.
        ${t('shipment:rejectWarningTail')}`}
        confirm={() => this.handleIgnore()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )

    const plannedDate =
    shipment.has_pre_carriage ? shipment.planned_pickup_date : shipment.planned_origin_drop_off_date

    const requestedLinks = ['confirmed'].includes(shipment.status) ? (
      <div className={`layout-row layout-align-center-center ${styles.topRight}`}>
        <div className={`${styles.edit} layout-row layout-align-center-center pointy`} onClick={() => this.handleEdit()}>
          <i className="flex-none fa fa-eye" />
          &nbsp;
          <p>{t('common:modify')}</p>
        </div>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <div className={`${styles.check} layout-row layout-align-center-center pointy`} onClick={() => this.handleFinished()}>
          <i className="flex-none fa fa-check" />
          &nbsp;
          <p>{t('common:finish')}</p>
        </div>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <div className={`${styles.trash} layout-row layout-align-center-center pointy`} onClick={() => this.confirmDelete()}>
          <i className="flex-none fa fa-trash" />
          &nbsp;
          <p>{t('common:reject')}</p>
        </div>
      </div>
    ) : ''
    const openLinks = ['requested', 'requested_by_unconfirmed_account'].includes(shipment.status) ? (
      <div className={`layout-row layout-align-center-center ${styles.topRight}`}>
        <div className={`${styles.edit} layout-row layout-align-center-center pointy`} onClick={() => this.handleEdit()}>
          <i className="flex-none fa fa-eye" />
          &nbsp;
          <p>{t('common:modify')}</p>
        </div>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <div className={`${styles.check} layout-row layout-align-center-center pointy`} onClick={() => this.handleAccept()}>
          <i className="flex-none fa fa-check" />
          &nbsp;
          <p>{t('common:accept')}</p>
        </div>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <div className={`${styles.trash} layout-row layout-align-center-center pointy`} onClick={() => this.confirmDelete()}>
          <i className="flex-none fa fa-trash" />
          &nbsp;
          <p>{t('common:reject')}</p>
        </div>
      </div>
    ) : ''

    const destinationHubObj = splitName(shipment.destination_hub.name)
    const originHubObj = splitName(shipment.origin_hub.name)

    const timeRow = plannedDate && shipment.planned_etd && shipment.planned_eta
      ? (
        <div className={`layout-row flex-100 layout-align-start-center
    ${styles.middle_bottom_box} ${styles.smallText}`}
        >
          <div className="flex-20 layout-align-center-start">
            <span className="flex-100">
              <b>{t('common:pickupDate')}</b>
              <br />
              <span className={`${styles.grey}`}>
                {moment(plannedDate).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="flex-20 layout-align-center-start">
            <span className="flex-100">
              <b>{t('common:etd')}</b>
              <br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_etd).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="flex-20 layout-align-center-start">
            <span className="flex-100">
              <b>{t('common:eta')}</b>
              <br />
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
        </div>
      ) : (
        <div className={`layout-row flex-100 layout-align-start-center
      ${styles.middle_bottom_box} ${styles.smallText}`}
        >
          <div className="layout-row flex-50 layout-align-center-center">
            <i
              className={shipment.has_pre_carriage ? 'fa fa-check clip' : 'fa fa-times'}
              style={shipment.has_pre_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
            />
            <p>{t('shipment:preCarriageBase')}</p>
          </div>
          <div className="layout-row flex-50 layout-align-center-center">
            <i
              className={shipment.has_on_carriage ? 'fa fa-check clip' : 'fa fa-times'}
              style={shipment.has_on_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
            />
            <p>{t('shipment:onCarriageBase')}</p>
          </div>
        </div>
      )
    const cargoTypeString = cargoPlurals(shipment, t)

    return (
      <div
        key={v4()}
        className={
          `flex-100 layout-align-start-stretch
          ${styles.container}`
        }
      >
        <hr className={`flex-100 layout-row ${styles.hr_divider}`} />
        {confimPrompt}
        <div className={adminStyles.card_link} onClick={() => this.handleView()} />

        {requestedLinks}
        {openLinks}

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
                <span>{originHubObj.name}</span>
              </p>
              <p>
                {t('common:to')}
:&nbsp;
                <span>{destinationHubObj.name}</span>
              </p>
            </div>
          </div>
          <div className={`layout-row flex-20 layout-align-start-end ${styles.ett}`}>
            <div>
              <b>
                {moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')}
                {' '}
                {t('common:days')}
              </b>
              <br />
              <span className={`${styles.grey}`} style={{ fontSize: '10px' }}>
                {t('shipment:estimatedTransitTime')}
              </span>
            </div>
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.middle_top_box}`}
        >
          <div className="layout-row flex-50 flex-sm-40 flex-md-40 flex-xl-40 layout-align-center-center">
            <div className="flex-100">
              <b className={styles.ref_row_card}>
                {t('common:ref')}
:&nbsp;
                {shipment.imc_reference}
              </b>
              <p>
                {t('shipment:placedAt')}
&nbsp;
                {moment(shipment.booking_placed_at).format('DD/MM/YYYY | HH:mm')}
              </p>
            </div>
          </div>

          <hr />

          <div className="layout-row flex-50 flex-sm-60 flex-md-60 flex-xl-60 layout-align-center-center">
            <div className="flex-100">
              <div className="layout-row flex-100 layout-align-start-center">
                <div className="flex-10 layout-row layout-align-center-center">
                  <i className="fa fa-user clip" style={gradientFontStyle} />
                </div>
                <div className="flex-80 layout-row layout-align-start-start">
                  <h4>{shipment.client_name}</h4>
                </div>
              </div>
              <div className="layout-row flex-100 layout-align-start-center">
                <span className="flex-10 layout-row layout-align-center-center">
                  <i className="fa fa-building clip" style={gradientFontStyle} />
                </span>
                <span className={`flex-80 layout-row layout-align-start-center ${styles.grey}`}>
                  <p>{shipment.company_name}</p>
                </span>
              </div>
            </div>
          </div>

        </div>

        {shipment.status !== 'finished' ? timeRow : (
          <div className={`layout-row flex-40 layout-align-start-stretch
            ${styles.middle_bottom_box} ${styles.smallText}`}
          >
            <div className="flex-100 layout-row">
              <b>
                {t('shipment:arrivedOn')}
:&nbsp;
              </b>
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
                  <b>x</b>
                  <span className={`${styles.bigText}`}>{shipment.cargo_count}</span>
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
                { formattedPriceValue(totalPrice(shipment).value) }
              </span>
              <span>
                {' '}
                { totalPrice(shipment).currency }
                {' '}
              </span>
            </span>
          </div>
        </div>
      </div>
    )
  }
}

AdminShipmentCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment),
  t: PropTypes.func.isRequired,
  confirmShipmentData: PropTypes.objectOf(PropTypes.any),
  dispatches: PropTypes.objectOf(PropTypes.func).isRequired,
  theme: PropTypes.theme
}

AdminShipmentCard.defaultProps = {
  shipment: {},
  confirmShipmentData: {},
  theme: {}
}

export default withNamespaces(['common', 'shipment', 'cargo'])(AdminShipmentCard)
