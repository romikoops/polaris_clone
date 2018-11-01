import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import { Price } from '../Price/Price'
import styles from './BestRoutesBox.scss'
import { gradientGenerator } from '../../helpers'

export class BestRoutesBox extends Component {
  calcFastest (schedules, fees, t) {
    let fastestTime
    let fastestSchedule
    let fastestFare
    schedules.forEach((sched) => {
      const travelTime = moment(sched.eta).diff(sched.etd)
      const schedKey = sched.hub_route_key
      const fare = fees[schedKey].total
      if (!fastestTime || travelTime < fastestTime) {
        fastestTime = travelTime
        fastestSchedule = { schedule: sched, total: fare }
        fastestFare = fees[schedKey].total
      }
    })

    return (
      <div
        className={`flex-none layout-row layout-wrap ${styles.best_card}`}
        onClick={() => this.props.chooseResult(fastestSchedule)}
      >
        <div className="flex-100 layout-row">
          <h4 className="flex-none">{t('common:fastestRoute')}</h4>
        </div>
        <div className="flex-100 layout-row">
          <Price value={fastestFare} scale="0.75" currency={this.props.user.currency} />
        </div>
      </div>
    )
  }

  calcCheapest (schedules, fees, t) {
    let cheapestFare
    let cheapestSchedule
    schedules.forEach((sched) => {
      const schedKey = sched.hub_route_key
      if (!fees[schedKey]) {
        // eslint-disable-next-line no-console
        console.log('err')
      }
      const fare = fees[schedKey].total
      if (!cheapestFare || fare < cheapestFare) {
        cheapestFare = fare
        cheapestSchedule = { schedule: sched, total: cheapestFare }
      }
    })

    return (
      <div
        className={`flex-none layout-row layout-wrap ${styles.best_card}`}
        onClick={() => this.props.chooseResult(cheapestSchedule)}
      >
        <div className="flex-100 layout-row">
          <h4 className="flex-none">{t('common:cheapestRoute')}</h4>
        </div>
        <div className="flex-100 layout-row">
          <Price value={cheapestFare} scale="0.75" currency={this.props.user.currency} />
        </div>
      </div>
    )
  }
  sortBestOption (schedules, fees, depDate, style) {
    const fareArray = schedules.sort((a, b) => {
      const aKey = a.hub_route_key
      const bKey = b.hub_route_key

      return fees[aKey] - fees[bKey]
    })
    const timeArray = schedules.sort((a, b) => moment(a.eta).diff(b.etd))
    const depArray = schedules.sort((a, b) => (
      moment(depDate).diff(a.etd) - moment(depDate).diff(b.etd)
    ))

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
        lowScore = totalScore
        bestOption = { schedule: sched, total: fare }
        bestFare = fare
      }
    })

    return (
      <div
        className={`flex-none layout-row layout-wrap ${styles.best_card}`}
        onClick={() => this.props.chooseResult(bestOption)}
        style={style}
      >
        <div className="flex-100 layout-row">
          <h4 className="flex-none">Best Deal</h4>
        </div>
        <div className="flex-100 layout-row">
          <Price value={bestFare} scale="0.75" currency={this.props.user.currency} />
        </div>
      </div>
    )
  }

  render () {
    const { theme, shipmentData, t } = this.props
    const { schedules } = shipmentData
    const fees = shipmentData.shipment ? shipmentData.shipment.schedules_charges : {}

    const depDate = shipmentData.shipment ? shipmentData.shipment.planned_pickup_date : ''

    const activeBtnStyle =
      theme && theme.colors
        ? { ...gradientGenerator(theme.colors.primary, theme.colors.secondary), color: 'white' }
        : { background: 'black' }

    return (
      <div className="flex-100 layout-row layout-align-space-between-center">
        {shipmentData.shipment ? this.sortBestOption(schedules, fees, depDate, activeBtnStyle) : ''}
        {shipmentData.shipment ? this.calcCheapest(schedules, fees, t) : ''}
        {shipmentData.shipment ? this.calcFastest(schedules, fees, t) : ''}
      </div>
    )
  }
}
BestRoutesBox.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  shipmentData: PropTypes.shape({
    shipment: PropTypes.shipment,
    schedules: PropTypes.array
  }),
  user: PropTypes.user.isRequired,
  chooseResult: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired
}

BestRoutesBox.defaultProps = {
  theme: null,
  shipmentData: null
}

export default withNamespaces('common')(BestRoutesBox)
