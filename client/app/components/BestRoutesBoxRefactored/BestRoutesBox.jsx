import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import { Price } from '../Price/Price'
import styles from './BestRoutesBox.scss'
import { gradientGenerator } from '../../helpers'
import { trim, ROW } from '../../classNames'

export class BestRoutesBox extends Component {
  calcFastest (schedules, fees) {
    let fastestTime
    let fastestSchedule
    let fastestFare
    schedules.forEach((sched) => {
      const travelTime = moment(sched.eta).diff(sched.etd)
      const schedKey = sched.hub_route_key
      const fare = fees[schedKey].total
      const ok = !fastestTime || travelTime < fastestTime
      if (ok) {
        fastestTime = travelTime
        fastestSchedule = {
          schedule: sched,
          total: fare
        }
        fastestFare = fees[schedKey].total
      }
    })

    return (
      <div
        className={trim(`
          flex-none 
          layout-row 
          layout-wrap 
          ${styles.best_card}
        `)}
        onClick={() => this.props.chooseResult(fastestSchedule)}
      >
        <div className="flex-100 layout-row">
          <h4 className="flex-none">Fastest route</h4>
        </div>
        <div className="flex-100 layout-row">
          <Price
            currency={this.props.user.currency}
            scale="0.75"
            value={fastestFare}
          />
        </div>
      </div>
    )
  }

  calcCheapest (schedules, fees) {
    let cheapestFare
    let cheapestSchedule
    schedules.forEach((sched) => {
      const schedKey = sched.hub_route_key
      if (!fees[schedKey]) {
        console.log('err')
      }
      const fare = fees[schedKey].total
      const ok = !cheapestFare || fare < cheapestFare
      if (ok) {
        cheapestFare = fare
        cheapestSchedule = {
          schedule: sched,
          total: cheapestFare
        }
      }
    })

    return (
      <div
        className={trim(`
          flex-none 
          layout-row 
          layout-wrap 
          ${styles.best_card}`)}
        onClick={() => this.props.chooseResult(cheapestSchedule)}
      >
        <div className={ROW(100)}>
          <h4 className="flex-none">
            Cheapest Route
          </h4>
        </div>
        <div className={ROW(100)}>
          <Price
            currency={this.props.user.currency}
            scale="0.75"
            value={cheapestFare}
          />
        </div>
      </div>
    )
  }
  sortBestOption (
    schedules,
    fees,
    depDate,
    style
  ) {
    const fareArray = schedules.sort((a, b) => {
      const aKey = a.hub_route_key
      const bKey = b.hub_route_key

      return fees[aKey] - fees[bKey]
    })
    const timeArray = schedules.sort((a, b) => moment(a.eta).diff(b.etd))
    const depArray = schedules.sort((a, b) => {
      const aDiff = moment(depDate).diff(a.etd)
      const bDiff = moment(depDate).diff(b.etd)

      return aDiff - bDiff
    })
    let lowScore = 100
    let bestFare
    let bestOption
    schedules.forEach((sched) => {
      const timeScore = timeArray.indexOf(sched)
      const fareScore = fareArray.indexOf(sched)
      const depScore = depArray.indexOf(sched)
      const schedKey = sched.hub_route_key
      const fare = fees[schedKey] ? fees[schedKey].total : 0
      const totalScore = timeScore + fareScore + depScore
      if (totalScore < lowScore) {
        bestFare = fare
        lowScore = totalScore
        bestOption = {
          schedule: sched,
          total: fare
        }
      }
    })

    return (
      <div
        className={trim(`
          flex-none 
          layout-row 
          layout-wrap 
          ${styles.best_card}
        `)}
        onClick={() => this.props.chooseResult(bestOption)}
        style={style}
      >
        <div className={ROW(100)}>
          <h4 className="flex-none">
            Best Deal
          </h4>
        </div>
        <div className={ROW(100)}>
          <Price
            currency={this.props.user.currency}
            scale="0.75"
            value={bestFare}
          />
        </div>
      </div>
    )
  }

  render () {
    const { theme, shipmentData } = this.props
    const { schedules } = shipmentData
    const fees = shipmentData.shipment ? shipmentData.shipment.schedules_charges : {}

    const depDate = shipmentData.shipment ? shipmentData.shipment.planned_pickup_date : ''

    const activeBtnStyle =
      theme && theme.colors
        ? { ...gradientGenerator(theme.colors.primary, theme.colors.secondary), color: 'white' }
        : { background: 'black' }

    const Shipment = shipmentData.shipment ? this.sortBestOption(schedules, fees, depDate, activeBtnStyle) : ''

    const Cheapest = shipmentData.shipment ? this.calcCheapest(schedules, fees) : ''

    const Fastest = shipmentData.shipment ? this.calcFastest(schedules, fees) : ''

    return (
      <div className={trim(`
        flex-100 
        layout-row layout-align-space-between-center
      `)}
      >
        {Shipment}
        {Cheapest}
        {Fastest}
      </div>
    )
  }
}
BestRoutesBox.propTypes = {
  chooseResult: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  user: PropTypes.user.isRequired,
  shipmentData: PropTypes.shape({
    shipment: PropTypes.shipment,
    schedules: PropTypes.array
  })
}

BestRoutesBox.defaultProps = {
  theme: null,
  shipmentData: null
}

export default BestRoutesBox
