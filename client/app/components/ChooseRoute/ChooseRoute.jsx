import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox'
// import { BestRoutesBox } from '../BestRoutesBox/BestRoutesBox'
import { RouteResult } from '../RouteResult/RouteResult'
import { currencyOptions, moment } from '../../constants'
import styles from './ChooseRoute.scss'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import defs from '../../styles/default_classes.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { TextHeading } from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'

export class ChooseRoute extends Component {
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
        air: true
      },
      durationFilter: 40,
      limits: {
        focus: true,
        alt: true
      },
      outerLimit: 10
    }
    this.chooseResult = this.chooseResult.bind(this)
    this.setDuration = this.setDuration.bind(this)
    this.setDepartureDate = this.setDepartureDate.bind(this)
    this.setMoT = this.setMoT.bind(this)
    this.toggleLimits = this.toggleLimits.bind(this)
  }
  componentDidMount () {
    const { prevRequest, setStage } = this.props
    if (prevRequest && prevRequest.shipment) {
      // this.loadPrevReq(prevRequest.shipment);
    }
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
    req.planned_pickup_date = date
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
  }
  shiftDepartureDate (operator, days) {
    const { shipmentDispatch, req } = this.props
    let newDepartureDate
    if (operator === 'add') {
      newDepartureDate = moment(req.shipment.planned_pickup_date).add(days, 'days').format()
    } else {
      newDepartureDate = moment(req.shipment.planned_pickup_date).subtract(days, 'days').format()
    }
    req.shipment.planned_pickup_date = newDepartureDate

    shipmentDispatch.getOffers(req, false)
  }

  chooseResult (obj) {
    this.props.chooseRoute(obj)
  }
  render () {
    const {
      shipmentData, messages, user, shipmentDispatch, theme
    } = this.props
    if (!shipmentData) return ''

    const { limits, currentCurrency } = this.state

    const {
      shipment, originHubs, destinationHubs, schedules
    } = shipmentData
    if (!schedules) return ''

    const depDay = shipment ? shipment.planned_pickup_date : new Date()
    schedules.sort(ChooseRoute.dynamicSort('closing_date'))
    const closestRoutes = []
    const focusRoutes = []
    const altRoutes = []
    const mKeys = ['rail', 'ocean', 'air', 'truck']
    const motKeys = Object.keys(this.state.selectedMoT).filter(k => this.state.selectedMoT[k])
    const noMotKeys = Object.keys(this.state.selectedMoT).filter(k => !this.state.selectedMoT[k])
    const scheduleObj = {}
    mKeys.forEach((mk) => {
      scheduleObj[mk] = schedules.filter(s => s.mode_of_transport === mk)
      scheduleObj[mk].sort(ChooseRoute.dynamicSort('closing_date'))
    })
    motKeys.forEach((key) => {
      const topSched = scheduleObj[key].shift()
      if (topSched) {
        closestRoutes.push(topSched)
      }
      focusRoutes.push(...scheduleObj[key])
    })
    noMotKeys.forEach((key) => {
      altRoutes.push(...scheduleObj[key])
    })
    const focusRoutestoRender = focusRoutes.map(s => (
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
      />
    ))

    const limitedFocus = limits.focus ? focusRoutes.slice(0, 5) : focusRoutes
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
                  <p className="flex-none no_m">Show earlier departures</p>
                </div>
                <div
                  className="flex-none layout-row layout-align-space-around-center pointy"
                  onClick={() => this.shiftDepartureDate('add', 5)}
                >
                  <p className="flex-none no_m">Show later departures</p>
                  <i className="flex-none fa fa-angle-double-right"style={{ margin: '0 5px' }} />
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
                    text="This is the closest departure to the specified date"
                  />
                </div>
                <div className="flex-30 layout-row layout-align-end-center">
                  <NamedSelect
                    className="flex-100"
                    options={currencyOptions}
                    value={currentCurrency}
                    placeholder="Select Currency"
                    onChange={e => this.handleCurrencyUpdate(e)}
                  />
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
              {limitedFocus.length !== focusRoutes.length ? (
                <div className="flex-100 layout-row layout-align-center-center">
                  <div
                    className="flex-33 layout-row layout-align-space-around-center"
                    onClick={() => this.toggleLimits('focus')}
                  >
                    {limits.focus ? (
                      <i className="flex-none fa fa-angle-double-down" />
                    ) : (
                      <i className="flex-none fa fa-angle-double-up" />
                    )}
                    <div className="flex-5" />
                    {limits.focus ? (
                      <p className="flex-none">More</p>
                    ) : (
                      <p className="flex-none">Less</p>
                    )}
                    <div className="flex-5" />
                    {limits.focus ? (
                      <i className="flex-none fa fa-angle-double-down" />
                    ) : (
                      <i className="flex-none fa fa-angle-double-up" />
                    )}
                  </div>
                </div>
              ) : (
                ''
              )}
            </div>
            {/* <div className="flex-100 layout-row layout-wrap">
              <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                <div className="flex-none">
                  <TextHeading theme={theme} size={3} text="Alternative modes of transport" />
                </div>
              </div>
               {altRoutestoRender}
              {limitedAlts.length !== altRoutes.length ? (
                <div className="flex-100 layout-row layout-align-center-center">
                  <div
                    className="flex-33 layout-row layout-align-space-around-center"
                    onClick={() => this.toggleLimits('alt')}
                  >
                    {limits.alt ? (
                      <i className="flex-none fa fa-angle-double-down" />
                    ) : (
                      <i className="flex-none fa fa-angle-double-up" />
                    )}
                    <div className="flex-5" />
                    {limits.alt ? (
                      <p className="flex-none">More</p>
                    ) : (
                      <p className="flex-none">Less</p>
                    )}
                    <div className="flex-5" />
                    {limits.alt ? (
                      <i className="flex-none fa fa-angle-double-down" />
                    ) : (
                      <i className="flex-none fa fa-angle-double-up" />
                    )}
                  </div>
                </div>
              ) : (
                ''
              )}
            </div> */}
          </div>
        </div>

        {!user.guest ? (
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
        ) : (
          ''
        )}
      </div>
    )
  }
}
ChooseRoute.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user.isRequired,
  shipmentData: PropTypes.shipmentData.isRequired,
  chooseRoute: PropTypes.func.isRequired,
  messages: PropTypes.arrayOf(PropTypes.string),
  req: PropTypes.objectOf(PropTypes.any),
  setStage: PropTypes.func.isRequired,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired
}

ChooseRoute.defaultProps = {
  theme: null,
  prevRequest: null,
  messages: [],
  req: {}
}

export default ChooseRoute
