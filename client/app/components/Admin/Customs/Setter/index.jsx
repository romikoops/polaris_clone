import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Toggle from 'react-toggle'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import '../../../../styles/day-picker-custom.scss'
import styles from '../../Admin.scss'
import styles2 from './index.scss'
import { NamedSelect } from '../../../NamedSelect/NamedSelect'
import { RoundButton } from '../../../RoundButton/RoundButton'
import {
  currencyOptions
  // cargoClassOptions
} from '../../../../constants/admin.constants'
import {
  chargeGlossary,
  rateBasises,
  customsFeeSchema,
  rateBasisSchema,
  moment
} from '../../../../constants'
import TextHeading from '../../../TextHeading/TextHeading'

const chargeGloss = chargeGlossary
const rateOpts = rateBasises
const currencyOpts = currencyOptions

export class AdminCustomsSetter extends Component {
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
      direction: 'import'
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
    if (nextProps.charges.hub_id) {
      this.setAllFromOptions(nextProps.charges)
    }
    if (this.state.charges !== nextProps.charges) {
      this.setState({ charges: nextProps.charges })
    }
  }

  setAllFromOptions (charges) {
    const newObj = { import: {}, export: {} }
    const tmpObj = {}

    if (!charges.import) {
      return
    }
    ['import', 'export'].forEach((dir) => {
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
            newObj[dir][key][chargeKey] = AdminCustomsSetter.selectFromOptions(
              opts,
              charges[dir][key][chargeKey]
            )
          } else if (chargeKey === 'rate_basis') {
            opts = rateOpts.slice()
            newObj[dir][key][chargeKey] = AdminCustomsSetter.selectFromOptions(
              opts,
              charges[dir][key][chargeKey]
            )
          }
        })
      })
    })

    this.setState({ selectOptions: newObj })
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

  handleSelect (selection) {
    const { direction } = this.state
    const nameKeys = selection.name.split('-')
    if (nameKeys[2] === 'rate_basis') {
      const price = this.state.charges[nameKeys[0]][nameKeys[1]]
      const newSchema = rateBasisSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if (price[k] && newSchema[k] && k !== 'rate_basis') {
          newSchema[k] = price[k]
        }
      })
      this.setState({
        charges: {
          ...this.state.charges,
          [nameKeys[0]]: {
            ...this.state.charges[nameKeys[0]],
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
        charges: {
          ...this.state.charges,
          [nameKeys[0]]: {
            ...this.state.charges[nameKeys[0]],
            [nameKeys[1]]: {
              ...this.state.charges[nameKeys[0]][nameKeys[2]],
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
      charges[direction][key] = customsFeeSchema[key]
    } else {
      charges[direction][key] = customsFeeSchema[key]
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
        newObj[direction][oKey][chargeKey] = AdminCustomsSetter.selectFromOptions(
          opts,
          charges[direction][oKey][chargeKey]
        )
      })
    })
    this.setState({ selectOptions: newObj, charges })
  }
  saveEdit () {
    const { charges } = this.state
    this.props.adminDispatch.editCustomsFees(charges.hub_id, charges)
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
  handleDayChange (e, direction, key, chargeKey) {
    console.log(e, direction, key, chargeKey)
    this.setState({
      charges: {
        ...this.state.charges,
        [direction]: {
          ...this.state.charges[direction],
          [key]: {
            ...this.state.charges[direction][key],
            [chargeKey]: moment(e).format('YYYY/MM/DD')
          }
        }
      }
    })
  }
  render () {
    const { theme } = this.props

    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const {
      selectOptions, edit, showPanel, direction, directionBool, charges
    } = this.state
    const panel = []
    const viewPanel = []
    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days')
          .format())
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightPrimary} 0%,
          ${theme.colors.primary} 100%
        ) !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightSecondary} 0%,
          ${theme.colors.secondary} 100%
        ) !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const dnrKeys = ['currency', 'key', 'name', 'effective_date', 'expiration_date']
    const gloss = chargeGloss

    if (!charges || (charges && !charges[direction])) {
      return ''
    }
    Object.keys(charges[direction]).forEach((key) => {
      const cells = []
      const viewCells = []

      Object.keys(charges[direction][key]).forEach((chargeKey) => {
        if (!dnrKeys.includes(chargeKey)) {
          cells.push(<div
            key={chargeKey}
            className={`flex layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <div className={`flex-95 layout-row ${styles.editor_input}`}>
              <input
                type="number"
                value={charges[direction][key][chargeKey]}
                onChange={this.handleChange}
                name={`${direction}-${key}-${chargeKey}`}
              />
            </div>
          </div>)
          viewCells.push(<div
            className={`flex-25 layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <p className="flex">
              {charges[direction][key][chargeKey]} {charges[direction][key].currency}
            </p>
          </div>)
        } else if (chargeKey === 'rate_basis') {
          cells.push(<div
            className={`flex layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <NamedSelect
              name={`${direction}-${key}-${chargeKey}`}
              classes={`${styles.select}`}
              value={selectOptions ? selectOptions[direction][key][chargeKey] : ''}
              options={rateOpts}
              className="flex-100"
              onChange={this.handleSelect}
            />
          </div>)
          viewCells.push(<div
            className={`flex-25 layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <p className="flex">{chargeGloss[charges[direction][key][chargeKey]]}</p>
          </div>)
        } else if (chargeKey === 'expiration_date' || chargeKey === 'effective_date') {
          cells.push(<div
            className={`flex layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            } ${styles2.dpb}`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <DayPickerInput
              name="dayPicker"
              placeholder="DD/MM/YYYY"
              format="DD/MM/YYYY"
              value={charges[direction][key][chargeKey]}
              onDayChange={e => this.handleDayChange(e, direction, key, chargeKey)}
              dayPickerProps={dayPickerProps}
            />
          </div>)
          viewCells.push(<div
            className={`flex-25 layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <p className="flex">{moment(charges[direction][key][chargeKey]).format('ll')}</p>
          </div>)
        } else if (chargeKey === 'currency') {
          cells.push(<div
            key={chargeKey}
            className={`flex layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <div className="flex-95 layout-row">
              <NamedSelect
                name={`${direction}-${key}-currency`}
                classes={`${styles.select}`}
                value={selectOptions ? selectOptions[direction][key].currency : ''}
                options={currencyOpts}
                className="flex-100"
                onChange={this.handleSelect}
              />
            </div>
          </div>)
        }
      })

      panel.push(<div
        key={key}
        className="
      flex-100
      layout-row
      layout-align-none-center
      layout-wrap"
      >
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${
            styles.price_subheader
          }`}
        >
          <p className="flex-none">
            {key} - {gloss[key]}
          </p>
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={() => this.deleteFee(key)}
          >
            <i className="fa fa-trash clip" style={textStyle} />
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">{cells}</div>
      </div>)
      viewPanel.push(<div
        className={`flex-100 layout-row layout-align-none-center layout-wrap ${
          styles.expand_panel
        }`}
      >
        <div
          className={`flex-100 layout-row layout-align-start-center ${styles.price_subheader}`}
        >
          <p className="flex-none">
            {key} - {gloss[key]}
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">{viewCells}</div>
      </div>)
    })
    const feesToAdd = Object.keys(customsFeeSchema).map((key) => {
      if (!charges[key]) {
        return (
          <div
            key={key}
            className="flex-33 layout-row layout-align-start-center"
            onClick={() => this.addFeeToPricing(key)}
          >
            <i className="fa fa-plus clip flex-none" style={textStyle} />
            <div className="flex-5" />
            <p className="flex-none">
              {key} - {gloss[key]}{' '}
            </p>
          </div>
        )
      }
      return ''
    })
    const panelViewClass = showPanel ? styles.hub_fee_panel_open : styles.hub_fee_panel_closed
    const impStyle = directionBool ? styles.toggle_off : styles.toggle_on
    const expStyle = directionBool ? styles.toggle_on : styles.toggle_off
    return (
      <div
        className={` ${styles.fee_box} flex-none layout-row layout-wrap layout-align-center-center`}
      >
        <div
          className=" flex-none layout-row layout-wrap layout-align-center-start"
          style={{ position: 'relative' }}
        >
          <div className="flex-95 layout-row layout-wrap layout-align-center-start">
            <div className="flex-100 layout-row">
              <div className="flex-50 layout-row layout-align-start-center">
                <TextHeading theme={theme} text={direction.label} size={4} />
              </div>
              <div className="flex-40 layout-row layout-align-end-center">
                <p className={`${impStyle} flex-none five_m`}>Import</p>
                <p />
                <Toggle checked={directionBool} onChange={e => this.handleDirectionChange(e)} />
                <p className={`${expStyle} flex-none five_m`}>Export</p>
              </div>
              <div
                className="flex-10 layout-row layout-align-end-center"
                onClick={() => this.toggleEdit()}
              >
                <i className="fa fa-pencil clip flex-none" style={textStyle} />
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap" style={{ position: 'relative' }}>
              {edit ? panel : viewPanel}
            </div>
            {edit ? (
              <div className="flex-100 layout-row layout-align-end-center">
                <div
                  className="
              flex-50
              layout-align-end-center
              layout-row"
                  style={{ margin: '15px' }}
                >
                  <RoundButton
                    theme={theme}
                    size="small"
                    text="Add Fee"
                    active
                    handleNext={this.showAddFeePanel}
                    P
                    iconClass="fa-plus"
                  />
                </div>
                <div
                  className="flex-50
layout-align-end-center layout-row"
                  style={{ margin: '15px' }}
                >
                  <RoundButton
                    theme={theme}
                    size="small"
                    text="Save"
                    active
                    handleNext={this.saveEdit}
                    iconClass="fa-floppy-o"
                  />
                </div>
              </div>
            ) : (
              ''
            )}
          </div>
          <div
            className={`flex-100 layout-row layout-align-center-center layout-wrap ${
              styles.add_hub_fee_panel
            } ${panelViewClass}`}
          >
            <div
              className={`flex-none layout-row layout-align-center-center ${styles.panel_close}`}
              onClick={this.showAddFeePanel}
            >
              <i className="fa fa-times clip" style={textStyle} />
            </div>
            <div className="flex-90 layout-row layout-wrap layout-align-start-start">
              {feesToAdd}
            </div>
          </div>
        </div>
        {styleTagJSX}
      </div>
    )
  }
}
AdminCustomsSetter.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  charges: PropTypes.objectOf(PropTypes.any)
}
AdminCustomsSetter.defaultProps = {
  theme: {},
  charges: {}
}

export default AdminCustomsSetter
