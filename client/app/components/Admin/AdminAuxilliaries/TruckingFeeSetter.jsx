import React, { Component } from 'react'
import PropTypes from 'prop-types'
import {
  rateBasises,
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
      fees: {}
    }
    this.addFee = this.addFee.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
  }
  componentWillMount () {
    this.setAllFromOptions()
  }
  setFees () {
    this.props.setFees(this.state.fees)
  }

  setAllFromOptions () {
    const { fees } = this.state
    const newObj = {}
    const tmpObj = {}
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
          opts = rateBasises.slice()
          // this.getOptions(opts, key, chargeKey);
        }
        newObj[key][chargeKey] = TruckingFeeSetter.selectFromOptions(opts, fees[key][chargeKey])
      })
    })

    this.setState({ selectOptions: newObj })
  }
  addFee (fee) {
    const { fees } = this.state
    const newObj = {}
    const tmpObj = {}
    fees[fee.key] = fee
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
          opts = rateBasises.slice()
          // this.getOptions(opts, key, chargeKey);
        }
        newObj[key][chargeKey] =
          chargeKey === 'currency' || chargeKey === 'rate_basis'
            ? TruckingFeeSetter.selectFromOptions(opts, fees[key][chargeKey])
            : ''
      })
    })

    this.setState({ selectOptions: newObj })
    this.setState({
      selectOptions: newObj,
      fees
    })
  }
  deleteFee (key) {
    const { fees } = this.state
    delete fees[key]
    this.setState({
      fees
    })
  }
  render () {
    const { fees, selectOptions } = this.state
    const { theme } = this.props
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const panel = !isEmpty(fees)
      ? Object.keys(fees).map((key) => {
        const cells = []
        Object.keys(fees[key]).forEach((chargeKey) => {
          if (chargeKey === 'rate_basis') {
            cells.push(<div
              className={`flex layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGlossary[chargeKey]}</p>
              <NamedSelect
                name={`${key}-${chargeKey}`}
                classes={`${styles.select}`}
                value={selectOptions ? selectOptions[key][chargeKey] : ''}
                options={rateBasises}
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
                  name={`${key}-currency`}
                  classes={`${styles.select}`}
                  value={selectOptions ? selectOptions[key].currency : ''}
                  options={currencyOptions}
                  className="flex-100"
                  onChange={this.handleSelect}
                />
              </div>
            </div>)
          }
        })
        return (
          <div key={key} className="flex-100 layout-row layout-align-none-center layout-wrap">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.price_subheader
              }`}
            >
              <p className="flex-none">
                {key} - {fees[key].label}
              </p>
              <div
                className="flex-none layout-row layout-align-center-center"
                onClick={() => this.deleteFee(key)}
              >
                <i className="fa fa-trash clip" style={textStyle} />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">{cells}</div>
          </div>
        )
      })
      : []
    const availableFees = truckingFees.map(tfk => (
      <div
        className="flex-33 layout-row layout-align-center-center"
        onClick={() => this.addFee(tfk)}
      >
        <p className="flex-none ">{tfk.label}</p>
      </div>
    ))
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">{panel}</div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          {availableFees}
        </div>
        <div className="flex-33 layout-row layout-align-center-center">
          <RoundButton
            theme={theme}
            size="small"
            text="Save Fees"
            iconClass="fa-plus-square-o"
            handleNext={this.setFees}
          />
        </div>
      </div>
    )
  }
}

TruckingFeeSetter.propTypes = {
  theme: PropTypes.theme,
  setFees: PropTypes.func.isRequired
}
TruckingFeeSetter.defaultProps = {
  theme: {}
}
export default TruckingFeeSetter
