import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import '../../../styles/react-toggle.scss'
import styles from '../Admin.scss'
import {
  chargeGlossary,
  currencyOptions,
  truckingRateBasises,
  rateBasisSchema,
  TRUCKING_ICONS
} from '../../../constants'
import { capitalize, gradientTextGenerator } from '../../../helpers'
import { NamedSelect } from '../../NamedSelect/NamedSelect'

const rbSchema = rateBasisSchema
function getTruckingPricingKey (truckingPricing) {
  if (truckingPricing.zipcode) {
    const joinedArrays = truckingPricing.zipcode.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }
  if (truckingPricing.city) {
    const joinedArrays = truckingPricing.city.map(zArray => zArray.join(', '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }
  if (truckingPricing.distance) {
    const joinedArrays = truckingPricing.distance.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }

  return ''
}

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
  static rateCellDisplayGenerator (fee, modKey) {
    if (!fee) {
      return ''
    }
    const modifierString =
      fee.rate.base === 1 ? `per ${modKey}` : `per ${fee.rate.base} ${modKey}'s`
    const displayCell = (
      <div key={v4()} className={`flex-100 layout-row layout-align-space-between-center ${styles.range_cell}`}>
        <div className="flex-33 layout-align-start-center">
          <p className="flex-none no_m">
            {`${parseInt(fee[`min_${modKey}`], 10)} - ${parseInt(
              fee[`max_${modKey}`],
              10
            )}  ${capitalize(modKey)}`}
          </p>
        </div>
        <div className="flex-33 layout-align-end-center">
          <p className="flex-none">{`${fee.rate.currency} ${fee.rate.value.toFixed(2)} ${modifierString}`}</p>
        </div>
      </div>
    )

    return displayCell
  }
  static feeCellDisplayGenerator (fee) {
    const cells = []
    const dnrKeys = ['currency', 'rate_basis', 'range', 'key', 'base']
    Object.keys(fee).forEach((chargeKey) => {
      if (dnrKeys.indexOf(chargeKey) < 0) {
        cells.push(<div className={`flex-25 layout-row layout-align-none-center ${styles.price_cell}`}>
          <p className="flex-none">{chargeGlossary[chargeKey]}</p>
          <p className="flex">
            {fee[chargeKey]} {fee.currency}
          </p>
        </div>)
      } else if (chargeKey === 'rate_basis') {
        cells.push(<div className={`flex-25 layout-row layout-align-none-center ${styles.price_cell}`}>
          <p className="flex-none">{chargeGlossary[chargeKey]}</p>
          <p className="flex">{chargeGlossary[fee[chargeKey]]}</p>
        </div>)
      }
    })

    return (
      <div className={`flex-100 layout-row layout-align-space-between-center ${styles.range_cell}`}>
        <div className={`flex-100 layout-row layout-align-start-center ${styles.price_subheader}`}>
          <p className="flex-none">
            {fee.key} - {chargeGlossary[fee.key]}
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">{cells}</div>
      </div>
    )
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
    const newObj = { rates: {}, fees: {} }
    Object.keys(truckingPricing.rates).forEach((modKey) => {
      if (!newObj.rates[modKey]) {
        newObj.rates[modKey] = []
      }
      truckingPricing.rates[modKey].forEach((pricing, i) => {
        if (!newObj.rates[modKey][i]) {
          newObj.rates[modKey][i] = {}
        }
        let opts
        if (pricing) {
          Object.keys(pricing.rate).forEach((chargeKey) => {
            if (chargeKey === 'currency') {
              opts = currencyOptions.slice()
              newObj.rates[modKey][i][chargeKey] = TruckingDisplayPanel.selectFromOptions(
                opts,
                pricing.rate[chargeKey]
              )
            } else if (chargeKey === 'rate_basis') {
              opts = truckingRateBasises.slice()
              newObj.rates[modKey][i][chargeKey] = TruckingDisplayPanel.selectFromOptions(
                opts,
                pricing.rate[chargeKey]
              )
            }
          })
        }
      })
    })
    Object.keys(truckingPricing.fees).forEach((feeKey) => {
      const fee = truckingPricing.fees[feeKey]
      if (!newObj.fees[feeKey]) {
        newObj.fees[feeKey] = {}
      }
      let opts
      Object.keys(fee).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOptions.slice()
          newObj.fees[feeKey][chargeKey] = TruckingDisplayPanel.selectFromOptions(
            opts,
            fee[chargeKey]
          )
        } else if (chargeKey === 'rate_basis') {
          opts = truckingRateBasises.slice()
          newObj.fees[feeKey][chargeKey] = TruckingDisplayPanel.selectFromOptions(
            opts,
            fee[chargeKey]
          )
        }
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
    let { editor } = this.state
    const { pricing } = this.state
    let tmpPricing
    if (!pricing.modifier) {
      const { truckingInstance } = this.props
      const { truckingPricing } = truckingInstance
      tmpPricing = truckingPricing
    } else {
      tmpPricing = pricing
    }
    if (i) {
      editor[i] = !editor[i]
    } else {
      editor = {}
    }
    this.setState({ editor, pricing: tmpPricing })
  }
  handleRateSelect (selection, i, modKey) {
    const nameKeys = selection.name.split('-')
    const tmpPricing = this.state.pricing
    const tmpSelect = this.state.selectOptions
    if (nameKeys[1] === 'rate_basis') {
      const price = this.state.pricing.rates[modKey][i][nameKeys[0]]

      const newSchema = rbSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if (price[k] && newSchema[k] && k !== 'rate_basis') {
          newSchema[k] = price[k]
        }
      })
      tmpPricing.rates[modKey][i][nameKeys[1]] = newSchema
      tmpSelect.rates[modKey][i][nameKeys[1]] = selection

      this.setState({
        pricing: tmpPricing,
        selectOptions: tmpSelect
      })
    } else {
      tmpPricing.rates[modKey][i][nameKeys[1]] = selection.value
      tmpSelect.rates[modKey][i][nameKeys[1]] = selection
      this.setState({
        pricing: tmpPricing,
        selectOptions: tmpSelect
      })
    }
  }
  handleFeeSelect (selection, feeKey) {
    const nameKey = selection.name
    const tmpPricing = this.state.pricing
    const tmpSelect = this.state.selectOptions
    if (nameKey === 'rate_basis') {
      const price = this.state.pricing.fees[feeKey][nameKey]

      const newSchema = rbSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if (price[k] && newSchema[k] && k !== 'rate_basis') {
          newSchema[k] = price[k]
        }
      })
      tmpPricing.fees[feeKey][nameKey] = newSchema
      tmpSelect.fees[feeKey][nameKey] = selection

      this.setState({
        pricing: tmpPricing,
        selectOptions: tmpSelect
      })
    } else {
      tmpPricing.fees[feeKey][nameKey] = selection.value
      tmpSelect.fees[feeKey][nameKey] = selection
      this.setState({
        pricing: tmpPricing,
        selectOptions: tmpSelect
      })
    }
  }
  handleRateChange (event, i, modKey) {
    const { name, value } = event.target
    const { pricing } = this.state
    const nameKeys = name.split('-')
    pricing.rates[modKey][i].rate[nameKeys[1]] = parseFloat(value)

    this.setState({
      pricing
    })
  }
  handleFeeChange (event, feeKey) {
    const { name, value } = event.target
    const { pricing } = this.state
    pricing.fees[feeKey][name] = parseFloat(value)
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

  rateCellEditorGenerator (modKey, i) {
    const { selectOptions, pricing } = this.state
    const fee = pricing.rates[modKey][i]
    const cells = []
    Object.keys(fee.rate).forEach((rateKey) => {
      if (rateKey !== 'currency' && rateKey !== 'rate_basis') {
        cells.push(<div
          key={rateKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[rateKey]}</p>
          <div className={`flex-95 layout-row ${styles.editor_input}`}>
            <input
              type="number"
              value={fee.rate[rateKey].toFixed(2)}
              onChange={e => this.handleRateChange(e, i, modKey)}
              name={`rate-${rateKey}`}
            />
          </div>
        </div>)
      } else if (rateKey === 'rate_basis') {
        cells.push(<div
          className={`flex-25 layout-row layout-align-none-center layout-wrap ${
            styles.price_cell
          }`}
        >
          <p className="flex-100">{chargeGlossary[rateKey]}</p>
          <NamedSelect
            name={`rate-${rateKey}`}
            classes={`${styles.select}`}
            value={selectOptions ? selectOptions.rates[modKey][i][rateKey] : ''}
            options={truckingRateBasises}
            className="flex-100"
            onChange={e => this.handleRateSelect(e, i, modKey)}
          />
        </div>)
      } else if (rateKey === 'currency') {
        cells.push(<div
          key={rateKey}
          className={`flex-25 layout-row layout-align-none-center layout-wrap ${
            styles.price_cell
          }`}
        >
          <p className="flex-100">{chargeGlossary[rateKey]}</p>
          <div className="flex-95 layout-row">
            <NamedSelect
              name="rate-currency"
              classes={`${styles.select}`}
              value={selectOptions ? selectOptions.rates[modKey][i].currency : ''}
              options={currencyOptions}
              className="flex-100"
              onChange={e => this.handleRateSelect(e, i, modKey)}
            />
          </div>
        </div>)
      }
    })

    return (
      <div className={`${styles.cell_editor_wrapper} flex-100 layout-row layout-wrap`}>
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.range_cell}`}
        >
          <div className="flex layout-align-start-center">
            <p className="flex-none no_m">{`${parseInt(fee[`min_${modKey}`], 10)} - ${parseInt(
              fee[`max_${modKey}`],
              10
            )} ${capitalize(modKey)}`}</p>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-space-around-center">{cells}</div>
      </div>
    )
  }
  feeCellEditorGenerator (feeKey) {
    const { selectOptions, pricing } = this.state
    const fee = pricing.fees[feeKey]
    const cells = []
    const dnrKeys = ['currency', 'rate_basis', 'key', 'name']
    Object.keys(fee).forEach((rateKey) => {
      if (dnrKeys.indexOf(rateKey) < 0) {
        cells.push(<div
          key={rateKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[rateKey]}</p>
          <div className={`flex-95 layout-row ${styles.editor_input}`}>
            <input
              type="number"
              value={fee[rateKey].toFixed(2)}
              onChange={e => this.handleFeeChange(e, feeKey)}
              name={`${rateKey}`}
            />
          </div>
        </div>)
      } else if (rateKey === 'rate_basis') {
        cells.push(<div
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[rateKey]}</p>
          <NamedSelect
            name={`${rateKey}`}
            classes={`${styles.select}`}
            value={selectOptions ? selectOptions.fees[feeKey][rateKey] : ''}
            options={truckingRateBasises}
            className="flex-100"
            onChange={e => this.handleFeeSelect(e, feeKey)}
          />
        </div>)
      } else if (rateKey === 'currency') {
        cells.push(<div
          key={rateKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
        >
          <p className="flex-100">{chargeGlossary[rateKey]}</p>
          <div className="flex-95 layout-row">
            <NamedSelect
              name="currency"
              classes={`${styles.select}`}
              value={selectOptions ? selectOptions.fees[feeKey].currency : ''}
              options={currencyOptions}
              className="flex-100"
              onChange={e => this.handleFeeSelect(e, feeKey)}
            />
          </div>
        </div>)
      }
    })

    return (
      <div className={`${styles.cell_editor_wrapper} flex-100 layout-row layout-wrap`}>
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.range_cell}`}
        >
          <div className="flex layout-align-start-center">
            <p className="flex-none no_m">{`${fee.name}`}</p>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-space-around-center">{cells}</div>
      </div>
    )
  }

  render () {
    const { theme, truckingInstance } = this.props
    const { truckingPricing } = truckingInstance
    const { editor } = this.state
    const keyObj = {}
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
      [keyObj.lowerKey, keyObj.upperKey] = truckingInstance.city
    } else if (truckingInstance.distance) {
      [keyObj.lowerKey, keyObj.upperKey] = truckingInstance.distance
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
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

    const pricingsTypes = Object.keys(truckingPricing.rates).map((modKey) => {
      const editable = editor[modKey]
      const pricingTypeCells = truckingPricing.rates[modKey].map((rate, i) =>
        (editable
          ? this.rateCellEditorGenerator(modKey, i)
          : TruckingDisplayPanel.rateCellDisplayGenerator(rate, modKey)))
      const startEdit = (
        <div
          className="flex-15 layout-row layout-align-end-center"
          onClick={() => this.toggleEdit(modKey)}
        >
          <i
            className="fa fa-edit pointy"
            style={{ color: '#BDBDBD' }}
            onFocus=" "
            onMouseOver={{ color: '#4F4F4F' }}
          />
        </div>
      )
      const saveClose = (
        <div className="flex-15 layout-row layout-align-end-center">
          <div
            className="flex-50 layout-row layout-align-end-center"
            onClick={() => this.saveEdit(modKey)}
          >
            <i className="fa fa-check pointy" style={{ color: '#219653' }} />
          </div>
          <div
            className="flex-50 layout-row layout-align-end-center"
            onClick={() => this.toggleEdit(modKey)}
          >
            <i className="fa fa-times pointy" style={{ color: 'red' }} />
          </div>
        </div>
      )

      return truckingPricing.rates[modKey][0] ? (
        <div
          className={`flex-70 layout-row layout-wrap layout-align-start-center ${
            styles.trucking_cell
          }`}
        >
          <div className="flex-100 layout-row layout-wrap">
            <div
              className={`${styles.range_header} flex-100 layout-row layout-align-start-center`}
            >
              {console.log(modKey)}
              <img src={TRUCKING_ICONS[modKey]} alt="Group_5" border="0" />
              <p className="flex no_m">{`${capitalize(modKey)} Ranges`}:</p>
              {editable ? saveClose : startEdit}
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center layout-wrap margin_bottom">
            {pricingTypeCells}
          </div>
        </div>
      ) : ''
    })
    const feeTypes = Object.keys(truckingPricing.fees).map((feeKey) => {
      const editable = editor[feeKey]
      const fee = truckingPricing.fees[feeKey]
      const startEdit = (
        <div
          className="flex-15 layout-row layout-align-end-center"
          onClick={() => this.toggleEdit(feeKey)}
        >
          <i className="fa fa-edit pointy" style={{ color: '#BDBDBD' }} />
        </div>
      )
      const saveClose = (
        <div className="flex-15 layout-row layout-align-end-center">
          <div
            className="flex-50 layout-row layout-align-end-center"
            onClick={() => this.saveEdit(feeKey)}
          >
            <i className="fa fa-check pointy" style={{ color: '#219653' }} />
          </div>
          <div
            className="flex-50 layout-row layout-align-end-center"
            onClick={() => this.toggleEdit(feeKey)}
          >
            <i className="fa fa-times pointy" style={{ color: 'red' }} />
          </div>
        </div>
      )

      return (
        <div
          className={`flex-70 layout-row layout-wrap layout-align-start-center ${
            styles.trucking_cell
          }`}
        >
          <div className="flex-100 layout-row layout-wrap">
            <div
              className={`${styles.range_header} flex-100 layout-row layout-align-start-center`}
            >
              <img src={TRUCKING_ICONS[fee.key.toLowerCase()]} alt="Group_5" border="0" />
              <p className="flex no_m">{`${fee.name} Ranges`}:</p>
              {editable ? saveClose : startEdit}
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center layout-wrap margin_bottom">
            {editable
              ? this.feeCellEditorGenerator(feeKey)
              : TruckingDisplayPanel.feeCellDisplayGenerator(fee)}
          </div>
        </div>
      )
    })

    return (
      <div className="flex-90 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <div className={`flex-100 layout-row layout-align-start-center layout-wrap margin_bottom ${styles.margin_top_align}`}>
            <h4 className="flex-none clip" style={textStyle}>
              {capitalize(modifier)}
            </h4>
            <div className="flex-5" />
            {getTruckingPricingKey(truckingInstance)}
          </div>
          {pricingsTypes}
          {feeTypes}
        </div>
        {styleTagJSX}
      </div>
    )
  }
}
TruckingDisplayPanel.propTypes = {
  theme: PropTypes.theme,
  truckingInstance: PropTypes.objectOf(PropTypes.any).isRequired,
  adminDispatch: PropTypes.func
}
TruckingDisplayPanel.defaultProps = {
  theme: {},
  adminDispatch: null
}
export default TruckingDisplayPanel
