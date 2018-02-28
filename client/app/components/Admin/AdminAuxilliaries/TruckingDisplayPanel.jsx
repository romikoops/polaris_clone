import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from '../Admin.scss'
import { chargeGlossary } from '../../../constants'
import { capitalize, gradientTextGenerator } from '../../../helpers'

export class TruckingDisplayPanel extends Component {
  static cellDisplayGenerator (fee) {
    const fields = Object.keys(fee).map((fk) => {
      const feeValue = fk !== 'currency' && fk !== 'rate_basis' ? fee[fk].toFixed(2) : fee[fk]
      return (
        <div className="flex-20 layout-row layout-wrap">
          <div className="flex-100 layout-align-start-center">
            <p className="flex-none no_m">{chargeGlossary[fk]}</p>
          </div>
          <div className="flex-100 layout-align-start-center">
            <p className="flex-none">{feeValue}</p>
          </div>
        </div>
      )
    })
    return fields
  }
  constructor (props) {
    super(props)
    this.state = {
      shrinkView: {}
    }
    this.shrinkPanel = this.shrinkPanel.bind(this)
  }
  shrinkPanel (key) {
    this.setState({
      shrinkView: {
        ...this.state.shrinkView,
        [key]: !this.state.shrinkView[key]
      }
    })
  }

  render () {
    const { theme, truckingInstance, truckingHub } = this.props

    const { query, pricings } = truckingInstance
    const keyObj = {}
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    switch (truckingHub.modifier) {
      case 'zipcode':
        keyObj.upperKey = 'upper_zip'
        keyObj.lowerKey = 'lower_zip'
        break
      case 'city':
        keyObj.upperKey = 'city'
        keyObj.lowerKey = 'province'
        break
      case 'distance':
        keyObj.upperKey = 'upper_distance'
        keyObj.lowerKey = 'lower_distance'
        break
      default:
        break
    }
    switch (query.modifier) {
      case 'kg':
        keyObj.cellUpperKey = 'max_weight'
        keyObj.cellLowerKey = 'min_weight'
        break
      case 'cbm':
        keyObj.cellUpperKey = 'max_cbm'
        keyObj.cellLowerKey = 'min_cbm'
        break
      case 'distance':
        keyObj.cellUpperKey = 'max_km'
        keyObj.cellLowerKey = 'min_km'
        break
      default:
        break
    }
    const pricingTables = pricings.map((pricing) => {
      const pricingCells = Object.keys(pricing.fees).map((pk) => {
        const pr = pricing.fees[pk]
        return (
          <div className={`flex-100 layout-row layout-align-start-center ${styles.trucking_cell}`}>
            <div className="flex-20 layout-row layout-wrap">
              <div className="flex-100 layout-align-start-center">
                <p className="flex-none no_m">{chargeGlossary[pk]}:</p>
              </div>
            </div>
            {TruckingDisplayPanel.cellDisplayGenerator(pr)}
          </div>
        )
      })
      return (
        <div
          className={`flex-100 layout-row layout-align-start-center layout-wrap ${
            styles.trucking_inner_row
          }`}
        >
          <div
            className={`${
              styles.trucking_fee_header
            } flex-100 layout-row layout-align-start-center`}
          >
            <div
              className={`flex-15 layout-row layout-align-start-center layout-wrap ${
                styles.trucking_cell
              }`}
            >
              <p className={`flex-100 ${styles.trucking_cell_label}`}>Modifier</p>
              <p className="flex-100 clip " style={textStyle}>
                {capitalize(query.modifier)}
              </p>
            </div>
            <div
              className={`flex-20 layout-row layout-align-start-center layout-wrap ${
                styles.trucking_cell
              }`}
            >
              <p className={`flex-100 ${styles.trucking_cell_label}`}>
                {chargeGlossary[keyObj.cellLowerKey]}
              </p>
              <p className="flex-100">{pricing[keyObj.cellLowerKey]}</p>
            </div>
            <div
              className={`flex-20 layout-row layout-align-start-center layout-wrap ${
                styles.trucking_cell
              }`}
            >
              <p className={`flex-100 ${styles.trucking_cell_label}`}>
                {chargeGlossary[keyObj.cellUpperKey]}
              </p>
              <p className="flex-100">{pricing[keyObj.cellUpperKey]}</p>
            </div>
            {pricing.min_value ? (
              <div
                className={`flex-20 layout-row layout-align-start-center layout-wrap ${
                  styles.trucking_cell
                }`}
              >
                <p className={`flex-100 ${styles.trucking_cell_label}`}>
                  {chargeGlossary.min_value}
                </p>
                <p className="flex-100">{pricing.min_value}</p>
              </div>
            ) : (
              ''
            )}
          </div>
          <div
            className={`${
              styles.trucking_fee_breakdown
            } flex-100 layout-row layout-align-center-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <p className={`flex-none no_m ${styles.fee_subtitle}`}>Fee Breakdown:</p>
            </div>
            <div className="flex-95 layout-row layout-wrap layout-align-start-start">
              {pricingCells}
            </div>
          </div>
        </div>
      )
    })
    return (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-end-center">
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={this.props.closeView}
          >
            <i className="fa fa-close clip" style={textStyle} />
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            <h4 className="flex-none clip" style={textStyle}>
              {capitalize(truckingHub.modifier)}
            </h4>
            <div className="flex-5" />
            {truckingHub.modifier === 'city' ? (
              <p className="flex-none">
                {`${capitalize(query[truckingHub.modifier][keyObj.lowerKey])} - ${capitalize(query[truckingHub.modifier][keyObj.upperKey])}`}
              </p>
            ) : (
              <p className="flex-none">
                {`${query[truckingHub.modifier][keyObj.lowerKey]} - ${
                  query[truckingHub.modifier][keyObj.upperKey]
                }`}
              </p>
            )}
          </div>
          {pricingTables}
        </div>
      </div>
    )
  }
}
TruckingDisplayPanel.propTypes = {
  theme: PropTypes.theme,
  truckingInstance: PropTypes.objectOf(PropTypes.any).isRequired,
  truckingHub: PropTypes.objectOf(PropTypes.any).isRequired,
  closeView: PropTypes.func.isRequired
}
TruckingDisplayPanel.defaultProps = {
  theme: {}
}
export default TruckingDisplayPanel
