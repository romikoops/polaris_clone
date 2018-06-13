import React, { Component } from 'react'
import PropTypes from 'prop-types'
// import Toggle from 'react-toggle'
// import DayPickerInput from 'react-day-picker/DayPickerInput'
import '../../../../styles/day-picker-custom.css'
import styles from '../../Admin.scss'
import styles2 from './index.scss'
// import { NamedSelect } from '../../../NamedSelect/NamedSelect'
// import { RoundButton } from '../../../RoundButton/RoundButton'
// import AdminPromptConfirm from '../../Prompt/Confirm'
import {
  currencyOptions,
  cargoClassOptions
} from '../../../../constants/admin.constants'
import {
  chargeGlossary,
  rateBasises,
  lclPricingSchema,
  fclPricingSchema,
  // cargoGlossary,
  rateBasisSchema,
  moment
} from '../../../../constants'
// import { TextHeading } from '../../../TextHeading/TextHeading'
import { gradientGenerator } from '../../../../helpers'
import FeeRow from './FeeRow'

const chargeGloss = chargeGlossary
const rateOpts = rateBasises
const currencyOpts = currencyOptions
// const cargoClassOpts = cargoClassOptions
// const lclSchema = lclPricingSchema
// const fclSchema = fclPricingSchema
// const cargoGloss = cargoGlossary

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
      selectOptions: {},
      edit: false,
      direction: 'import',
      selectedCargoClass: 'lcl'
    }
    // this.editPricing = lclSchema
    this.handleChange = this.handleChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
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
    if (nextProps.charges[0].hub_id) {
      this.setAllFromOptions(nextProps.charges[0])
      this.setAllFromOptions(nextProps.customs[0])
    }
    if (this.state.charges !== nextProps.charges || this.state.customs !== nextProps.customs) {
      this.setState({
        charges: nextProps.charges,
        customs: nextProps.customs
      })
    }
  }
  setCargoClass (type) {
    this.setState({ selectedCargoClass: type })
  }

  setAllFromOptions (charges) {
    const newObj = { import: {}, export: {} }
    const tmpObj = {}
    const directions = ['import', 'export']
    directions.forEach((dir) => {
      Object.keys(charges[dir]).forEach((key) => {
        if (!newObj[dir][key]) {
          newObj[dir][key] = {}
        }
        if (!tmpObj[key]) {
          tmpObj[key] = {}
        }
        let opts
        Object.keys(charges[dir][key]).forEach((chargeKey) => {
          if (chargeKey === 'currency') {
            opts = currencyOpts.slice()
            newObj[dir][key][chargeKey] = AdminHubFees.selectFromOptions(
              opts,
              charges[dir][key][chargeKey]
            )
          } else if (chargeKey === 'rate_basis') {
            opts = rateOpts.slice()
            newObj[dir][key][chargeKey] = AdminHubFees.selectFromOptions(
              opts,
              charges[dir][key][chargeKey]
            )
          }
        })
      })
    })

    this.setState({
      selectOptions: {
        ...this.state.selectOptions,
        [charges.load_type]: newObj
      }
    })
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
  handleDayChange (e, direction, key, chargeKey) {
    console.log(e, direction, key, chargeKey)
    this.setState({
      charge: {
        ...this.state.charge,
        [direction]: {
          ...this.state.charge[direction],
          [key]: {
            ...this.state.charge[direction][key],
            [chargeKey]: moment(e).format('YYYY/MM/DD')
          }
        }
      }
    })
  }

  handleSelect (selection) {
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
        charge: {
          ...this.state.charge,
          [nameKeys[0]]: {
            ...this.state.charge[nameKeys[0]],
            [nameKeys[1]]: newSchema
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          [nameKeys[0]]: {
            ...this.state.selectOptions[direction],
            [nameKeys[1]]: {
              ...this.state.selectOptions[nameKeys[0]][nameKeys[1]],
              [nameKeys[2]]: selection
            }
          }
        }
      })
    } else {
      this.setState({
        charge: {
          ...this.state.charge,
          [nameKeys[0]]: {
            ...this.state.charge[nameKeys[0]],
            [nameKeys[1]]: {
              ...this.state.charge[nameKeys[0]][nameKeys[2]],
              [nameKeys[2]]: parseInt(selection.value, 10)
            }
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          [nameKeys[0]]: {
            ...this.state.selectOptions[nameKeys[0]],
            [nameKeys[1]]: {
              ...this.state.selectOptions[nameKeys[0]][nameKeys[1]],
              [nameKeys[2]]: selection
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
  handleChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    this.setState({
      charges: {
        ...this.state.charges,
        [nameKeys[0]]: {
          ...this.state.charges[nameKeys[0]],
          [nameKeys[1]]: {
            ...this.state.charges[nameKeys[0]][nameKeys[1]],
            [nameKeys[2]]: parseInt(value, 10)
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

  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }

  saveEdit () {
    const { charges } = this.state
    this.props.adminDispatch.editLocalCharges(charges.nexus_id, charges)
    this.closeConfirm()
    this.toggleEdit()
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

    // const textStyle = {
    //   background:
    //     theme && theme.colors
    //       ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
    //       : 'black'
    // }
    const {
      selectOptions,
      // edit,
      // showPanel,
      direction,
      directionBool,
      charges,
      // confirm,
      selectedCargoClass,
      customs
    } = this.state
    // let gloss
    const { primary, secondary } = theme.colors
    const bgStyle = gradientGenerator(primary, secondary)

    if (!charges || (charges && !charges[0])) {
      return ''
    }
    // const confimPrompt = confirm ? (
    //   <AdminPromptConfirm
    //     theme={theme}
    //     heading="Are you sure?"
    //     text="These changes will be instantly available in your store"
    //     confirm={() => this.saveEdit()}
    //     deny={() => this.closeConfirm()}
    //   />
    // ) : (
    //   ''
    // )

    // const feeSchema = loadType === 'lcl' ? lclPricingSchema : fclPricingSchema
    // const feesToAdd = Object.keys(feeSchema.data).map((key) => {
    //   if (!charges[key]) {
    //     return (
    //       <div
    //         key={key}
    //         className="flex-33 layout-row layout-align-start-center"
    //         onClick={() => this.addFeeToPricing(key)}
    //       >
    //         <i className="fa fa-plus clip flex-none" style={textStyle} />
    //         <div className="flex-5" />
    //         <p className="flex-none">
    //           {key} - {gloss[key]}{' '}
    //         </p>
    //       </div>
    //     )
    //   }
    //   return ''
    // })
    // const panelViewClass = showPanel ? styles.hub_fee_panel_open : styles.hub_fee_panel_closed
    const impStyle = directionBool ? styles2.toggle_off : styles2.toggle_on
    const expStyle = directionBool ? styles2.toggle_on : styles2.toggle_off
    const currentCharge = charges.filter(charge => charge.load_type === selectedCargoClass)[0]
    const currentCustoms = customs.filter(custom => custom.load_type === selectedCargoClass)[0]
    const feeRows = Object.keys(currentCharge[direction]).map((ck) => {
      const fee = currentCharge[direction][ck]
      return (<FeeRow
        className="flex-100"
        theme={theme}
        fee={fee}
        selectOptions={selectOptions[currentCharge.load_type]}
        direction={direction}
      />)
    })
    const customsRows = Object.keys(currentCustoms[direction]).map((ck) => {
      const fee = currentCustoms[direction][ck]
      return (<FeeRow
        className="flex-100"
        theme={theme}
        fee={fee}
        selectOptions={selectOptions[currentCustoms.load_type]}
        direction={direction}
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
