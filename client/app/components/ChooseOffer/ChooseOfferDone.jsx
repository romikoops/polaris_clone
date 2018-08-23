import React, { Component } from 'react'
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

import { trim, ROW, WRAP_ROW, ALIGN_CENTER } from '../../classNames'

const CONTAINER = `CHOOSE_OFFER ${WRAP_ROW(100)} ${ALIGN_CENTER}`
const POINTY = 'flex-none layout-row layout-align-space-around-center pointy'
const ANGLE_LEFT_ICON = 'flex-none fa fa-angle-double-left'
const ANGLE_RIGHT_ICON = 'flex-none fa fa-angle-double-right'
const ANGLE_DOWN_ICON = 'flex-none fa fa-angle-double-down'
const DEPARTURE_TEXT = 'This is the closest departure to the specified date'

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
      const initialResult = a[prop] < b[prop] ? -1 : a[prop] > b[prop]
      const result = initialResult ? 1 : 0

      return result * sortOrder
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      durationFilter: 40,
      outerLimit: 20,
      limits: {
        focus: true,
        alt: true
      },
      selectedMoT: {
        air: true,
        ocean: true,
        rail: true,
        truck: true
      }
    }
    this.chooseResult = this.chooseResult.bind(this)
    this.setDepartureDate = this.setDepartureDate.bind(this)
    this.setDuration = this.setDuration.bind(this)
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
    this.setState(prevState => ({
      selectedMoT: {
        ...this.prevState.selectedMoT,
        [target]: val
      }
    }))
  }
  toggleLimits (target) {
    this.setState(prevState => ({
      limits: {
        ...this.state.limits,
        [target]: !this.prevState.limits[target]
      }
    }))
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
    const { shipmentDispatch, req } = this.props
    const dayFactor = 10

    this.setState({ outerLimit: outerLimit + dayFactor })
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
      shipmentData,
      messages,
      user,
      shipmentDispatch,
      theme,
      tenant,
      originalSelectedDay
    } = this.props
    if (!shipmentData) return ''

    const { scope } = tenant.data
    const { currentCurrency } = this.state
    const {
      shipment,
      originHubs,
      destinationHubs,
      schedules
    } = shipmentData
    if (!shipment || !schedules) return ''

    const availableMoTKeys = {}
    const scheduleObj = {}
    const closestRoutes = []
    const focusRoutes = []
    const altRoutes = []
    const modesOfTransport = tenant.data.scope.modes_of_transport
    const depDay = originalSelectedDay || shipment.selected_day
    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''

    schedules.sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
    schedules.forEach((s) => {
      if (modesOfTransport[s.mode_of_transport][shipment.load_type]) {
        availableMoTKeys[s.mode_of_transport] = true
      }
    })

    const mKeys = Object.keys(modesOfTransport).filter(motKey => modesOfTransport[motKey][shipment.load_type])
    const motKeys = Object.keys(this.state.selectedMoT).filter(k => this.state.selectedMoT[k])
    const noMotKeys = Object.keys(this.state.selectedMoT).filter(k => !this.state.selectedMoT[k])

    mKeys.forEach((mk) => {
      scheduleObj[mk] = schedules.filter(s => s.mode_of_transport === mk)
      scheduleObj[mk].sort((a, b) => {
        const aDiff = Math.abs(moment(depDay).diff(a.closing_date))
        const bDiff = Math.abs(moment(depDay).diff(b.closing_date))

        return aDiff - bDiff
      })
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
    const BackToDashboard = () => {
      if (user.guest) return ''

      const backToDash = trim(`
        ${styles.back_to_dash_sec} 
        ${WRAP_ROW(100)} 
        layout-align-center
      `)

      return (
        <div
          className={backToDash}
        >
          <div className={trim(`
            content_width_booking 
            flex-none 
            layout-row 
            layout-align-start-center
          `)}
          >
            <RoundButton
              theme={theme}
              text="Back to dashboard"
              back
              iconClass="fa-angle0-left"
              handleNext={() => shipmentDispatch.goTo('/account')}
            />
          </div>
        </div>
      )
    }
    const AlternativeDepartures = (
      <TextHeading
        theme={theme}
        size={3}
        text="Alternative departures"
      />
    )
    const NamedSelectComponent = () => {
      if (scope.fixed_currency) return ''

      return (<NamedSelect
        className="flex-100"
        options={currencyOptions}
        value={currentCurrency}
        placeholder="Select Currency"
        onChange={e => this.handleCurrencyUpdate(e)}
      />
      )
    }
    const RouteFilterBoxComponent = (
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
    )

    return (
      <div
        className={CONTAINER}
        style={{ marginTop: '62px', marginBottom: '166px' }}
      >
        {flash}
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div className={WRAP_ROW(20)}>{RouteFilterBoxComponent}</div>

          <div className={`${WRAP_ROW(75)} offset-5`}>
            <div className={WRAP_ROW(100)}>
              <div className={`${ROW(100)} layout-align-space-between-center`}>
                <div
                  className={POINTY}
                  onClick={() => this.shiftDepartureDate('subtract', 5)}
                >
                  <i className={ANGLE_LEFT_ICON} style={{ margin: '0 5px' }} />
                  <p className="flex-none no_m">Show earlier departures</p>
                </div>

                <div
                  className={POINTY}
                  onClick={() => this.shiftDepartureDate('add', 5)}
                >
                  <p className="flex-none no_m">Show later departures</p>
                  <i className={ANGLE_RIGHT_ICON} style={{ margin: '0 5px' }} />
                </div>
              </div>

              <div className={trim(`
                ${ROW(100)} 
                layout-align-space-between-center 
                ${styles.route_header}
              `)}
              >
                <div className="flex-none">
                  <TextHeading
                    theme={theme}
                    size={3}
                    text={DEPARTURE_TEXT}
                  />
                </div>

                <div className={`${ROW(30)} layout-align-end-center`}>
                  {NamedSelectComponent()}
                </div>
              </div>
              {closestRoutestoRender}
            </div>

            <div className={WRAP_ROW(100)}>
              <div className={trim(`
                ${ROW(100)} 
                layout-align-start
                ${styles.route_header}
              `)}
              >
                <div className="flex-none">{AlternativeDepartures}</div>
              </div>

              {focusRoutestoRender}

              <div className={`${ROW(100)} ${ALIGN_CENTER}`}>
                <div
                  onClick={() => this.showMore()}
                  className={`${ROW(33)} layout-align-space-around-center`}
                >
                  <i className={ANGLE_DOWN_ICON} />
                  <div className="flex-5" />
                  <p className="flex-none">More</p>
                  <div className="flex-5" />
                  <i className={ANGLE_DOWN_ICON} />
                </div>
              </div>
            </div>
          </div>
        </div>

        {BackToDashboard()}
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

export default ChooseOffer
