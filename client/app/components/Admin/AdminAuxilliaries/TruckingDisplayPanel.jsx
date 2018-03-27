import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Toggle from 'react-toggle'
import '../../../styles/react-toggle.scss'
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
  handleDirectionToggle (value) {
    this.setState({ directionBool: !this.state.directionBool })
  }

  render () {
    const { theme, truckingInstance } = this.props
    const { truckingPricing } = truckingInstance
    const { directionBool } = this.state
    const keyObj = {}
    const directionKey = directionBool ? 'import' : 'export'
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightPrimary} 0%,
          ${theme.colors.brightSecondary} 100%
        ) !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: rgba(0, 0, 0, 0.75);
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    let modifier = ''
    if (truckingInstance.zipcode) {
      [keyObj.upperKey, keyObj.lowerKey] = truckingInstance.zipcode
    } else if (truckingInstance.city) {
      [keyObj.upperKey] = truckingInstance.city
    } else if (truckingInstance.distance) {
      [keyObj.upperKey, keyObj.lowerKey] = truckingInstance.distance
    }
    if (truckingInstance.zipcode) {
      modifier = 'Zipcode'
    } else if (truckingInstance.city) {
      modifier = 'City'
    } else if (truckingInstance.distance) {
      modifier = 'Distance'
    }

    switch (truckingInstance.modifier) {
      case 'kg':
        keyObj.cellUpperKey = 'Max Weight'
        keyObj.cellLowerKey = 'Min Weight'
        break
      case 'cbm':
        keyObj.cellUpperKey = 'Max Cbm'
        keyObj.cellLowerKey = 'Min Cbm'
        break
      case 'distance':
        keyObj.cellUpperKey = 'Max Km'
        keyObj.cellLowerKey = 'Min Km'
        break
      default:
        break
    }
    const headerStyle = {
      background: theme && theme.colors ? theme.colors.primary : 'rgba(0,0,0,0.75)'
    }
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const pricings = truckingPricing[directionKey].table
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
            style={headerStyle}
          >
            <div
              className={`flex-15 layout-row layout-align-start-center layout-wrap ${
                styles.trucking_cell
              }`}
            >
              <p className={`flex-100 ${styles.trucking_cell_label}`}>Modifier</p>
              <p className="flex-100 clip " style={textStyle}>
                {capitalize(truckingPricing.modifier)}
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
          <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
            <h4 className="flex-none clip" style={textStyle}>
              {capitalize(modifier)}
            </h4>
            <div className="flex-5" />
            {modifier === 'City' ? (
              <p className="flex-none">
                {`${capitalize(keyObj.upperKey)}`}
              </p>
            ) : (
              <p className="flex-none">{`${keyObj.lowerKey} - ${keyObj.upperKey}`}</p>
            )}
            <div className="flex-30 layout-row layout-align-end-center">
              <p className="flex-none">Toggle Import/Export View</p>
              <div className="flex-5" />
              <Toggle
                className="flex-none"
                id="unitView"
                name="unitView"
                checked={directionBool}
                onChange={e => this.handleDirectionToggle(e)}
              />
            </div>
          </div>
          {pricingTables}
        </div>
        {styleTagJSX}
      </div>
    )
  }
}
TruckingDisplayPanel.propTypes = {
  theme: PropTypes.theme,
  truckingInstance: PropTypes.objectOf(PropTypes.any).isRequired,
  closeView: PropTypes.func.isRequired
}
TruckingDisplayPanel.defaultProps = {
  theme: {}
}
export default TruckingDisplayPanel
