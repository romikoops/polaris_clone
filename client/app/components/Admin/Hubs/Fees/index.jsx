import React, { Component } from 'react'
import PropTypes from 'prop-types'
import '../../../../styles/day-picker-custom.css'
import styles from '../../Admin.scss'
import styles2 from './index.scss'
import {
  currencyOptions,
  cargoClassOptions
} from '../../../../constants/admin.constants'
import {
  rateBasises,
  lclPricingSchema,
  fclPricingSchema,
  rateBasisSchema,
  moment
} from '../../../../constants'
import { gradientGenerator } from '../../../../helpers'
import FeeRow from './FeeRow'

const rateOpts = rateBasises
const currencyOpts = currencyOptions

export class AdminHubFees extends Component {
  static selectFromOptions (options, value) {
    if (!value) {
      return options[0]
    }
    let result
    options.forEach((op) => {
      if (op.value === value) {
        result = op
      }
    })

    return result || options[0]
  }
  static prepForSelect (arr, labelKey, valueKey, glossary) {
    return arr.map(a => ({
      value: valueKey ? a[valueKey] : a,
      label: glossary ? glossary[a[labelKey]] : a[labelKey]
    }))
  }
  constructor (props) {
    super(props)
    this.state = {
      selectOptions: {
        customs: {},
        charges: {}
      },
      editor: {
        charges: {
          import: {},
          export: {}
        },
        customs: {
          import: {},
          export: {}
        }
      },
      edit: false,
      direction: 'import',
      selectedCargoClass: 'lcl'
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
    this.handleTopLevelSelect = this.handleTopLevelSelect.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.showAddFeePanel = this.showAddFeePanel.bind(this)
    this.addFeeToPricing = this.addFeeToPricing.bind(this)
  }
  componentWillMount () {
    // this.setAllFromOptions()
  }
  componentWillReceiveProps (nextProps) {
    const { direction, selectedCargoClass } = this.state
    if (nextProps.charges[0].hub_id) {
      this.setAllFromOptions(nextProps.charges
        .filter(c => c.direction === direction && c.load_type === selectedCargoClass)[0], 'charges')
      this.setAllFromOptions(nextProps.customs
        .filter(c => c.direction === direction && c.load_type === selectedCargoClass)[0], 'customs')
    }
    if (this.state.charges !== nextProps.charges || this.state.customs !== nextProps.customs) {
      this.setState({
        charges: nextProps.charges,
        customs: nextProps.customs
      })
    }
  }

  setCargoClass (type) {
    this.setState({ selectedCargoClass: type }, () => { this.prepAllOptions() })
  }

  setAllFromOptions (charges, target) {
    const newObj = { import: {}, export: {} }
    const tmpObj = {}
    if (!charges.fees) {
      return
    }
    Object.keys(charges.fees).forEach((key) => {
      if (!newObj[charges.direction][key]) {
        newObj[charges.direction][key] = {}
      }
      if (!tmpObj[key]) {
        tmpObj[key] = {}
      }
      let opts
      Object.keys(charges.fees[key]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          newObj[charges.direction][key][chargeKey] = AdminHubFees.selectFromOptions(
            opts,
            charges.fees[key][chargeKey]
          )
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          newObj[charges.direction][key][chargeKey] = AdminHubFees.selectFromOptions(
            opts,
            charges.fees[key][chargeKey]
          )
        }
      })
    })

    this.setState(prevState => (
      {
        editor: {
          ...prevState.editor,
          [target]: {
            ...prevState.editor[target],
            [charges.direction]: charges
          }
        },
        selectOptions: {
          ...prevState.selectOptions,
          [target]: {
            ...prevState.selectOptions[target],
            [charges.load_type]: {
              ...prevState.selectOptions[charges.load_type],
              ...newObj
            }
          }
        }
      }
    ))
  }
  prepAllOptions () {
    const {
      direction, selectedCargoClass, charges, customs
    } = this.state
    this.setAllFromOptions(charges
      .filter(c => c.direction === direction && c.load_type === selectedCargoClass)[0], 'charges')
    this.setAllFromOptions(customs
      .filter(c => c.direction === direction && c.load_type === selectedCargoClass)[0], 'customs')
  }

  handleTopLevelSelect (selection) {
    this.setState({
      [selection.name]: selection,
      steps: {
        ...this.state.steps,
        [selection.name]: true
      }
    })
  }
  handleDayChange (e, direction, key, chargeKey, target) {
    console.log(e, direction, key, chargeKey)
    this.setState({
      editor: {
        ...this.state.editor,
        [target]: {
          ...this.state.editor[target],
          [direction]: {
            ...this.state.editor[target][direction],
            fees: {
              ...this.state.editor[target][direction].fees,
              [key]: {
                ...this.state.editor[target][direction].fees[key],
                [chargeKey]: moment(e).format('YYYY/MM/DD')
              }
            }
          }
        }
      }
    })
  }

  handleSelect (selection, target) {
    const { direction } = this.state
    const nameKeys = selection.name.split('-')
    if (nameKeys[2] === 'rate_basis') {
      const price = this.state.charge[nameKeys[0]][nameKeys[1]]
      const newSchema = rateBasisSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if (price[k] && newSchema[k] && k !== 'rate_basis') {
          newSchema[k] = price[k]
        }
      })
      this.setState({
        editor: {
          ...this.state.editor,
          [target]: {
            ...this.state.editor[target],
            [direction]: {
              ...this.state.editor[target][direction],
              fees: {
                ...this.state.editor[target][direction].fees,
                [nameKeys[1]]: newSchema
              }
            }
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          [target]: {
            ...this.state.selectOptions[target],
            [nameKeys[0]]: {
              ...this.state.selectOptions[target][nameKeys[0]],
              [nameKeys[1]]: {
                ...this.state.selectOptions[target][nameKeys[0]][nameKeys[1]],
                [nameKeys[2]]: selection
              }
            }
          }
        }
      })
    } else {
      this.setState({
        editor: {
          ...this.state.editor,
          [target]: {
            ...this.state.editor[target],
            [nameKeys[0]]: {
              ...this.state.editor[target][nameKeys[0]],
              fees: {
                ...this.state.editor[target][nameKeys[0]].fees,
                [nameKeys[1]]: {
                  ...this.state.editor[target][nameKeys[0]].fees[nameKeys[1]],
                  [nameKeys[2]]: parseInt(selection.value, 10)
                }
              }
            }
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          [target]: {
            ...this.state.selectOptions[target],
            [nameKeys[0]]: {
              ...this.state.selectOptions[target][nameKeys[0]],
              [nameKeys[1]]: {
                ...this.state.selectOptions[target][nameKeys[0]][nameKeys[1]],
                [nameKeys[2]]: selection
              }
            }
          }
        }
      })
    }
  }
  showAddFeePanel () {
    this.setState({ showPanel: !this.state.showPanel })
  }
  deleteFee (key) {
    const { charges } = this.state
    delete charges[key]
    this.setState({ charges })
  }
  handleChange (event, target) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    this.setState({
      editor: {
        ...this.state.editor,
        [target]: {
          ...this.state.editor[target],
          [nameKeys[0]]: {
            ...this.state.editor[target][nameKeys[0]],
            fees: {
              ...this.state.editor[target][nameKeys[0]].fees,
              [nameKeys[1]]: {
                ...this.state.editor[target][nameKeys[0]].fees[nameKeys[1]],
                [nameKeys[2]]: parseInt(value, 10)
              }
            }
          }
        }
      }
    })
  }
  toggleEdit () {
    this.setState({ edit: !this.state.edit })
  }
  addFeeToPricing (key) {
    const { charges, direction, selectOptions } = this.state
    if (charges.load_type === 'lcl') {
      charges[direction][key] = lclPricingSchema.data[key]
    } else {
      charges[direction][key] = fclPricingSchema.data[key]
    }

    const newObj = Object.assign({}, selectOptions)
    const tmpObj = {}

    Object.keys(charges[direction]).forEach((oKey) => {
      if (!newObj[direction][oKey]) {
        newObj[direction][oKey] = {}
      }
      if (!tmpObj[oKey]) {
        tmpObj[oKey] = {}
      }
      let opts
      Object.keys(charges[direction][oKey]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          // this.getOptions(opts, key, chargeKey);
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          // this.getOptions(opts, key, chargeKey);
        }
        newObj[direction][oKey][chargeKey] = AdminHubFees.selectFromOptions(
          opts,
          charges[direction][oKey][chargeKey]
        )
      })
    })
    this.setState({ selectOptions: newObj, charges })
  }

  saveEdit (target) {
    const { editor, direction } = this.state
    // debugger // eslint-disable-line
    const charges = editor[target][direction]
    if (target === 'charges') {
      this.props.adminDispatch.editLocalCharges(charges)
    } else {
      this.props.adminDispatch.editCustomsFees(charges)
    }
  }
  handleDirectionChange (e) {
    const { directionBool } = this.state
    if (!directionBool) {
      this.setState({
        direction: 'export',
        directionBool: true
      })
    } else {
      this.setState({
        direction: 'import',
        directionBool: false
      })
    }
  }
  renderCargoClassButtons () {
    const { selectedCargoClass, charges } = this.state
    const { theme } = this.props
    const { primary, secondary } = theme.colors
    const bgStyle = gradientGenerator(primary, secondary)

    return cargoClassOptions.map((cargoClass, i) => {
      const hasCargoClass = charges
        .filter(charge => charge.load_type === cargoClass.value).length > 0
      const buttonStyle = selectedCargoClass === cargoClass.value ? bgStyle : { background: '#E0E0E0' }
      const innerStyle = selectedCargoClass === cargoClass.value ? styles2.cargo_class_button_selected : ''
      const inactiveStyle = hasCargoClass ? '' : styles2.cargo_class_button_inactive

      return (<div
        className={`flex-25 layout-row layout-align-start-center ${inactiveStyle} ${styles2.cargo_class_button}`}
        style={buttonStyle}
        onClick={hasCargoClass ? () => this.setCargoClass(cargoClass.value) : null}
      >
        <div className={`flex-none layout-row layout-align-center-center ${innerStyle} ${styles2.cargo_class_button_inner}`}>
          <p className="flex-none">{cargoClass.label}</p>
        </div>
        { i !== cargoClassOptions.length - 1 ? <div className={`flex-none ${styles2.cargo_class_divider}`} /> : ''}
      </div>)
    })
  }

  render () {
    const { theme } = this.props

    const {
      selectOptions,

      direction,
      directionBool,
      charges,
      selectedCargoClass,
      customs
    } = this.state
    const { primary, secondary } = theme.colors
    const bgStyle = gradientGenerator(primary, secondary)

    if (!charges || (charges && !charges[0])) {
      return ''
    }
    const impStyle = directionBool ? styles2.toggle_off : styles2.toggle_on
    const expStyle = directionBool ? styles2.toggle_on : styles2.toggle_off
    const currentCharge = charges.filter(charge => charge.load_type === selectedCargoClass && charge.direction === direction)[0]
    const currentCustoms = customs.filter(custom => custom.load_type === selectedCargoClass && custom.direction === direction)[0]
    const editCharge = this.state.editor.charges[direction]
    const editCustoms = this.state.editor.customs[direction]
    const feeRows = Object.keys(currentCharge.fees).map((ck) => {
      const fee = currentCharge.fees[ck]

      return (<FeeRow
        className="flex-100"
        theme={theme}
        fee={fee}
        selectOptions={selectOptions.charges[currentCharge.load_type]}
        direction={direction}
        editCharge={editCharge}
        handleDateEdit={this.handleDayChange}
        handleSelect={this.handleSelect}
        handleChange={this.handleChange}
        saveEdit={e => this.saveEdit(e)}
        target="charges"
      />)
    })
    const customsRows = Object.keys(currentCustoms.fees).map((ck) => {
      const fee = currentCustoms.fees[ck]

      return (<FeeRow
        className="flex-100"
        theme={theme}
        fee={fee}
        editCharge={editCustoms}
        selectOptions={selectOptions.customs[currentCustoms.load_type]}
        direction={direction}
        handleDateEdit={this.handleDayChange}
        handleSelect={this.handleSelect}
        handleChange={this.handleChange}
        saveEdit={e => this.saveEdit(e)}
        target="customs"
      />)
    })

    return (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles2.container}`}>
        <div className={`flex-100 layout-row layout-align-space-between-center ${styles2.header_bar_grey}`}>
          <div className="flex-30 layout-row layout-align-start-center">
            <p className={`flex-none ${styles2.text}`} >Fees & Charges</p>
          </div>
          <div className="flex-30 layout-row layout-align-end-center">
            <div
              className={`flex-none layout-row layout-align-center-center ${styles2.toggle} ${impStyle}`}
              style={bgStyle}
              onClick={() => this.handleDirectionChange()}
            >
              <p className="flex-none">Import</p>
            </div>
            <div
              className={`flex-none layout-row layout-align-center-center ${styles2.toggle} ${expStyle}`}
              style={bgStyle}
              onClick={() => this.handleDirectionChange()}
            >
              <p className="flex-none">Export</p>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className={`flex-100 layout-row ${styles.cargo_class_row}`}>
            {this.renderCargoClassButtons()}
          </div>
          <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.fee_row_container}`}>
            {feeRows}
          </div>
          <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.header_bar_grey}`}>
            <div className="flex-30 layout-row layout-align-start-center">
              <p className={`flex-none ${styles2.text}`} >Customs</p>
            </div>
          </div>
          <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.fee_row_container}`}>
            {customsRows}
          </div>
        </div>
      </div>
    )
  }
}
AdminHubFees.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  charges: PropTypes.arrayOf(PropTypes.any),
  customs: PropTypes.arrayOf(PropTypes.any)
}
AdminHubFees.defaultProps = {
  theme: {},
  charges: [],
  customs: []
}

export default AdminHubFees
