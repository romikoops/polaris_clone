import React, { Component } from 'react'
import { translate } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox'
import { RouteResult } from '../RouteResult/RouteResult'
import { currencyOptions, moment } from '../../constants'
import styles from './ChooseOffer.scss'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import defs from '../../styles/default_classes.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { TextHeading } from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'

export class ChooseOffer extends Component {
  static dynamicSort (property) {
    let sortOrder = 1
    let prop
    if (property[0] === '-') {
      sortOrder = -1
      prop = property.substr(1)
    } else {
      prop = property
    }

    return (a, b) => {
      const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop]
      const result2 = result1 ? 1 : 0

      return result2 * sortOrder
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedMoT: {
        ocean: true,
        air: true,
        truck: true,
        rail: true
      },
      durationFilter: 40,
      limits: {
        focus: true,
        alt: true
      },
      outerLimit: 20
    }
    this.chooseResult = this.chooseResult.bind(this)
    this.setDuration = this.setDuration.bind(this)
    this.setDepartureDate = this.setDepartureDate.bind(this)
    this.setMoT = this.setMoT.bind(this)
    this.toggleLimits = this.toggleLimits.bind(this)
  }
  componentDidMount () {
    const { setStage } = this.props
    window.scrollTo(0, 0)
    setStage(3)
  }
  shouldComponentUpdate () {
    return !!(this.props.shipmentData && this.props.shipmentData.shipment)
  }
  setDuration (val) {
    this.setState({ durationFilter: val })
  }
  setDepartureDate (date) {
    const { shipmentDispatch, req } = this.props
    req.shipment.selected_day = date
    shipmentDispatch.getOffers(req)
  }
  setMoT (val, target) {
    this.setState({
      selectedMoT: {
        ...this.state.selectedMoT,
        [target]: val
      }
    })
  }
  toggleLimits (target) {
    this.setState({ limits: { ...this.state.limits, [target]: !this.state.limits[target] } })
    this.showMore()
  }
  handleCurrencyUpdate (e) {
    const { value } = e
    const { shipmentDispatch, req } = this.props
    this.setState({ currentCurrency: e })
    shipmentDispatch.updateCurrency(value, req)
  }
  showMore () {
    const { outerLimit } = this.state
    const dayFactor = 10
    this.setState({ outerLimit: outerLimit + dayFactor })
    const { shipmentDispatch, req } = this.props
    req.delay = outerLimit + dayFactor
    shipmentDispatch.getOffers(req, false)
    this.setState({ outerLimit: req.delay })
  }
  shiftDepartureDate (operator, days) {
    const { shipmentDispatch, req } = this.props
    let newDepartureDate
    if (operator === 'add') {
      newDepartureDate = moment(req.shipment.selected_day)
        .add(days, 'days')
        .format()
    } else {
      newDepartureDate = moment(req.shipment.selected_day)
        .subtract(days, 'days')
        .format()
    }
    req.shipment.selected_day = newDepartureDate

    shipmentDispatch.getOffersForNewDate(req, false)
  }
  chooseResult (obj) {
    this.props.chooseOffer(obj)
  }
  render () {
    const {
      messages,
      originalSelectedDay,
      shipmentData,
      shipmentDispatch,
      t,
      tenant,
      theme,
      user
    } = this.props
    if (!shipmentData) return ''
    const { scope } = tenant.data
    const { currentCurrency } = this.state

    const {
      destinationHubs,
      originHubs,
      schedules,
      shipment
    } = shipmentData
    if (!shipment || !schedules) return ''

    const depDay = originalSelectedDay || shipment.selected_day
    schedules.sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
    const availableMoTKeys = {}
    schedules.forEach((s) => {
      if (tenant.data.scope.modes_of_transport[s.mode_of_transport][shipment.load_type]) {
        availableMoTKeys[s.mode_of_transport] = true
      }
    })
    const closestRoutes = []
    const focusRoutes = []
    const altRoutes = []
    const mKeys = Object.keys(tenant.data.scope.modes_of_transport)
      .filter(motKey => tenant.data.scope.modes_of_transport[motKey][shipment.load_type])
    const motKeys = Object.keys(this.state.selectedMoT).filter(k => this.state.selectedMoT[k])
    const noMotKeys = Object.keys(this.state.selectedMoT).filter(k => !this.state.selectedMoT[k])
    const scheduleObj = {}
    mKeys.forEach((mk) => {
      scheduleObj[mk] = schedules.filter(s => s.mode_of_transport === mk)
      scheduleObj[mk].sort((a, b) => Math.abs(moment(depDay).diff(a.closing_date)) - Math.abs(moment(depDay).diff(b.closing_date)))
    })
    motKeys.forEach((key) => {
      if (scheduleObj[key]) {
        const topSched = scheduleObj[key].shift()
        if (topSched) {
          closestRoutes.push(topSched)
        }
        scheduleObj[key].sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
        focusRoutes.push(...scheduleObj[key])
      }
    })
    noMotKeys.forEach((key) => {
      altRoutes.push(...scheduleObj[key])
    })
    const focusRoutestoRender = focusRoutes
      .sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
      .map(s => (
        <RouteResult
          key={v4()}
          selectResult={this.chooseResult}
          theme={this.props.theme}
          originHubs={originHubs}
          destinationHubs={destinationHubs}
          fees={shipment.schedules_charges}
          schedule={s}
          user={user}
          pickup={shipment.has_pre_carriage}
          loadType={shipment.load_type}
          pickupDate={shipment.planned_pickup_date}
          truckingTime={shipment.trucking.pre_carriage.trucking_time_in_seconds}
        />
      ))
    const closestRoutestoRender = closestRoutes.map(s => (
      <RouteResult
        key={v4()}
        selectResult={this.chooseResult}
        theme={this.props.theme}
        originHubs={originHubs}
        destinationHubs={destinationHubs}
        fees={shipment.schedules_charges}
        schedule={s}
        user={user}
        pickup={shipment.has_pre_carriage}
        loadType={shipment.load_type}
        pickupDate={shipment.planned_pickup_date}
        truckingTime={shipment.trucking.pre_carriage.trucking_time_in_seconds}
      />
    ))
    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''

    return (
      <div
        className="flex-100 layout-row layout-align-center-start layout-wrap"
        style={{ marginTop: '62px', marginBottom: '166px' }}
      >
        {flash}
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div className="flex-20 layout-row layout-wrap">
            <RouteFilterBox
              theme={theme}
              pickup={shipment.has_pre_carriage}
              setDurationFilter={this.setDuration}
              durationFilter={this.state.durationFilter}
              setMoT={this.setMoT}
              moT={this.state.selectedMoT}
              departureDate={depDay}
              shipment={shipment}
              availableMotKeys={availableMoTKeys}
              setDepartureDate={this.setDepartureDate}
            />
          </div>
          <div className="flex-75 offset-5 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-wrap">
              <div className="flex-100 layout-row layout-align-space-between-center">
                <div
                  className="flex-none layout-row layout-align-space-around-center pointy"
                  onClick={() => this.shiftDepartureDate('subtract', 5)}
                >
                  <i className="flex-none fa fa-angle-double-left" style={{ margin: '0 5px' }} />
                  <p className="flex-none no_m">
                    {t('common:earlierDepartures')}
                  </p>
                </div>
                <div
                  className="flex-none layout-row layout-align-space-around-center pointy"
                  onClick={() => this.shiftDepartureDate('add', 5)}
                >
                  <p className="flex-none no_m">
                    {t('common:laterDepartures')}
                  </p>
                  <i className="flex-none fa fa-angle-double-right" style={{ margin: '0 5px' }} />
                </div>
              </div>
              <div
                className={`flex-100 layout-row layout-align-space-between-center ${
                  styles.route_header
                }`}
              >
                <div className="flex-none">
                  <TextHeading
                    theme={theme}
                    size={3}
                    text={t('common:closestDeparture')}
                  />
                </div>
                <div className="flex-30 layout-row layout-align-end-center">
                  {scope.fixed_currency ? (
                    ''
                  ) : (
                    <NamedSelect
                      className="flex-100"
                      options={currencyOptions}
                      value={currentCurrency}
                      placeholder={t('common:selectCurrency')}
                      onChange={e => this.handleCurrencyUpdate(e)}
                    />
                  )}
                </div>
              </div>
              {closestRoutestoRender}
            </div>
            <div className="flex-100 layout-row layout-wrap">
              <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                <div className="flex-none">
                  <TextHeading theme={theme} size={3} text="Alternative departures" />
                </div>
              </div>
              {focusRoutestoRender}

              <div className="flex-100 layout-row layout-align-center-center">
                <div
                  className="flex-33 layout-row layout-align-space-around-center"
                  onClick={() => this.showMore()}
                >
                  <i className="flex-none fa fa-angle-double-down" />
                  <div className="flex-5" />
                  <p className="flex-none">More</p>
                  <div className="flex-5" />
                  <i className="flex-none fa fa-angle-double-down" />
                </div>
              </div>

            </div>
          </div>
        </div>

        {!user.guest && (
          <div
            className={`${
              styles.back_to_dash_sec
            } flex-100 layout-row layout-wrap layout-align-center`}
          >
            <div className="content_width_booking flex-none layout-row layout-align-start-center">
              <RoundButton
                theme={theme}
                text="Back to dashboard"
                back
                iconClass="fa-angle0-left"
                handleNext={() => shipmentDispatch.goTo('/account')}
              />
            </div>
          </div>
        )}
      </div>
    )
  }
}

ChooseOffer.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user.isRequired,
  shipmentData: PropTypes.shipmentData.isRequired,
  chooseOffer: PropTypes.func.isRequired,
  messages: PropTypes.arrayOf(PropTypes.string),
  req: PropTypes.objectOf(PropTypes.any),
  setStage: PropTypes.func.isRequired,
  originalSelectedDay: PropTypes.string,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired,
  tenant: PropTypes.tenant
}

ChooseOffer.defaultProps = {
  theme: null,
  prevRequest: null,
  messages: [],
  req: {},
  tenant: {},
  originalSelectedDay: false
}

export default translate('common')(ChooseOffer)
