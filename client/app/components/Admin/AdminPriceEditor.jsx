import React, { Component } from 'react'
import PropTypes from 'prop-types'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import {
  formatDate,
  parseDate
} from 'react-day-picker/moment'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import '../../styles/day-picker-custom.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { currencyOptions } from '../../constants/admin.constants'
import AdminPromptConfirm from './Prompt/Confirm'
import {
  fclChargeGlossary,
  lclChargeGlossary,
  chargeGlossary,
  rateBasises,
  lclPricingSchema,
  fclPricingSchema,
  rateBasisSchema,
  moment
} from '../../constants'
import { gradientTextGenerator } from '../../helpers'

const fclChargeGloss = fclChargeGlossary
const lclChargeGloss = lclChargeGlossary
const chargeGloss = chargeGlossary
const rateOpts = rateBasises
// import {v4} from 'uuid';
const currencyOpts = currencyOptions
export class AdminPriceEditor extends Component {
  static selectFromOptions (options, value) {
    let result
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
      pricing: Object.assign({}, this.props.pricing),
      selectOptions: {}
    }
    this.editPricing = props.pricing
    this.handleChange = this.handleChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)

    this.saveEdit = this.saveEdit.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.showAddFeePanel = this.showAddFeePanel.bind(this)
    this.addFeeToPricing = this.addFeeToPricing.bind(this)
  }
  componentWillMount () {
    this.setAllFromOptions()
  }
  setAllFromOptions () {
    const { pricing } = this.props
    const newObj = { data: {} }
    const tmpObj = {}

    Object.keys(pricing.data).forEach((key) => {
      if (!newObj.data[key]) {
        newObj.data[key] = {}
      }
      if (!tmpObj[key]) {
        tmpObj[key] = {}
      }
      let opts
      Object.keys(pricing.data[key]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          newObj.data[key][chargeKey] = AdminPriceEditor.selectFromOptions(
            opts,
            pricing.data[key][chargeKey]
          )
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          newObj.data[key][chargeKey] = AdminPriceEditor.selectFromOptions(
            opts,
            pricing.data[key][chargeKey]
          )
        }
      })
    })
    this.setState({ selectOptions: newObj })
  }
  addFeeToPricing (key) {
    const { pricing } = this.state
    if (pricing.load_type === 'lcl') {
      pricing.data[key] = lclPricingSchema.data[key]
    } else {
      pricing.data[key] = fclPricingSchema.data[key]
    }
    console.log('pricing', pricing)
    const newObj = { data: {} }
    const tmpObj = {}

    Object.keys(pricing.data).forEach((pKey) => {
      if (!newObj.data[pKey]) {
        newObj.data[pKey] = {}
      }
      if (!tmpObj[pKey]) {
        tmpObj[pKey] = {}
      }
      let opts
      Object.keys(pricing.data[pKey]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          newObj.data[pKey][chargeKey] = AdminPriceEditor.selectFromOptions(
            opts,
            pricing.data[pKey][chargeKey]
          )
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          newObj.data[pKey][chargeKey] = AdminPriceEditor.selectFromOptions(
            opts,
            pricing.data[pKey][chargeKey]
          )
        }
      })
    })
    this.setState({ selectOptions: newObj, pricing })
  }
  handleChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    this.setState({
      pricing: {
        ...this.state.pricing,
        data: {
          ...this.state.pricing.data,
          [nameKeys[0]]: {
            ...this.state.pricing.data[nameKeys[0]],
            [nameKeys[1]]: parseInt(value, 10)
          }
        }
      }
    })
  }
  handleRateChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    const oldRanges = this.state.pricing.data[nameKeys[0]][nameKeys[1]]
    oldRanges[nameKeys[2]][nameKeys[3]] = parseInt(value, 10)
    this.setState({
      pricing: {
        ...this.state.pricing,
        data: {
          ...this.state.pricing.data,
          [nameKeys[0]]: {
            ...this.state.pricing.data[nameKeys[0]],
            [nameKeys[1]]: oldRanges
          }
        }
      }
    })
  }
  handleDayChange (date, target) {
    this.setState({
      pricing: {
        ...this.state.pricing,
        [target]: date
      }
    })
  }
  handleSelect (selection) {
    const nameKeys = selection.name.split('-')
    if (nameKeys[1] === 'rate_basis') {
      const price = this.state.pricing.data[nameKeys[0]]
      const newSchema = rateBasisSchema[selection.value]
      Object.keys(newSchema).forEach((k) => {
        if (price[k] && newSchema[k] && k !== 'rate_basis') {
          newSchema[k] = price[k]
        }
      })
      this.setState({
        pricing: {
          ...this.state.pricing,
          data: {
            ...this.state.pricing.data,
            [nameKeys[0]]: newSchema
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          data: {
            ...this.state.selectOptions.data,
            [nameKeys[0]]: {
              ...this.state.selectOptions.data[nameKeys[0]],
              [nameKeys[1]]: selection
            }
          }
        }
      })
    } else {
      this.setState({
        pricing: {
          ...this.state.pricing,
          data: {
            ...this.state.pricing.data,
            [nameKeys[0]]: {
              ...this.state.pricing.data[nameKeys[0]],
              [nameKeys[1]]: selection.value
            }
          }
        },
        selectOptions: {
          ...this.state.selectOptions,
          data: {
            ...this.state.selectOptions.data,
            [nameKeys[0]]: {
              ...this.state.selectOptions.data[nameKeys[0]],
              [nameKeys[1]]: selection
            }
          }
        }
      })
    }
  }
  deleteFee (key) {
    const { pricing } = this.state
    delete pricing.data[key]
    this.setState({ pricing })
  }
  showAddFeePanel () {
    this.setState({ showPanel: !this.state.showPanel })
  }
  confirmSave () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  saveEdit () {
    const req = this.state.pricing
    const { pricing } = this.props
    this.props.adminTools.updatePricing(pricing.id, req)
    this.closeConfirm()
    this.props.closeEdit()
  }
  render () {
    const { theme, hubRoute } = this.props
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const {
      pricing, selectOptions, showPanel, confirm
    } = this.state
    const panel = []
    let gloss
    if (pricing.load_type === 'lcl') {
      gloss = lclChargeGloss
    } else {
      gloss = fclChargeGloss
    }
    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days'))
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
    console.log(this.state.pricing)
    Object.keys(pricing.data).forEach((key) => {
      const cells = []
      Object.keys(pricing.data[key]).forEach((chargeKey) => {
        if (chargeKey !== 'currency' && chargeKey !== 'rate_basis' && chargeKey !== 'range') {
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
                value={pricing.data[key][chargeKey]}
                onChange={this.handleChange}
                name={`${key}-${chargeKey}`}
              />
            </div>
          </div>)
        } else if (chargeKey === 'rate_basis') {
          cells.push(<div
            className={`flex layout-row layout-align-none-center layout-wrap ${
              styles.price_cell
            }`}
          >
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <NamedSelect
              name={`${key}-${chargeKey}`}
              classes={`${styles.select}`}
              value={selectOptions ? selectOptions.data[key][chargeKey] : ''}
              options={rateOpts}
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
            <p className="flex-100">{chargeGloss[chargeKey]}</p>
            <div className="flex-95 layout-row">
              <NamedSelect
                name={`${key}-currency`}
                classes={`${styles.select}`}
                value={selectOptions ? selectOptions.data[key].currency : ''}
                options={currencyOpts}
                className="flex-100"
                onChange={this.handleSelect}
              />
            </div>
          </div>)
        } else if (chargeKey === 'range') {
          pricing.data[key].range.forEach((rangeFee, i) => {
            const ellipsis = (
              <div className="flex-10 layout-row layout-align-center-center">
                <i className="flex-none fa fa-balance-scale" />
              </div>
            )
            const rangeCells = [ellipsis]
            Object.keys(rangeFee).forEach((rfKey) => {
              if (rfKey === 'max' || rfKey === 'min') {
                rangeCells.push(<div
                  key={rfKey}
                  className={`flex layout-row layout-align-none-center layout-wrap ${
                    styles.price_cell
                  }`}
                >
                  <p className="flex-100">{chargeGloss[rfKey]}</p>
                  <div className={`flex-95 layout-row ${styles.editor_input}`}>
                    <input
                      type="number"
                      value={pricing.data[key][chargeKey][i][rfKey]}
                      onChange={e => this.handleRateChange(e)}
                      name={`${key}-${chargeKey}-${i}-${rfKey}`}
                    />
                  </div>
                </div>)
              } else if (rfKey === 'rate') {
                rangeCells.push(<div
                  key={rfKey}
                  className={`flex layout-row layout-align-none-center layout-wrap ${
                    styles.price_cell
                  }`}
                >
                  <p className="flex-100">{chargeGloss[rfKey]}</p>
                  <div className={`flex-95 layout-row ${styles.editor_input}`}>
                    <input
                      type="number"
                      value={pricing.data[key][chargeKey][i][rfKey]}
                      onChange={e => this.handleRateChange(e)}
                      name={`${key}-${chargeKey}-${i}-${rfKey}`}
                    />
                  </div>

                </div>)
              }
            })
            cells
              .push(<div className="flex-100 layout-row layout-align-start-center">
                {rangeCells}
              </div>)
          })
        }
      })
      panel.push(<div
        key={key}
        className="flex-100
      layout-row layout-align-none-center layout-wrap"
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
        <div className="flex-100 layout-row layout-align-start-center layout-wrap ">{cells}</div>
      </div>)
    })
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text="These changes will be instantly available in your store"
        confirm={() => this.saveEdit()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const feeSchema = pricing.load_type === 'lcl' ? lclPricingSchema : fclPricingSchema
    const feesToAdd = Object.keys(feeSchema.data).map((key) => {
      if (!pricing.data[key]) {
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
    const panelViewClass = showPanel ? styles.fee_panel_open : styles.fee_panel_closed
    return (
      <div
        className={` ${
          styles.editor_backdrop
        } flex-none layout-row layout-wrap layout-align-center-center`}
      >
        {confimPrompt}
        <div
          className={` ${
            styles.editor_fade
          } flex-none layout-row layout-wrap layout-align-center-start`}
          onClick={this.props.closeEdit}
        />
        <div
          className={` ${
            styles.editor_box
          } flex-none layout-row layout-wrap layout-align-center-start`}
        >
          <div
            className={`flex-95 layout-row layout-wrap layout-align-center-start ${
              styles.editor_scroll
            }`}
          >
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_title
              }`}
            >
              <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
                Edit Pricing
              </p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-60 layout-row layout-align-start-center">
                <i className="fa fa-map-signs clip" style={textStyle} />
                <p className="flex-none offset-5">{hubRoute.name}</p>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-100 layout-row layout-align-start-center">
                <i className="fa fa-calendar-check-o clip" style={textStyle} />
                <p className="flex-none offset-5">Applicable Period</p>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                <div className={`flex-40 layout-row layout-align-start-center layout-wrap ${styles.dpb}`}>
                  <p className="flex-100">Effective Date</p>
                  <DayPickerInput
                    name="dayPicker"
                    // placeholder="DD/MM/YYYY"
                    format="LL"
                    formatDate={formatDate}
                    parseDate={parseDate}
                    placeholder={`${formatDate(new Date())}`}
                    value={moment(pricing.effective_date).format('DD/MM/YYYY')}
                    onDayChange={e => this.handleDayChange(e, 'effective_date')}
                    dayPickerProps={dayPickerProps}
                  />
                </div>
                <div className={`flex-40 layout-row layout-align-start-center layout-wrap ${styles.dpb}`}>
                  <p className="flex-100">Expiration Date</p>
                  <DayPickerInput
                    name="dayPicker"
                    // placeholder="DD/MM/YYYY"
                    format="LL"
                    formatDate={formatDate}
                    parseDate={parseDate}
                    placeholder={`${formatDate(new Date())}`}
                    value={moment(pricing.expiration_date).format('DD/MM/YYYY')}
                    onDayChange={e => this.handleDayChange(e, 'expiration_date')}
                    dayPickerProps={dayPickerProps}
                  />
                </div>
              </div>
            </div>
            {panel}
            <div className="flex-100 layout-align-end-center layout-row" style={{ margin: '15px' }}>
              <RoundButton
                theme={theme}
                size="small"
                text="Add Fee"
                active
                handleNext={this.showAddFeePanel}
                iconClass="fa-plus"
              />
            </div>
            <div className="flex-100 layout-align-end-center layout-row" style={{ margin: '15px' }}>
              <RoundButton
                theme={theme}
                size="small"
                text="Save"
                active
                handleNext={() => this.confirmSave()}
                iconClass="fa-floppy-o"
              />
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-align-center-center layout-wrap ${
              styles.add_fee_panel
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
      </div>
    )
  }
}
AdminPriceEditor.propTypes = {
  theme: PropTypes.theme,
  closeEdit: PropTypes.func.isRequired,
  adminTools: PropTypes.shape({
    updatePricing: PropTypes.func
  }).isRequired,
  pricing: PropTypes.shape({
    _id: PropTypes.number,
    data: PropTypes.object
  }).isRequired,
  hubRoute: PropTypes.shape({
    name: PropTypes.string
  }).isRequired
}

AdminPriceEditor.defaultProps = {
  theme: null
}

export default AdminPriceEditor
