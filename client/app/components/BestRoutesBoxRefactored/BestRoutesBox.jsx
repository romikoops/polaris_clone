import React from 'react'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import { Price } from '../Price/Price'
import styles from './BestRoutesBox.scss'
import { gradientGenerator } from '../../helpers'

const CONTAINER = 'flex-100 layout-row layout-align-space-between-center'
const INNER_CONTAINER = `flex-none layout-row layout-wrap ${styles.best_card}`
const ROW = 'flex-100 layout-row'

function calcFastest (schedules, fees) {
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

  return [fastestFare, fastestSchedule]
}

function calcCheapest (schedules, fees) {
  let cheapestFare
  let cheapestSchedule

  schedules.forEach((sched) => {
    const schedKey = sched.hub_route_key

    if (!fees[schedKey]) {
      console.log('err.calcCheapest')
    }
    const fare = fees[schedKey].total

    if (!cheapestFare || fare < cheapestFare) {
      cheapestFare = fare
      cheapestSchedule = { schedule: sched, total: cheapestFare }
    }
  })

  return [cheapestFare, cheapestSchedule]
}

function factory (fare, schedule, label, user, chooseResult) {
  const onClick = () => chooseResult(schedule)

  return (
    <div className={INNER_CONTAINER} onClick={onClick}>
      <div className={ROW}>
        <h4 className="flex-none">{label}</h4>
      </div>
      <div className={ROW}>
        <Price value={fare} scale="0.75" user={user} />
      </div>
    </div>
  )
}

function sortBestOption (schedules, fees, depDate, style, user, chooseResult) {
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

    const fare = fees[schedKey]
      ? fees[schedKey].total
      : 0

    const totalScore = timeScore + fareScore + depScore

    if (totalScore < lowScore) {
      lowScore = totalScore
      bestOption = { schedule: sched, total: fare }
      bestFare = fare
    }
  })

  const onClick = () => chooseResult(bestOption)

  return (
    <div
      className={INNER_CONTAINER}
      onClick={onClick}
      style={style}
    >
      <div className={ROW}>
        <h4 className="flex-none">Best Deal</h4>
      </div>
      <div className={ROW}>
        <Price value={bestFare} scale="0.75" user={user} />
      </div>
    </div>
  )
}

export function BestRoutesBox ({
  chooseResult,
  shipmentData,
  theme,
  user
}) {
  const { schedules } = shipmentData
  const flag = shipmentData.shipment !== undefined

  const fees = flag ? shipmentData.shipment.schedules_charges : {}
  const depDate = flag ? shipmentData.shipment.planned_pickup_date : ''

  const buttonStyle = theme && theme.colors
    ? { ...gradientGenerator(theme.colors.primary, theme.colors.secondary), color: 'white' }
    : { background: 'black' }

  return (
    <div className={CONTAINER}>
      {flag && sortBestOption(schedules, fees, depDate, buttonStyle, user, chooseResult)}
      {flag && factory(...calcCheapest(schedules, fees), 'Cheapest Route', user, chooseResult)}
      {flag && factory(...calcFastest(schedules, fees), 'Fastest route', user, chooseResult)}
    </div>
  )
}

BestRoutesBox.propTypes = {
  theme: PropTypes.theme,
  shipmentData: PropTypes.shape({
    shipment: PropTypes.shipment,
    schedules: PropTypes.array
  }),
  user: PropTypes.user.isRequired,
  chooseResult: PropTypes.func.isRequired
}

BestRoutesBox.defaultProps = {
  theme: null,
  shipmentData: null
}

export default BestRoutesBox
