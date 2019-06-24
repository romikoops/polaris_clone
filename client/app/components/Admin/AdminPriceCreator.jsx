import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { RoundButton } from '../RoundButton/RoundButton'
import { currencyOptions, cargoClassOptions } from '../../constants/admin.constants'
import {
  fclChargeGlossary,
  lclChargeGlossary,
  chargeGlossary,
  rateBasises,
  lclPricingSchema,
  fclPricingSchema,
  cargoGlossary,
  rateBasisSchema
} from '../../constants'

const fclChargeGloss = fclChargeGlossary
const lclChargeGloss = lclChargeGlossary
const chargeGloss = chargeGlossary
const rateOpts = rateBasises
const currencyOpts = currencyOptions
const cargoClassOpts = cargoClassOptions
const lclSchema = lclPricingSchema
const fclSchema = fclPricingSchema
const cargoGloss = cargoGlossary

export class AdminPriceCreator extends Component {
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
  static prepForSelect (arr, labelKey, valueKey, glossary) {
    return arr.map(a => ({
      value: valueKey ? a[valueKey] : a,
      label: glossary ? glossary[a[labelKey]] : a[labelKey]
    }))
  }
  constructor (props) {
    super(props)
    this.state = {
      pricing: lclSchema,
      cargoClass: cargoClassOpts[0],
      selectOptions: {},
      route: false,
      hubRoute: false,
      transportCategory: false,
      client: false,
      steps: {
        cargoClass: false,
        route: false,
        hubRoute: false,
        transportCategory: false,
        pricing: false,
        client: false
      }
    }
    this.editPricing = lclSchema
    this.handleChange = this.handleChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.setCargoClass = this.setCargoClass.bind(this)
    this.setAllFromOptions = this.setAllFromOptions.bind(this)
    this.handleTopLevelSelect = this.handleTopLevelSelect.bind(this)
    this.deleteFee = this.deleteFee.bind(this)
    this.showAddFeePanel = this.showAddFeePanel.bind(this)
    this.addFeeToPricing = this.addFeeToPricing.bind(this)
  }
  componentWillMount () {
    this.setAllFromOptions()
  }

  setAllFromOptions () {
    const { pricing } = this.state
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
          // this.getOptions(opts, key, chargeKey);
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          // this.getOptions(opts, key, chargeKey);
        }
        newObj.data[key][chargeKey] = AdminPriceCreator.selectFromOptions(
          opts,
          pricing.data[key][chargeKey]
        )
      })
    })
    this.setState({ selectOptions: newObj })
  }

  setCargoClass (value) {
    const schema = value.value === 'lcl' ? lclSchema : fclSchema
    this.setState({ cargoClass: value, pricing: schema })
    this.editPricing = schema
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
  showAddFeePanel () {
    this.setState({ showPanel: !this.state.showPanel })
  }
  deleteFee (key) {
    const { pricing } = this.state
    delete pricing.data[key]
    this.setState({ pricing })
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
  addFeeToPricing (key) {
    const { pricing } = this.state
    if (pricing.load_type === 'lcl') {
      pricing.data[key] = lclPricingSchema.data[key]
    } else {
      pricing.data[key] = fclPricingSchema.data[key]
    }

    const newObj = { data: {} }
    const tmpObj = {}

    Object.keys(pricing.data).forEach((oKey) => {
      if (!newObj.data[oKey]) {
        newObj.data[oKey] = {}
      }
      if (!tmpObj[oKey]) {
        tmpObj[oKey] = {}
      }
      let opts
      Object.keys(pricing.data[oKey]).forEach((chargeKey) => {
        if (chargeKey === 'currency') {
          opts = currencyOpts.slice()
          // this.getOptions(opts, key, chargeKey);
        } else if (chargeKey === 'rate_basis') {
          opts = rateOpts.slice()
          // this.getOptions(opts, key, chargeKey);
        }
        newObj.data[key][chargeKey] = AdminPriceCreator.selectFromOptions(
          opts,
          pricing.data[key][chargeKey]
        )
      })
    })
    this.setState({ selectOptions: newObj, pricing })
  }
  saveEdit () {
    const {
      hubRoute, transportCategory, route, cargoClass, pricing, client
    } = this.state
    const clientTag = client.value !== 'OPEN' ? `_${client.value.id}` : ''
    const pricingId = `${hubRoute.value.origin_stop_id}_${hubRoute.value.destination_stop_id}_${
      transportCategory.value.id
    }_${route.value.tenant_id}_${cargoClass.value}${clientTag}`
    pricing.hub_route_id = hubRoute.value.id
    pricing.itinerary_id = route.value.id
    pricing.tenant_id = route.value.tenant_id
    pricing.transport_category_id = transportCategory.value.id
    this.props.adminDispatch.updatePricing(pricingId, pricing)
    this.props.closeForm()
  }

  render () {
    const {
      t, theme, itineraries, detailedItineraries, transportCategories, clients
    } = this.props
    const {
      route, hubRoute, cargoClass, steps, transportCategory, client, showPanel
    } = this.state
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const { pricing, selectOptions } = this.state
    const panel = []
    let gloss
    if (cargoClass.value.includes('lcl')) {
      gloss = lclChargeGloss
    } else {
      gloss = fclChargeGloss
    }
    const routeOpts = AdminPriceCreator.prepForSelect(itineraries, 'name', false, false)

    const hubRouteOpts = route
      ? detailedItineraries
        .filter(di => di.id === route.value.id)
        .map(a => ({ value: a, label: `${a.origin_hub_name} - ${a.destination_hub_name}` }))
      : []
    const transportCategoryOpts = cargoClass
      ? AdminPriceCreator.prepForSelect(
        transportCategories.filter(x => x.cargo_class === cargoClass.value),
        'name',
        false,
        cargoGloss
      )
      : []

    Object.keys(pricing.data).forEach((key) => {
      const cells = []
      Object.keys(pricing.data[key]).forEach((chargeKey) => {
        if (chargeKey !== 'currency' && chargeKey !== 'rate_basis') {
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
        }
      })
      panel.push(<div
        key={key}
        className="flex-100 layout-row layout-align-none-center layout-wrap"
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
    })

    const selectCargoClass = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">{t('admin:selectCargoType')}</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="cargoClass"
              classes={`${styles.select}`}
              value={cargoClass}
              options={cargoClassOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )
    const selectRoute = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">{t('admin:selectRoute')}</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="route"
              classes={`${styles.select}`}
              value={route}
              options={routeOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )
    const selectHubRoute = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">{t('admin:selecSspecificHubs')}</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="hubRoute"
              classes={`${styles.select}`}
              value={hubRoute}
              options={hubRouteOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )

    const selectTransportCategory = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">{t('admin:selectTypeGood')}</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="transportCategory"
              classes={`${styles.select}`}
              value={transportCategory}
              options={transportCategoryOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )
    const cargoClassResult = (
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
        <h4 className="flex-none letter_3">{t('admin:cargoClass')}</h4>
        <h4 className="flex-none letter_3">{cargoClass.label}</h4>
      </div>
    )
    const routeResult = (
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
        <h4 className="flex-none letter_3">{t('admin:route')}</h4>
        <h4 className="flex-none letter_3">{route.label}</h4>
      </div>
    )
    const hubRouteResult = (
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
        <h4 className="flex-none letter_3">{t('admin:subRoute')}</h4>
        <h4 className="flex-none letter_3">{hubRoute.label}</h4>
      </div>
    )
    const transportCategoryResult = (
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
        <h4 className="flex-none letter_3">{t('admin:transportCategory')}</h4>
        <h4 className="flex-none letter_3">{transportCategory.label}</h4>
      </div>
    )

    const contextPanel = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          {steps.cargoClass === false ? selectCargoClass : cargoClassResult}
          {steps.cargoClass === true && steps.transportCategory === false
            ? selectTransportCategory
            : transportCategoryResult}
          {steps.transportCategory === true && steps.route === false ? selectRoute : routeResult}
          {steps.route === true && steps.hubRoute === false ? selectHubRoute : hubRouteResult}
        </div>
      </div>
    )
    const feeSchema = cargoClass.label === 'lcl' ? lclPricingSchema : fclPricingSchema
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
        <div
          className={` ${
            styles.editor_fade
          } flex-none layout-row layout-wrap layout-align-center-start`}
          onClick={this.props.closeForm}
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
                {t('admin:newPricing')}
              </p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-60 layout-row layout-align-start-center">
                <i className="fa fa-map-signs clip" style={textStyle} />
                <p className="flex-none offset-5">{hubRoute ? hubRoute.label : ''}</p>
              </div>
            </div>
            {client ? panel : contextPanel}
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
                text={t('admin:save')}
                active
                handleNext={this.saveEdit}
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

AdminPriceCreator.defaultProps = {
  theme: {},
  closeForm: null,
  itineraries: [],
  detailedItineraries: [],
  transportCategories: []
}

export default withNamespaces('admin')(AdminPriceCreator)
