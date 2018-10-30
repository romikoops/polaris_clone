import React, { Component } from 'react'
import PropTypes from 'prop-types'
import '../../../styles/day-picker-custom.scss'
import styles from '../Admin.scss'
import styles2 from './index.scss'
import {
  currencyOptions,
  cargoClassOptions
} from '../../../constants/admin.constants'
import {
  rateBasises,
  lclPricingSchema,
  fclPricingSchema,
  rateBasisSchema,
  moment,
  chargeGlossary
} from '../../../constants'
import { gradientGenerator } from '../../../helpers'
import PricingRow from './Row'
import PricingRangeRow from './RangeRow'
import { NamedSelect } from '../../NamedSelect/NamedSelect'

const rateOpts = rateBasises
const currencyOpts = currencyOptions

export class AdminPricingBox extends Component {
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
      editor: {},
      charges: props.charges,
      edit: false,
      direction: 'import',
      selectedServiceLevel: false,
      selectedCargoClass: ''
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
    this.handleServiceLevelChange = this.handleServiceLevelChange.bind(this)
    this.handleTopLevelSelect = this.handleTopLevelSelect.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.showAddFeePanel = this.showAddFeePanel.bind(this)
    this.addFeeToPricing = this.addFeeToPricing.bind(this)
    this.handleRangeChange = this.handleRangeChange.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.charges[0]) {
      nextProps.charges.forEach((charge) => {
        this.setAllFromOptions(charge.pricing, 'charges', charge.transport_category.cargo_class)
      })
    }
    if (this.state.charges !== nextProps.charges && nextProps.charges.length > 0) {
      this.setState({
        charges: nextProps.charges
      })
    }
    if (!this.state.editor.id && nextProps.charges.length > 0) {
      const charge = nextProps.charges[0]
      const serviceLevel = nextProps.serviceLevels
        .filter(sl => sl.value === charge.transport_category.vehicle_id)[0]
      this.setState({
        editor: charge.pricing,
        selectedServiceLevel: serviceLevel,
        selectedCargoClass: charge.transport_category.cargo_class
      })
    }
  }

  setCargoClass (type) {
    this.setState({ selectedCargoClass: type }, () => { this.prepAllOptions() })
  }

  setAllFromOptions (pricing, target, loadType) {
    const newObj = { }
    const tmpObj = {}

    if (!pricing.data) {
      return
    }
    Object.keys(pricing.data).forEach((key) => {
      if (!newObj[key]) {
        newObj[key] = {}
      }
      if (!tmpObj[key]) {
        tmpObj[key] = {}
      }
      let opts
      Object.keys(pricing.data[key]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          newObj[key][chargeKey] = AdminPricingBox.selectFromOptions(
            opts,
            pricing.data[key][chargeKey]
          )
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          newObj[key][chargeKey] = AdminPricingBox.selectFromOptions(
            opts,
            pricing.data[key][chargeKey]
          )
        }
      })
    })

    this.setState(prevState => (
      {
        selectOptions: {
          ...prevState.selectOptions,
          [target]: {
            ...prevState.selectOptions[target],
            [loadType]: {
              ...prevState.selectOptions[loadType],
              ...newObj
            }
          }
        }
      }
    ))
  }
  prepAllOptions () {
    const {
      selectedCargoClass, charges, selectedServiceLevel
    } = this.state
    const charge = charges
      .filter(c => (c.transport_category.cargo_class === selectedCargoClass) &&
       (c.transport_category.vehicle_id === selectedServiceLevel.value ||
         !selectedServiceLevel))[0]

    this.setAllFromOptions(charge.pricing, 'charges', charge.transport_category.cargo_class)
  }
  isEditing () {
    this.setState({ isEditing: !this.state.isEditing })
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
  handleDayChange (e, target) {
    this.setState({
      editor: {
        ...this.state.editor,
        data: {
          ...this.state.editor.data,
          [target]: moment(e).format('YYYY/MM/DD')
        }
      }
    })
  }

  handleSelect (selection) {
    const nameKeys = selection.name.split('-')
    if (nameKeys[2] === 'rate_basis') {
      const price = this.state.editor.data[nameKeys[1]]
      const newSchema = rateBasisSchema[selection.value] || {}
      Object.keys(newSchema).forEach((k) => {
        if ((price[k] && newSchema[k] && k !== 'rate_basis') || k === 'effective_date' || k === 'expiration_date') {
          newSchema[k] = price[k]
        }
      })
      if (price.range) {
        newSchema.range = price.range
      }
      this.setState({
        editor: {
          ...this.state.editor,
          data: {
            ...this.state.editor.data,
            [nameKeys[1]]: newSchema
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          charges: {
            ...this.state.selectOptions.charges,
            [nameKeys[0]]: {
              ...this.state.selectOptions.charges[nameKeys[0]],
              [nameKeys[1]]: {
                ...this.state.selectOptions.charges[nameKeys[0]][nameKeys[1]],
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
          data: {
            ...this.state.editor[nameKeys[0]].data,
            [nameKeys[1]]: {
              ...this.state.editor[nameKeys[0]].data[nameKeys[1]],
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
      editor: {
        ...this.state.editor,
        data: {
          ...this.state.editor.data,
          [nameKeys[1]]: {
            ...this.state.editor.data[nameKeys[1]],
            [nameKeys[2]]: parseFloat(value)
          }
        }
      }
    })
  }
  handleServiceLevelChange (event) {
    this.setState({ selectedServiceLevel: event }, () => { this.prepAllOptions() })
  }
  handleRangeChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    const { range } = this.state.editor.data[nameKeys[1]]
    range[nameKeys[2]][nameKeys[3]] = parseFloat(value)
    this.setState({
      editor: {
        ...this.state.editor,
        data: {
          ...this.state.editor.data,
          [nameKeys[1]]: {
            ...this.state.editor.data[nameKeys[1]],
            range
          }
        }
      }
    })
  }
  toggleEdit () {
    this.setState({ edit: !this.state.edit }, () => { this.prepAllOptions() })
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
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
        }
        newObj[direction][oKey][chargeKey] = AdminPricingBox.selectFromOptions(
          opts,
          charges[direction][oKey][chargeKey]
        )
      })
    })
    this.setState({ selectOptions: newObj, charges })
  }

  saveEdit () {
    const { editor, selectedCargoClass } = this.state
    Object.keys(editor.data).forEach((fk) => {
      delete editor.data[fk].key
      delete editor.data[fk].name
      delete editor.data[fk].effective_date
      delete editor.data[fk].expiration_date
    })
    this.props.adminDispatch.updatePricing(editor.id, editor)
    const charge = this.props.charges
      .filter(c => c.transport_category.cargo_class === selectedCargoClass)[0]
    this.setAllFromOptions(charge.pricing, 'charges', charge.transport_category.cargo_class)
  }
  handleDirectionChange (e) {
    const { directionBool } = this.state
    if (!directionBool) {
      this.setState({
        direction: 'export',
        directionBool: true
      }, () => this.prepAllOptions())
    } else {
      this.setState({
        direction: 'import',
        directionBool: false
      }, () => this.prepAllOptions())
    }
  }
  renderCargoClassButtons () {
    const { selectedCargoClass, charges, isEditing } = this.state
    const { theme } = this.props
    const { primary, secondary } = theme.colors
    const bgStyle = gradientGenerator(primary, secondary)

    return cargoClassOptions.map((cargoClass, i) => {
      const hasCargoClass = charges
        .filter(charge => charge.transport_category.cargo_class === cargoClass.value).length > 0
      const buttonStyle = selectedCargoClass === cargoClass.value ? bgStyle : { background: '#E0E0E0' }
      const innerStyle = selectedCargoClass === cargoClass.value ? styles2.cargo_class_button_selected : ''
      const inactiveStyle = hasCargoClass ? '' : styles2.cargo_class_button_inactive

      return (<div
        className={`flex-25 layout-row layout-align-start-center ${inactiveStyle} ${styles2.cargo_class_button}`}
        style={buttonStyle}
        onClick={hasCargoClass && !isEditing ? () => this.setCargoClass(cargoClass.value) : null}
      >
        <div className={`flex-none layout-row layout-align-center-center ${innerStyle} ${styles2.cargo_class_button_inner}`}>
          <p className="flex-none">{cargoClass.label}</p>
        </div>
        { i !== cargoClassOptions.length - 1 ? <div className={`flex-none ${styles2.cargo_class_divider}`} /> : ''}
      </div>)
    })
  }

  render () {
    const {
      theme, title, closeView, serviceLevels
    } = this.props

    const {
      selectOptions,
      charges,
      selectedCargoClass,
      editor,
      selectedServiceLevel
    } = this.state

    if (!charges || (charges && !charges[0])) {
      return ''
    }
    const gradientStyle =
    theme && theme.colors
      ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }

    const editCharge = { ...editor }
    const selectedCharge = charges.filter(c => (c.transport_category.cargo_class === selectedCargoClass) &&
    (c.transport_category.vehicle_id === selectedServiceLevel.value ||
      !selectedServiceLevel))[0]
    const currentCharge = selectedCharge || charges[0]

    const feeRows = Object.keys(currentCharge.pricing.data).map((ck) => {
      const fee = currentCharge.pricing.data[ck]
      fee.key = ck
      fee.name = chargeGlossary[ck]
      fee.effective_date = currentCharge.pricing.effective_date
      fee.expiration_date = currentCharge.pricing.expiration_date

      return fee.range ? (<PricingRangeRow
        className="flex-100"
        theme={theme}
        fee={fee}
        isEditing={() => this.isEditing()}
        loadType={selectedCargoClass}
        selectOptions={selectOptions.charges}
        editCharge={editCharge}
        handleDateEdit={this.handleDayChange}
        handleSelect={this.handleSelect}
        handleChange={this.handleChange}
        saveEdit={e => this.saveEdit(e)}
        handleRangeChange={this.handleRangeChange}
        target="charges"
      />) : (<PricingRow
        className="flex-100"
        theme={theme}
        fee={fee}
        isEditing={() => this.isEditing()}
        loadType={selectedCargoClass}
        selectOptions={selectOptions.charges}
        editCharge={editCharge}
        handleDateEdit={this.handleDayChange}
        handleSelect={this.handleSelect}
        handleChange={this.handleChange}
        saveEdit={e => this.saveEdit(e)}
        target="charges"
      />)
    })

    return (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles2.container}`}>
        <div className={`flex-100 layout-row layout-align-space-between-center ${styles2.header_bar_grey}`}>
          <div className="flex-30 layout-row layout-align-start-center">
            <p className={`flex-none ${styles2.text}`} >{title || 'Fees & Charges' }</p>
          </div>
          <div className="flex-25 layout-row layout-align-end-center">
            <NamedSelect
              options={serviceLevels}
              onChange={this.handleServiceLevelChange}
              value={selectedServiceLevel}
              className="flex-100"
            />
          </div>
          {closeView ? <div
            className="flex-none layout-row layout-align-center-center"
            onClick={closeView}
          >
            <i className="fa fa-times clip flex-none" style={gradientStyle} />
          </div> : ''}
        </div>
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className={`flex-100 layout-row ${styles.cargo_class_row}`}>
            {this.renderCargoClassButtons()}
          </div>
          <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.fee_row_container}`}>
            {feeRows}
          </div>
        </div>
      </div>
    )
  }
}
AdminPricingBox.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  closeView: PropTypes.objectOf(PropTypes.func),
  charges: PropTypes.arrayOf(PropTypes.any),
  serviceLevels: PropTypes.arrayOf(PropTypes.any),
  title: PropTypes.string
}
AdminPricingBox.defaultProps = {
  theme: {},
  charges: [],
  serviceLevels: [],
  title: '',
  closeView: null
}

export default AdminPricingBox
