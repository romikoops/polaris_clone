import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Toggle from 'react-toggle'
import '../../../styles/react-toggle.scss'
import styles from '../Admin.scss'
import {
  chargeGlossary,
  currencyOptions,
  truckingRateBasises,
  rateBasisSchema
} from '../../../constants'
import { capitalize, gradientTextGenerator } from '../../../helpers'
import { NamedSelect } from '../../NamedSelect/NamedSelect'

export class TruckingDisplayPanel extends Component {
  static selectFromOptions (options, value) {
    let result
    options.forEach((op) => {
      if (op.value === value) {
        result = op
      }
    })
    return result || options[0]
  }
  static cellDisplayGenerator (fee) {
    const fields = Object.keys(fee).map((fk) => {
      const feeValue = fk !== 'currency' && fk !== 'rate_basis' ? fee[fk].toFixed(2) : fee[fk]
      const displayCell = (
        <div className="flex-20 layout-row layout-wrap">
          <div className="flex-100 layout-align-start-center">
            <p className="flex-none no_m">{chargeGlossary[fk]}</p>
          </div>
          <div className="flex-100 layout-align-start-center">
            <p className="flex-none">{feeValue}</p>
          </div>
        </div>
      )
      return displayCell
    })
    return fields
  }
  constructor (props) {
    super(props)
    this.state = {
      shrinkView: {},
      selectOptions: {},
      editor: {},
      pricing: {}
    }
    this.shrinkPanel = this.shrinkPanel.bind(this)
  }
  componentWillMount () {
    this.setAllFromOptions()
  }
  setAllFromOptions () {
    const { truckingInstance } = this.props
    const { truckingPricing } = truckingInstance
    const { directionBool } = this.state
    const directionKey = directionBool ? 'import' : 'export'
    const newObj = { data: {} }
    const tmpObj = {}
    truckingPricing[directionKey].table.forEach((pricing) => {
      Object.keys(pricing.fees).forEach((key) => {
        if (!newObj[key]) {
          newObj[key] = {}
        }
        if (!tmpObj[key]) {
          tmpObj[key] = {}
        }
        let opts
        Object.keys(pricing.fees[key]).forEach((chargeKey) => {
          if (chargeKey === 'currency') {
            opts = currencyOptions.slice()
            newObj[key][chargeKey] = TruckingDisplayPanel.selectFromOptions(
              opts,
              pricing.fees[key][chargeKey]
            )
          } else if (chargeKey === 'rate_basis') {
            opts = truckingRateBasises.slice()
            newObj[key][chargeKey] = TruckingDisplayPanel.selectFromOptions(
              opts,
              pricing.fees[key][chargeKey]
            )
          }
        })
      })
    })
    this.setState({ selectOptions: newObj })
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
  toggleEdit (i) {
    const { editor, pricing } = this.state
    let tmpPricing
    if (!pricing.modifier) {
      const { truckingInstance } = this.props
      const { truckingPricing } = truckingInstance
      tmpPricing = truckingPricing
    } else {
      tmpPricing = pricing
    }
    editor[i] = !editor[i]
    this.setState({ editor, pricing: tmpPricing })
  }
  handleSelect (selection, i, directionKey) {
    const nameKeys = selection.name.split('-')
    if (nameKeys[1] === 'rate_basis') {
      const price = this.state.pricing[directionKey].table[i].fees[nameKeys[0]]
      const newSchema = rateBasisSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if (price[k] && newSchema[k] && k !== 'rate_basis') {
          newSchema[k] = price[k]
        }
      })
      const tmpPricing = this.state.pricing
      tmpPricing[directionKey].table[i].fees[nameKeys[0]] = newSchema

      this.setState({
        pricing: tmpPricing,
        selectOptions: {
          ...this.state.selectOptions,
          [nameKeys[0]]: {
            ...this.state.selectOptions[nameKeys[0]],
            [nameKeys[1]]: selection
          }
        }
      })
    } else {
      const tmpPricing = this.state.pricing
      tmpPricing[directionKey].table[i].fees[nameKeys[0]][nameKeys[1]] = selection.value
      this.setState({
        pricing: tmpPricing,
        selectOptions: {
          ...this.state.selectOptions,
          [nameKeys[0]]: {
            ...this.state.selectOptions[nameKeys[0]],
            [nameKeys[1]]: selection
          }
        }
      })
    }
  }
  handleChange (event, i, directionKey) {
    const { name, value } = event.target
    const { pricing } = this.state
    const nameKeys = name.split('-')
    pricing[directionKey].table[i].fees[nameKeys[0]][nameKeys[1]] = parseFloat(value)

    this.setState({
      pricing
    })
  }
  saveEdit () {
    const { pricing } = this.state
    const { adminDispatch } = this.props
    adminDispatch.editTruckingPrice(pricing)
    this.toggleEdit()
  }

  cellEditorGenerator (feeKey, directionKey, i) {
    const { selectOptions, pricing } = this.state
    const fee = pricing[directionKey].table[i].fees[feeKey]
    const cells = []
    Object.keys(fee).forEach((chargeKey) => {
      if (chargeKey !== 'currency' && chargeKey !== 'rate_basis') {
        cells.push(<div
          key={chargeKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[chargeKey]}</p>
          <div className={`flex-95 layout-row ${styles.editor_input}`}>
            <input
              type="number"
              value={fee[chargeKey]}
              onChange={e => this.handleChange(e, i, directionKey)}
              name={`${feeKey}-${chargeKey}`}
            />
          </div>
        </div>)
      } else if (chargeKey === 'rate_basis') {
        cells.push(<div
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[chargeKey]}</p>
          <NamedSelect
            name={`${fee.key}-${chargeKey}`}
            classes={`${styles.select}`}
            value={selectOptions ? selectOptions[feeKey][chargeKey] : ''}
            options={truckingRateBasises}
            className="flex-100"
            onChange={e => this.handleSelect(e, i, directionKey)}
          />
        </div>)
      } else if (chargeKey === 'currency') {
        cells.push(<div
          key={chargeKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[chargeKey]}</p>
          <div className="flex-95 layout-row">
            <NamedSelect
              name={`${fee.key}-currency`}
              classes={`${styles.select}`}
              value={selectOptions ? selectOptions[feeKey].currency : ''}
              options={currencyOptions}
              className="flex-100"
              onChange={e => this.handleSelect(e, i, directionKey)}
            />
          </div>
        </div>)
      }
    })
    return cells
  }

  render () {
    const { theme, truckingInstance } = this.props
    const { truckingPricing } = truckingInstance
    const { directionBool, editor } = this.state
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

    switch (truckingPricing.modifier) {
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
    const headerStyle = {
      background: theme && theme.colors ? theme.colors.primary : 'rgba(0,0,0,0.75)'
    }
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const pricings = truckingPricing[directionKey].table
    const pricingTables = pricings.map((pricing, i) => {
      const editable = editor[i]
      const pricingCells = Object.keys(pricing.fees).map((pk) => {
        const pr = pricing.fees[pk]
        return (
          <div className={`flex-100 layout-row layout-align-start-center ${styles.trucking_cell}`}>
            <div className="flex-20 layout-row layout-wrap">
              <div className="flex-100 layout-align-start-center">
                <p className="flex-none no_m">{chargeGlossary[pk]}:</p>
              </div>
            </div>
            {editable
              ? this.cellEditorGenerator(pk, directionKey, i)
              : TruckingDisplayPanel.cellDisplayGenerator(pr)}
          </div>
        )
      })
      const startEdit = (
        <div
          className="flex-20 layout-row layout-align-end-center"
          onClick={() => this.toggleEdit(i)}
        >
          <i className="fa fa-pencil " style={{ color: 'white' }} />
        </div>
      )
      const saveClose = (
        <div className="flex-20 layout-row layout-align-end-center">
          <div
            className="flex-50 layout-row layout-align-end-center"
            onClick={() => this.saveEdit(i)}
          >
            <i className="fa fa-floppy-o " style={{ color: 'white' }} />
          </div>
          <div
            className="flex-50 layout-row layout-align-end-center"
            onClick={() => this.toggleEdit(i)}
          >
            <i className="fa fa-times " style={{ color: 'red' }} />
          </div>
        </div>
      )
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
            {editable ? saveClose : startEdit}
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
              <p className="flex-none">{`${capitalize(keyObj.upperKey)}`}</p>
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
  closeView: PropTypes.func.isRequired,
  adminDispatch: PropTypes.func
}
TruckingDisplayPanel.defaultProps = {
  theme: {},
  adminDispatch: null
}
export default TruckingDisplayPanel
