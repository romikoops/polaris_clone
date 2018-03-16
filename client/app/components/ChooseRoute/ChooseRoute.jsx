import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox'
// import { BestRoutesBox } from '../BestRoutesBox/BestRoutesBox'
import { RouteResult } from '../RouteResult/RouteResult'
import { moment } from '../../constants'
import styles from './ChooseRoute.scss'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import defs from '../../styles/default_classes.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { TextHeading } from '../TextHeading/TextHeading'

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
    console.log('######### MOUNTED ###########')
  }
  setDuration (val) {
    this.setState({ durationFilter: val })
  }
  setDepartureDate (date) {
    const { shipmentDispatch, req } = this.props
    req.planned_pickup_date = date
    shipmentDispatch.setShipmentDetails(req)
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
  showMore () {
    const { outerLimit } = this.state
    this.setState({ outerLimit: outerLimit + 10 })
    const { shipmentDispatch, req } = this.props
    req.delay = outerLimit + 10
    shipmentDispatch.setShipmentDetails(req)
  }

  chooseResult (obj) {
    this.props.chooseRoute(obj)
  }
  render () {
    const {
      shipmentData, messages, user, shipmentDispatch, theme
    } = this.props

    const { limits } = this.state

    let smallestDiff = 100
    if (!shipmentData) {
      return ''
    }
    const {
      shipment, originHubs, destinationHubs, schedules
    } = shipmentData
    const depDay = shipment ? shipment.planned_pickup_date : new Date()
    schedules.sort(ChooseRoute.dynamicSort('etd'))
    const idArrays = {
      closest: '',
      focus: [],
      alternative: []
    }
    let closestRoute = []
    const focusRoutes = []
    const altRoutes = []
    const motKeys = Object.keys(this.state.selectedMoT).filter(k => this.state.selectedMoT[k])
    const closestMots = {}
    schedules.forEach((sched) => {
      console.log(sched)
      if (Math.abs(moment(sched.etd).diff(sched.eta, 'days')) <= this.state.durationFilter) {
        if (
          Math.abs(moment(sched.etd).diff(depDay, 'days')) < smallestDiff &&
          motKeys.indexOf(sched.mode_of_transport) > -1
        ) {
          smallestDiff = Math.abs(moment(sched.etd).diff(depDay, 'days'))
          idArrays.closest = sched.id
          closestMots[sched.mode_of_transport] = sched
        }
        if (
          motKeys.indexOf(sched.mode_of_transport) > -1 &&
          !idArrays.focus.includes(sched.id) &&
          sched.id !== idArrays.closest
        ) {
          idArrays.focus.push(sched.id)
          focusRoutes.push(<RouteResult
            key={v4()}
            selectResult={this.chooseResult}
            theme={this.props.theme}
            originHubs={originHubs}
            destinationHubs={destinationHubs}
            fees={shipment.schedules_charges}
            schedule={sched}
            user={user}
            pickup={shipment.has_pre_carriage}
            loadType={shipment.load_type}
            pickupDate={shipment.planned_pickup_date}
          />)
        } else if (
          motKeys.indexOf(sched.mode_of_transport) < 0 &&
          !idArrays.alternative.includes(sched.id)
        ) {
          idArrays.alternative.push(sched.id)
          altRoutes.push(<RouteResult
            key={v4()}
            selectResult={this.chooseResult}
            theme={this.props.theme}
            originHubs={originHubs}
            destinationHubs={destinationHubs}
            fees={shipment.schedules_charges}
            schedule={sched}
            user={user}
            pickup={shipment.has_pre_carriage}
            loadType={shipment.load_type}
            pickupDate={shipment.planned_pickup_date}
          />)
        }
      }
    })
    closestRoute = Object
      .values(closestMots)
      .map(value =>
        (<RouteResult
          key={v4()}
          selectResult={this.chooseResult}
          theme={this.props.theme}
          originHubs={originHubs}
          destinationHubs={destinationHubs}
          fees={shipment.schedules_charges}
          schedule={value}
          user={user}
          pickup={shipment.has_pre_carriage}
          loadType={shipment.load_type}
          pickupDate={shipment.planned_pickup_date}
        />))

    const limitedFocus = limits.focus ? focusRoutes.slice(0, 3) : focusRoutes
    const limitedAlts = limits.alt ? altRoutes.slice(0, 3) : altRoutes
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
              <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                <div className="flex-none">
                  <TextHeading
                    theme={theme}
                    size={3}
                    text="This is the closest departure to the specified date"
                  />
                </div>
              </div>
              {closestRoute}
            </div>
            <div className="flex-100 layout-row layout-wrap">
              <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                <div className="flex-none">
                  <TextHeading theme={theme} size={3} text="Alternative departures" />
                </div>
              </div>
              {limitedFocus}
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
            <div className="flex-100 layout-row layout-wrap">
              <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                <div className="flex-none">
                  <TextHeading theme={theme} size={3} text="Alternative modes of transport" />
                </div>
              </div>
              {limitedAlts}
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
            </div>
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
