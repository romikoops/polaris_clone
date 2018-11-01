import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './Messaging.scss'
import { moment } from '../../constants'
import { Price } from '../Price/Price'
import { Tooltip } from '../Tooltip/Tooltip'
import PropTypes from '../../prop-types'
import { switchIcon, totalPrice } from '../../helpers'

class MessageShipmentData extends Component {
  static switchIcon (sched) {
    let icon
    switch (sched.mode_of_transport) {
      case 'ocean':
        icon = <i className="fa fa-ship" />
        break
      case 'air':
        icon = <i className="fa fa-plane" />
        break
      case 'train':
        icon = <i className="fa fa-train" />
        break
      default:
        icon = <i className="fa fa-ship" />
        break
    }

    return icon
  }
  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  constructor (props) {
    super(props)
    this.onChangeFunc = this.onChangeFunc.bind(this)
  }
  onChangeFunc (optionsSelected) {
    const nameKey = this.props.name
    this.props.onChange(nameKey, optionsSelected)
  }

  render () {
    const {
      theme, shipmentData, closeInfo, t
    } = this.props
    if (!shipmentData) {
      return ''
    }
    const { shipment } = shipmentData
    const gradientFontStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary})`
          : 'black'
    }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? MessageShipmentData.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }

    return (
      <div
        className={`flex-90 layout-row layout-wrap layout-align-center-start 
        ${styles.data_overlay} `}
      >
        <div className={`flex-100 layout-row layout-wrap ${styles.data_box}`}>
          <div className={`flex-100 layout-row layout-align-center-center ${styles.top_row}`}>
            <div className={`flex-100 layout-row layout-align-start-center ${styles.hubs_row}`}>
              <div className={` flex-40 ${styles.header_hub}`}>
                <div className="flex-100 layout-row">
                  <div className="flex-15 layout-row layout-align-center-center">
                    <i
                      className={`fa fa-map-marker clip ${styles.map_marker}`}
                      style={gradientFontStyle}
                    />
                  </div>
                  <h4 className="flex-85"> {shipment.origin_hub.name} </h4>
                </div>
              </div>
              <div className={` flex ${styles.connection_graphics}`}>
                <div className="flex-none layout-row layout-align-center-center">
                  {switchIcon(shipment.mode_of_transport)}
                </div>
                <div style={dashedLineStyles} />
              </div>
              <div className={` flex-40 ${styles.header_hub}`}>
                <div className="flex-100 layout-row">
                  <div className="flex-15 layout-row layout-align-center-center">
                    <i className={`fa fa-flag-o clip ${styles.flag}`} style={gradientFontStyle} />
                  </div>
                  <h4 className="flex-85"> {shipment.destination_hub.name} </h4>
                </div>
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-center layout-wrap">
            <div className="flex-50 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {t('common:pickupDate')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-50 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {' '}
                  {t('common:dateOfDeparture')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_etd).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_etd).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-50 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {' '}
                  {t('shipment:etaTerminal')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-100 flex-gt-sm-50 layout-wrap
            layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {t('shipment:shipmentType')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className="flex-none"> {shipment.load_type === 'cargo_item' ? t('acronym:LCL') : t('acronym:FCL')} </p>
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
            <div
              className="
              flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {t('shipment:incoterm')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className="flex-none"> {shipment.incoterm} </p>
              </div>
            </div>
            <div className="
              flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {t('shipment:MoT')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className="flex-none"> {shipment.mode_of_transport} </p>
              </div>
            </div>
            <div
              className="
              flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {t('shipment:preCarriage')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className="flex-none"> {shipment.has_pre_carriage ? t('common:yes') : t('common:no')} </p>
              </div>
            </div>
            <div
              className="
              flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row layout-align-center">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {t('shipment:onCarriage')}
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <p className="flex-none"> {shipment.has_on_carriage ? t('common:yes') : t('common:no')} </p>
              </div>
            </div>
          </div>
          <div className={`flex-100 layout-row layout-align-center-center ${styles.load_type}`}>
            <div
              className={`${
                styles.tot_price
              } flex-none layout-row layout-align-space-between-center`}
              style={gradientFontStyle}
            >
              <p>{t('shipment:totalPrice')}</p>{' '}
              <Tooltip theme={theme} icon="fa-info-circle" color="white" text="total_price" />
              <Price value={totalPrice(shipment).value} currency={totalPrice(shipment).currency} />
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-center">
            <div
              className="flex-33 layout-row layout-align-space-around-center"
              onClick={closeInfo}
            >
              <i className="flex-none fa fa-angle-double-up" />
              <div className="flex-5" />
              <p className="flex-none">{t('common:hide')}</p>
              <div className="flex-5" />
              <i className="flex-none fa fa-angle-double-up" />
            </div>
          </div>
        </div>
      </div>
    )
  }
}

MessageShipmentData.propTypes = {
  name: PropTypes.string,
  t: PropTypes.func.isRequired,
  onChange: PropTypes.func,
  theme: PropTypes.theme,
  shipmentData: PropTypes.shipmentData.isRequired,
  closeInfo: PropTypes.func.isRequired,
  pickupDate: PropTypes.number.isRequired
}

MessageShipmentData.defaultProps = {
  theme: null,
  name: '',
  onChange: null
}

export default withNamespaces(['common', 'shipment', 'acronym'])(MessageShipmentData)
