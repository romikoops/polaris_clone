import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import '../../styles/day-picker-custom.scss'
import { moment, LOAD_TYPES } from '../../constants'
import { switchIcon, capitalize } from '../../helpers'
import styles from './RouteFilterBox.scss'
import TextHeading from '../TextHeading/TextHeading'
import Checkbox from '../Checkbox/Checkbox'
import ExchangeRatesHolder from '../ExchangeRatesHolder/ExchangeRatesHolder'

class RouteFilterBox extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedDay: props.departureDate
        ? moment(props.departureDate).format('DD/MM/YYYY')
        : moment().format('DD/MM/YYYY'),
      selectedOption: {
        air: true,
        ocean: true,
        truck: true,
        rail: true
      }
    }
    this.editFilterDay = this.editFilterDay.bind(this)
    this.handleOptionChange = this.handleOptionChange.bind(this)
    this.setFilterDuration = this.setFilterDuration.bind(this)
  }

  setFilterDuration (event) {
    const dur = event.target.value
    this.props.setDurationFilter(dur)
  }

  editFilterDay (day) {
    this.props.setDepartureDate(day)
  }

  handleOptionChange (changeEvent, target) {
    this.setState({
      selectedOption: {
        ...this.state.selectedOption,
        [target]: changeEvent
      }
    })
    this.props.setMoT(changeEvent, target)
  }

  render () {
    const {
      theme, pickup, shipment, availableMotKeys, cargos, lastAvailableDate, t, exchangeRates
    } = this.props
    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment().format()),
        after: new Date(moment(lastAvailableDate))
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }

    const motCheckBoxKeys = Object.keys(availableMotKeys)
    const motCheckBoxes = motCheckBoxKeys.length > 1 ? motCheckBoxKeys.map((mKey) => (
      <div className="radio layout-row layout-align-none-center" style={{ margin: '2px 0' }}>
        <Checkbox
          id={mKey}
          onChange={e => this.handleOptionChange(e, mKey)}
          checked={this.state.selectedOption[mKey]}
          theme={theme}
          disabled={motCheckBoxKeys.length === 1}
        />
        <label className="flex-none pointy" htmlFor={mKey}>
          {switchIcon(mKey)}
          {capitalize(mKey)}
        </label>
      </div>
    )) : []
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }
    const imgFCL = { backgroundImage: `url(${LOAD_TYPES[1].img})` }

    return (
      <div className={styles.filterbox}>
        <div className={styles.pickup_date}>
          <div className="flex-100 layout-row">
            <TextHeading theme={theme} size={4} text={pickup ? t('cargo:cargoReadyDate') : t('cargo:availableAtTerm')} />
          </div>
          <div className={`flex-none layout-row ${styles.dpb}`}>
            <div className={`flex-none layout-row layout-align-center-center ${styles.dpb_icon}`}>
              <i className="flex-none fa fa-calendar" />
            </div>
            <DayPickerInput
              placeholder="DD/MM/YYYY"
              formatDate={formatDate}
              parseDate={parseDate}
              format="DD/MM/YYYY"
              className={styles.dpb_picker}
              value={this.state.selectedDay}
              onDayChange={this.editFilterDay}
              dayPickerProps={dayPickerProps}
            />
          </div>
        </div>
        {motCheckBoxKeys.length > 1 ? (
          <div className={styles.mode_of_transport}>
            <div>
              <TextHeading theme={theme} size={4} text={t('shipment:modeOfTransport')} />
            </div>
            {motCheckBoxes}
          </div>
        ) : '' }
        <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.cargos_recap}`}>
          {cargos.map((cargo) => (
            <div className="flex-100 layout-row layout-align-start-center">
              <div>
                x
                {cargo.quantity}
              </div>
              <div className={styles.cargo_img} style={shipment.load_type === 'cargo_item' ? imgLCL : imgFCL} />
            </div>
          ))}
        </div>
        <div>
          <p style={{ fontSize: '10px', marginBottom: '10px' }}>
            <ExchangeRatesHolder exchangeRates={exchangeRates} />
          </p>
          <p style={{ fontSize: '10px', marginTop: '0' }}>{t('shipment:ttNoGuarantee')}</p>
          <p style={{ fontSize: '10px', marginTop: '0' }}>{t('shipment:invoicedLocalCurrency')}</p>
          {pickup
            ? (
              <p style={{ fontSize: '10px', marginTop: '0' }}>
                ***
                {t('shipment:pickupTakesTwoDays')}
              </p>
            )
            : '' }
        </div>
      </div>
    )
  }
}

RouteFilterBox.defaultProps = {
  departureDate: 0,
  theme: 0,
  pickup: false,
  cargos: [],
  shipment: {},
  availableMotKeys: {},
  lastAvailableDate: '',
  exchangeRates: []
}

export default withNamespaces(['shipment', 'cargo'])(RouteFilterBox)
