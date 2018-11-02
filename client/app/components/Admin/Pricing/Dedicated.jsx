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
import { gradientGenerator, gradientTextGenerator, gradientBorderGenerator, filters } from '../../../helpers'
import PricingRow from './Row'
import PricingRangeRow from './RangeRow'
import { RoundButton } from '../../RoundButton/RoundButton'
import GradientBorder from '../../GradientBorder'
import GreyBox from '../../GreyBox/GreyBox'

const rateOpts = rateBasises
const currencyOpts = currencyOptions

export class AdminPricingDedicated extends Component {
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
        charges: {}
      },
      editor: {
      },
      edit: true,
      direction: 'import',
      selectedCargoClass: 'lcl',
      setUsers: false,
      selectedClients: {}
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
    this.handleTopLevelSelect = this.handleTopLevelSelect.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.showAddFeePanel = this.showAddFeePanel.bind(this)
    this.addFeeToPricing = this.addFeeToPricing.bind(this)
    this.handleRangeChange = this.handleRangeChange.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.charges[0] && nextProps.charges[0].pricing) {
      nextProps.charges.forEach((charge) => {
        this.setAllFromOptions(charge.pricing, 'charges', charge.transport_category.cargo_class)
      })
    }
    if (this.state.charges !== nextProps.charges) {
      this.setState({
        charges: nextProps.charges,
        selectedCargoClass: nextProps.charges[0].transport_category.cargo_class
      })
    }
  }

  setCargoClass (type) {
    this.setState({ selectedCargoClass: type }, () => { this.prepAllOptions() })
  }

  setAllFromOptions (charges, target, loadType) {
    const newObj = { }
    const tmpObj = {}
    if (!charges.data) {
      return
    }
    Object.keys(charges.data).forEach((key) => {
      if (!newObj[key]) {
        newObj[key] = {}
      }
      if (!tmpObj[key]) {
        tmpObj[key] = {}
      }
      let opts
      Object.keys(charges.data[key]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          newObj[key][chargeKey] = AdminPricingDedicated.selectFromOptions(
            opts,
            charges.data[key][chargeKey]
          )
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          newObj[key][chargeKey] = AdminPricingDedicated.selectFromOptions(
            opts,
            charges.data[key][chargeKey]
          )
        }
      })
    })

    this.setState(prevState => (
      {
        editor: charges,
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
      selectedCargoClass, charges
    } = this.state
    const charge = charges
      .filter(c => c.transport_category.cargo_class === selectedCargoClass)[0]
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
      const newSchema = rateBasisSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if ((price[k] && newSchema[k] && k !== 'rate_basis') || k === 'effective_date' || k === 'expiration_date') {
          newSchema[k] = price[k]
        }
      })
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
            [nameKeys[2]]: parseInt(value, 10)
          }
        }
      }
    })
  }
  handleRangeChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    const { range } = this.state.editor.data[nameKeys[1]]
    range[nameKeys[2]][nameKeys[3]] = parseInt(value, 10)
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
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
        }
        newObj[direction][oKey][chargeKey] = AdminPricingDedicated.selectFromOptions(
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
  assignUsers () {
    this.setState({ setUsers: !this.state.setUsers })
  }
  assignUser (id) {
    this.setState({
      selectedClients: {
        ...this.state.selectedClients,
        [id]: !this.state.selectedClients[id]
      }
    })
  }
  handleSearchChange (event) {
    const { value } = event.target
    this.setState({
      clientSearch: value
    })
  }
  savePricings () {
    const { adminDispatch, closePricingView } = this.props
    const { editor, selectedClients } = this.state
    const activeClients = []
    Object.keys(selectedClients).forEach((ck) => {
      if (selectedClients[ck]) {
        activeClients.push(ck)
      }
    })
    Object.keys(editor.data).forEach((fk) => {
      delete editor.data[fk].key
      delete editor.data[fk].name
      delete editor.data[fk].effective_date
      delete editor.data[fk].expiration_date
    })
    adminDispatch.assignDedicatedPricings(editor, activeClients)
    closePricingView()
  }
  renderCargoClassButtons () {
    const { selectedCargoClass, charges } = this.state
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
    const {
      theme, clients, backBtn, initialEdit
    } = this.props

    const {
      selectOptions,
      charges,
      selectedCargoClass,
      setUsers,
      selectedClients,
      clientSearch
    } = this.state

    if (!charges || (charges && !charges[0])) {
      return ''
    }

    const selectedCharge = charges.filter(charge => charge.transport_category.cargo_class === selectedCargoClass)[0]
    const currentCharge = selectedCharge || charges[0]
    const editCharge = this.state.editor

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
        initialEdit={initialEdit}
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
        initialEdit={initialEdit}
      />)
    })
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const gradientBorderStyle =
        theme && theme.colors
          ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
          : { background: 'black' }
    const filteredClients = filters.handleSearchChange(
      clientSearch,
      ['first_name', 'last_name', 'company_name', 'phone', 'email'],
      clients
    )
    const setPricingView = (
      <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
        <div className="flex-5 layout-row pointy" onClick={backBtn}>
          <span className="hover_text">{'< Back'}</span>
        </div>
        <div className="flex-100 layout-row">
          <h2>Define dedicated charges</h2>
        </div>
        <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles2.edit_wrapper}`}>
          <div className={`flex-100 layout-row ${styles.cargo_class_row}`}>
            {this.renderCargoClassButtons()}
          </div>
          <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.fee_row_container}`}>
            {feeRows}
          </div>
        </div>
        <div className={`flex-100 layout-row layout-align-end-center layout-wrap ${styles.fee_row_container}`}>
          <div className="flex-33 layout-row">
            <RoundButton
              inverse
              theme={theme}
              handleNext={() => this.assignUsers()}
              text="Next >"
              size="small"
              active
            />
          </div>
        </div>
      </div>
    )
    const userTiles = filteredClients.slice(0, 7).map(c => (
      <div className={`flex-100 flex-sm-50 flex-md-33 flex-gt-md-20 layout-row ${styles2.assign_user_tile}`}>
        {selectedClients[c.id] ? (
          <GradientBorder
            wrapperClassName={`flex pointy ${styles2.margin_fixes}`}
            gradient={gradientBorderStyle}
            className="layout-row flex-100"
            content={(
              <div className={`flex layout-row layout-align-start-center ${styles2.assign_user_tile_inner}`}>
                <div
                  onClick={() => this.assignUser(c.id)}
                  className="flex layout-row layout-align-start-center"
                >
                  <i className="flex-none fa fa-user clip" style={gradientStyle} />
                  <p className="flex-100">{`${c.first_name} ${c.last_name}`}</p>
                </div>
                <div className={`flex-none layout-row layout-align-center-center ${styles2.assigned_checkmark}`}>
                  <i className="fa fa-check flex-none clip" style={gradientStyle} />
                </div>
              </div>
            )}
          />
        ) : (
          <GreyBox
            wrapperClassName="flex pointy"
            contentClassName="layout-row flex-100"
            content={(
              <div className={`flex layout-row layout-align-start-center ${styles2.assign_user_tile_inner}`}>
                <div
                  onClick={() => this.assignUser(c.id)}
                  className="flex layout-row layout-align-start-center"
                >
                  <i className="flex-none fa fa-user" style={{ color: '#BDBDBD' }} />
                  <p className="flex-100">{`${c.first_name} ${c.last_name}`}</p>
                </div>
              </div>
            )}
          />
        )}
      </div>
    ))
    const setUserView = (
      <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
        <div className="flex-5 layout-row pointy" onClick={() => this.assignUsers()}>
          <span className="hover_text">{'< Back'}</span>
        </div>
        <div className="flex-100 layout-row layout-align-space-between-center">
          <h2>Choose users</h2>
          <div className="input_box_full flex-40 layout-row layout-align-end-center">
            <input
              type="text"
              name="search"
              placeholder="Search clients"
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        <div className={`flex-100 layout-row layout-align-start-start layout-wrap layout-padding ${styles2.users_wrapper}`}>
          {userTiles}
        </div>
        <div className="flex-100 layout-row layout-align-center-center layout-wrap">
          <RoundButton
            theme={theme}
            handleNext={() => this.savePricings()}
            text="Save Pricings"
            size="small"
            active
          />
        </div>
      </div>
    )

    return (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles2.container}`}>
        {setUsers ? setUserView : setPricingView}
      </div>
    )
  }
}
AdminPricingDedicated.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  charges: PropTypes.arrayOf(PropTypes.any),
  clients: PropTypes.arrayOf(PropTypes.user).isRequired,
  backBtn: PropTypes.func,
  closePricingView: PropTypes.func.isRequired,
  initialEdit: PropTypes.bool
}
AdminPricingDedicated.defaultProps = {
  theme: {},
  charges: [],
  backBtn: null,
  initialEdit: false
}

export default AdminPricingDedicated
