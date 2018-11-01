import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import {
  truckingRateBasises,
  truckingFees,
  currencyOptions,
  chargeGlossary
  // cargoGlossary
} from '../../../constants'
import styles from '../Admin.scss'
import { NamedSelect } from '../../NamedSelect/NamedSelect'
import { RoundButton } from '../../RoundButton/RoundButton'
import { gradientTextGenerator, isEmpty } from '../../../helpers'

export class TruckingFeeSetter extends Component {
  static selectFromOptions (options, value) {
    let result
    console.log(options)
    options.forEach((op) => {
      if (op.value === value) {
        result = op
      }
    })

    return result || options[0]
  }
  constructor (props) {
    super(props)
    this.state = {
      globalFees: {},
      variableFees: {
        base_rate: {
          value: 0,
          currency: 'EUR',
          rate_basis: 'PER_X_KG',
          base: 10
        }
      }
    }
    this.setFees = this.setFees.bind(this)
    this.addFee = this.addFee.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
    this.handleBaseChange = this.handleBaseChange.bind(this)
    this.handleCurrencyChange = this.handleCurrencyChange.bind(this)
  }
  componentWillMount () {
    this.setAllFromOptions()
  }
  setFees () {
    const { variableFees, globalFees } = this.state
    this.props.setFees({
      variableFees,
      globalFees
    })
  }

  setAllFromOptions () {
    const { variableFees, globalFees } = this.state
    const newObj = {}
    const tmpObj = {}
    const feeArr = [
      { key: 'variableFees', fees: variableFees },
      { key: 'globalFees', fees: globalFees }
    ]
    feeArr.forEach((feeObj) => {
      Object.keys(feeObj.fees).forEach((key) => {
        if (!newObj[key]) {
          newObj[key] = {}
        }
        if (!tmpObj[key]) {
          tmpObj[key] = {}
        }
        let opts
        Object.keys(feeObj.fees[key]).forEach((chargeKey) => {
          if (chargeKey === 'currency') {
            opts = currencyOptions.slice()
            newObj[key][chargeKey] = TruckingFeeSetter.selectFromOptions(
              opts,
              feeObj.fees[key][chargeKey]
            )
          } else if (chargeKey === 'rate_basis') {
            opts = truckingRateBasises.slice()
            newObj[key][chargeKey] = TruckingFeeSetter.selectFromOptions(
              opts,
              feeObj.fees[key][chargeKey]
            )
          }
        })
      })
    })

    this.setState({ selectOptions: newObj })
  }
  handleCurrencyChange (event) {
    const nameKeys = event.name.split('-')
    const tempFee = {
      ...this.state[nameKeys[0]][nameKeys[1]],
      [nameKeys[2]]: event.value
    }

    this.setState({
      selectOptions: {
        ...this.state.selectOptions,
        [nameKeys[1]]: {
          ...this.state.selectOptions[nameKeys[1]],
          [nameKeys[2]]: event
        }
      },
      [nameKeys[0]]: {
        ...this.state[nameKeys[0]],
        [nameKeys[1]]: tempFee
      }
    })
  }
  handleSelect (event) {
    const nameKeys = event.name.split('-')
    const { value, currency } = this.state[nameKeys[0]][nameKeys[1]]
    const tempFee = {
      currency,
      value,
      [nameKeys[2]]: event.value
    }
    if (event.value === 'PER_CBM_TON') {
      tempFee.cbm = 0
      tempFee.ton = 0
    }
    if (event.value === 'PER_CBM_KG') {
      tempFee.cbm = 0
      tempFee.kg = 0
    }
    if (event.value.includes('_X_')) {
      tempFee.base = 0
    }

    this.setState({
      selectOptions: {
        ...this.state.selectOptions,
        [nameKeys[1]]: {
          ...this.state.selectOptions[nameKeys[1]],
          [nameKeys[2]]: event
        }
      },
      [nameKeys[0]]: {
        ...this.state[nameKeys[0]],
        [nameKeys[1]]: tempFee
      }
    })
  }
  handleBaseChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    this.setState({
      [nameKeys[0]]: {
        ...this.state[nameKeys[0]],
        [nameKeys[1]]: {
          ...this.state[nameKeys[0]][nameKeys[1]],
          [nameKeys[2]]: value
        }
      }
    })
  }
  addFee (fee, global) {
    const { variableFees, globalFees } = this.state
    const newObj = {}
    const tmpObj = {}
    const fees = global ? globalFees : variableFees
    fees[fee.key] = fee
    if (fee.rate_basis === 'PER_CBM_TON') {
      fees[fee.key].cbm = 0
      fees[fee.key].ton = 0
    }
    if (fee.rate_basis === 'PER_CBM_KG') {
      fees[fee.key].cbm = 0
      fees[fee.key].kg = 0
    }
    const keyArr = Object.keys(fees)
    keyArr.forEach((key) => {
      if (!newObj[key]) {
        newObj[key] = {}
      }
      if (!tmpObj[key]) {
        tmpObj[key] = {}
      }
      let opts
      Object.keys(fees[key]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOptions.slice()
          // this.getOptions(opts, key, chargeKey);
        } else if (chargeKey === 'rate_basis') {
          opts = truckingRateBasises.slice()
          // this.getOptions(opts, key, chargeKey);
        }
        newObj[key][chargeKey] =
          chargeKey === 'currency' || chargeKey === 'rate_basis'
            ? TruckingFeeSetter.selectFromOptions(opts, fees[key][chargeKey])
            : ''
      })
    })
    if (global) {
      this.setState({
        selectOptions: {
          ...this.state.selectOptions,
          ...newObj
        },
        globalFees: fees
      })
    } else {
      this.setState({
        selectOptions: {
          ...this.state.selectOptions,
          ...newObj
        },
        variableFees: fees
      })
    }
  }
  deleteFee (key, global) {
    const { variableFees, globalFees } = this.state
    const fees = global ? globalFees : variableFees
    delete fees[key]
    if (global) {
      this.setState({
        globalFees: fees
      })
    } else {
      this.setState({
        variableFees: fees
      })
    }
  }
  render () {
    const { variableFees, globalFees, selectOptions } = this.state
    const { theme, t } = this.props
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const globalPanel = !isEmpty(globalFees)
      ? Object.keys(globalFees).map((key) => {
        const cells = []
        Object.keys(globalFees[key]).forEach((chargeKey) => {
          if (chargeKey === 'rate_basis') {
            cells.push(<div
              className={`flex layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGlossary[chargeKey]}</p>
              <NamedSelect
                name={`globalFees-${key}-${chargeKey}`}
                classes={`${styles.select}`}
                value={selectOptions ? selectOptions[key][chargeKey] : ''}
                options={truckingRateBasises}
                className="flex-100"
                onChange={this.handleSelect}
              />
            </div>)
          } else if (chargeKey === 'currency') {
            cells.push(<div
              key={chargeKey}
              className={`flex layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGlossary[chargeKey]}</p>
              <div className="flex-95 layout-row">
                <NamedSelect
                  name={`globalFees-${key}-currency`}
                  classes={`${styles.select}`}
                  value={selectOptions ? selectOptions[key].currency : ''}
                  options={currencyOptions}
                  className="flex-100"
                  onChange={this.handleCurrencyChange}
                />
              </div>
            </div>)
          }
        })

        return (
          <div
            key={key}
            className={`flex-50 layout-row layout-align-none-center layout-wrap ${
              styles.price_cell_row
            }`}
          >
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.price_subheader
              }`}
            >
              <p className="flex-none">{chargeGlossary[key]}</p>
              <div
                className="flex-none layout-row layout-align-center-center"
                onClick={() => this.deleteFee(key, true)}
              >
                <i className="fa fa-trash clip" style={textStyle} />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">{cells}</div>
          </div>
        )
      })
      : []
    const variablePanel = !isEmpty(variableFees)
      ? Object.keys(variableFees).map((key) => {
        const cells = []
        Object.keys(variableFees[key]).forEach((chargeKey) => {
          if (chargeKey === 'rate_basis') {
            cells.push(<div
              className={`flex layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGlossary[chargeKey]}</p>
              <NamedSelect
                name={`variableFees-${key}-${chargeKey}`}
                classes={`${styles.select}`}
                value={selectOptions ? selectOptions[key][chargeKey] : ''}
                options={truckingRateBasises}
                className="flex-100"
                onChange={this.handleSelect}
              />
            </div>)
          } else if (chargeKey === 'currency') {
            cells.push(<div
              key={chargeKey}
              className={`flex layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGlossary[chargeKey]}</p>
              <div className="flex-95 layout-row">
                <NamedSelect
                  name={`variableFees-${key}-currency`}
                  classes={`${styles.select}`}
                  value={selectOptions ? selectOptions[key].currency : ''}
                  options={currencyOptions}
                  className="flex-100"
                  onChange={this.handleCurrencyChange}
                />
              </div>
            </div>)
          } else if (chargeKey === 'base' && variableFees[key].rate_basis.includes('_X_')) {
            cells.push(<div
              key={chargeKey}
              className={`flex layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGlossary[chargeKey]}</p>
              <div className="flex-95 layout-row input_box_full">
                <input
                  type="number"
                  value={variableFees[key].base}
                  onChange={this.handleBaseChange}
                  name={`variableFees-${key}-base`}
                />
              </div>
            </div>)
          }
        })

        return (
          <div
            key={key}
            className={`flex-50 layout-row layout-align-none-center layout-wrap ${
              styles.price_cell_row
            }`}
          >
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.price_subheader
              }`}
            >
              <p className="flex-none">{chargeGlossary[key]}</p>
              <div
                className="flex-none layout-row layout-align-center-center"
                onClick={() => this.deleteFee(key, false)}
              >
                <i className="fa fa-trash clip" style={textStyle} />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">{cells}</div>
          </div>
        )
      })
      : []
    const availableFees = truckingFees.map((tfk) => {
      if (globalFees[tfk.key] || variableFees[tfk.key]) {
        return ''
      }

      return (
        <div
          className={`flex-none layout-row layout-align-center-center layout-wrap ${
            styles.add_price_cell
          }`}
        >
          <div className="flex-100 layout-row layout-align-center-center">
            <p className="flex-none letter_3 clip" style={textStyle}>
              {tfk.label}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-center-center">
            <div className="flex-50 layout-row layout-align-center-center">
              <div
                className={`flex-none layout-row layout-align-center-center pointy ${
                  styles.add_price_button
                }`}
                onClick={() => this.addFee(tfk, true)}
              >
                <p className="flex-none ">{t('admin:addGlobal')}</p>
              </div>
            </div>
            <div className="flex-50 layout-row layout-align-center-center">
              <div
                className={`flex-none layout-row layout-align-center-center pointy ${
                  styles.add_price_button
                }`}
                onClick={() => this.addFee(tfk, false)}
              >
                <p className="flex-none ">{t('admin:addVariable')}</p>
              </div>
            </div>
          </div>
        </div>
      )
    })

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-space-between">
          {availableFees}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">
            <p className="flex-none">{t('admin:globalFees')}</p>
          </div>
          {globalPanel}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">
            <p className="flex-none">{t('admin:variableFees')}</p>
          </div>
          {variablePanel}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-end-center button_padding">
          <div className="flex-33 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              text={t('admin:saveFees')}
              iconClass="fa-plus-square-o"
              handleNext={this.setFees}
            />
          </div>
        </div>
      </div>
    )
  }
}

TruckingFeeSetter.propTypes = {
  theme: PropTypes.theme,
  setFees: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired
}
TruckingFeeSetter.defaultProps = {
  theme: {}
}
export default withNamespaces('admin')(TruckingFeeSetter)
