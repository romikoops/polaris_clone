import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get, has } from 'lodash'
import Modal from '../Modal/Modal'
import AdminMarginPreviewRate from '../Admin/Clients/MarginPreview/Rate'
import styles from './QuoteChargeBreakdown.scss'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import { CONTAINER_DESCRIPTIONS } from '../../constants'
import {
  numberSpacing,
  capitalize,
  formattedPriceValue,
  humanizeSnakeCaseUp,
  fixedWeightChargeableString
} from '../../helpers'
import { breakdownExists, previewPrepare } from '../Admin/Clients/MarginPreview/previewPrepare'
import { UserContext } from '../../helpers/contexts'

class QuoteChargeBreakdown extends Component {
  static shouldShowSubTotal (currencySections, scope) {
    if (scope.hide_sub_totals) return false

    if (Object.keys(currencySections).length < 1) return false

    return true
  }

  constructor (props) {
    super(props)
    this.unbreakableKeys = ['total', 'edited_total', 'name']
    this.quoteKeys = this.quoteKeys.bind(this)
    this.state = {
      expander: this.quoteKeys().reduce(
        (acc, k) => ({ ...acc, [k]: props.scope.hide_sub_totals }),
        {}
      )
    }
  }

  static contextType = UserContext

  determineSubKey (charge) {
    const { scope, mot, t } = this.props
    let effectiveCharge
    if (charge[0].includes('unknown')) {
      effectiveCharge = [charge[0].replace('unknown_', ''), charge[1]]
    } else if (charge[0].includes('included_')) {
      effectiveCharge = [charge[0].replace('included_', ''), charge[1]]
    } else {
      effectiveCharge = charge
    }

    switch (scope.fee_detail) {
      case 'key':
        return this.displayKeyOnly(effectiveCharge[0])
      case 'name':
        return effectiveCharge[1].name
      case 'key_and_name':
        return this.displayKeyAndName(effectiveCharge)
      default:
        return this.displayKeyOnly(effectiveCharge[0])
    }
  }

  displayKeyOnly (key) {
    const { t } = this.props

    switch (key) {
      case 'trucking_lcl' || 'trucking_fcl':
        return t('cargo:truckingRate')

      default:
        return humanizeSnakeCaseUp(key)
    }
  }

  displayKeyAndName (fee) {
    const { t } = this.props

    switch (fee[0]) {
      case 'trucking_lcl' || 'trucking_fcl':
        return t('cargo:truckingRate')

      default:
        return `${humanizeSnakeCaseUp(fee[0])} - ${fee[1].name}`
    }
  }

  quoteKeys () {
    const keysInOrder = [
      'trucking_pre',
      'export',
      'cargo',
      'import',
      'trucking_on'
    ]
    const availableQuoteKeys = Object.keys(this.props.quote).filter(
      (key) => !this.unbreakableKeys.includes(key)
    )

    return keysInOrder.filter((key) => availableQuoteKeys.includes(key))
  }

  motName (name) {
    const { mot } = this.props
    if (name === 'Freight') {
      return `${capitalize(mot)} ${name}`
    }

    return name
  }

  dynamicValueExtractor (key, price) {
    const { scope } = this.props
    const user = this.context
    let currency
    let value
    if (key.includes('trucking') && (user.guest || scope.hide_grand_total)) {
      const targetKey = Object.keys(price[1]).filter(
        (pKey) => !this.unbreakableKeys.includes(pKey)
      )[0]
      currency = get(price, ['1', targetKey, 'currency'])
      value = get(price, ['1', targetKey, 'value'])
    } else {
      currency = get(price, ['1', 'total', 'currency'], null)
      value = get(price, ['1', 'total', 'value'], null)
    }

    return { currency, value, overridePrice: price }
  }

  dynamicSectionTotal (key) {
    const { scope, quote } = this.props

    if (get(scope, ['quote_card', 'sub_totals', key], true) && has(quote, [key, 'total', 'value'])) {
      return `${formattedPriceValue(get(quote, [key, 'total', 'value']))} ${
        get(quote, [key, 'total', 'currency'])
        }`
    }

    return ''
  }

  dynamicSubKey (key, price, i) {
    const { t, scope, mot } = this.props
    if (
      key === 'cargo' &&
      !get(scope, ['consolidation', 'cargo', 'backend']) &&
      !scope.fine_fee_detail
    ) {
      return t('cargo:unitFreightRate', { unitNo: i + 1 })
    }
    if (
      key === 'cargo' &&
      get(scope, ['consolidation', 'cargo', 'backend']) &&
      !get(scope, ['quote_card', 'consolidated_fees'], false) &&
      mot === 'ocean'
    ) {
      return t('cargo:oceanFreight')
    }
    if (
      key === 'cargo' &&
      get(scope, ['consolidation', 'cargo', 'backend']) &&
      !get(scope, ['quote_card', 'consolidated_fees'], false)
    ) {
      return t('cargo:consolidatedCargoRate')
    }

    return this.determineSubKey(price)
  }

  generateContent (key) {
    const { quote } = this.props

    const contentSections = Object.entries(quote[`${key}`])
      .map((array) => array.filter((value) => !this.unbreakableKeys.includes(value)))
      .filter((value) => value.length !== 1)

    const currencySections = {}
    const includedSections = []
    const excludedSections = []
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = this.dynamicValueExtractor(
        key,
        price
      )

      if (price[0].includes('included')) {
        includedSections.push(price)
      } else if (price[0].includes('unknown')) {
        excludedSections.push(price)
      } else if (value && currency) {
        if (!currencySections[currency]) {
          currencySections[currency] = []
        }
        if (!currencyTotals[currency]) {
          currencyTotals[currency] = 0.0
        }
        currencyTotals[currency] += parseFloat(value)
        currencySections[currency].push(overridePrice)
      }
    })
    const sortedCurrencySections = this.sortCurrencySections(currencySections, key)

    return this.renderContent(
      key,
      sortedCurrencySections,
      currencyTotals,
      includedSections,
      excludedSections,
      true
    )
  }

  fetchCargoData (id) {
    const { cargo } = this.props
    if (id === 'cargo_item') {
      const consolidatedCargo = {
        width: 0,
        length: 0,
        height: 0,
        payload_in_kg: 0,
        quantity: 0,
        cargo_item_type: cargo[0]?.cargo_item_type,
        cargo_class: cargo[0]?.cargo_class
      }
      cargo.forEach((cargoItem) => {
        consolidatedCargo.width += parseFloat(cargoItem.width)
        consolidatedCargo.length += parseFloat(cargoItem.length)
        consolidatedCargo.height += parseFloat(cargoItem.height)
        consolidatedCargo.payload_in_kg += parseFloat(cargoItem.payload_in_kg)
        consolidatedCargo.quantity += parseFloat(cargoItem.quantity)
      })

      return consolidatedCargo
    }

    return cargo.filter((item) => String(item.id) === String(id))[0]
  }

  determineContentToGenerate (key) {
    const { scope } = this.props
    if (key === 'cargo' && scope.fine_fee_detail) { return this.generateUnitContent(key) }
    if (['import', 'export'].includes(key)) { return this.generateUnitContent(key) }

    return this.generateContent(key)
  }

  sortContentSections (sections, key) {
    const { scope } = this.props
    const primaryCode = get(scope, 'primary_freight_code')?.toString()
    if (!primaryCode || key !== 'cargo') { return sections }

    const primarySection = sections.find((section) => section[0].toLowerCase() === primaryCode.toLowerCase())
    const sortedSections = sections.filter((section) => section !== primarySection)
    if (primarySection) { sortedSections.unshift(primarySection) }

    return sortedSections
  }

  sortCurrencySections (sections, key) {
    const { scope } = this.props
    const primaryCode = get(scope, 'primary_freight_code')?.toString()
    const entries = Object.entries(sections)
    if (!primaryCode || key !== 'cargo') { return entries }
    // eslint-disable-next-line arrow-body-style
    const primaryEntry = entries.find((entry) => {
      return entry[1].find((feeEntry) => feeEntry[0].toLowerCase() === primaryCode.toLowerCase())
    })
    const sortedEntries = entries.filter((entry) => entry !== primaryEntry)
    if (primaryEntry) { sortedEntries.unshift(primaryEntry) }

    return sortedEntries
  }

  generateUnitContent (key) {
    const { quote, scope, t } = this.props

    if (quote[`${key}`] == null) {
      return ''
    }

    const unitSections = Object.entries(quote[`${key}`])
      .map((array) => array.filter((value) => !this.unbreakableKeys.includes(value)))
      .filter((value) => value.length !== 1)

    return unitSections.map((unitArray) => {
      const cargo = this.fetchCargoData(unitArray[0])
      const contentSections = Object.entries(unitArray[1])
        .map((array) => array.filter((value) => !this.unbreakableKeys.includes(value)))
        .filter((value) => value.length !== 1)
      const currencySections = {}
      const includedSections = []
      const excludedSections = []
      const currencyTotals = {}
      this.sortContentSections(contentSections, key).forEach((price) => {
        const { currency, value } = price[1]
        if (price[0].includes('included')) {
          includedSections.push(price)
        } else if (price[0].includes('unknown')) {
          excludedSections.push(price)
        } else {
          if (!currencySections[currency]) {
            currencySections[currency] = []
          }
          if (!currencyTotals[currency]) {
            currencyTotals[currency] = 0.0
          }
          currencyTotals[currency] += parseFloat(value)
          currencySections[currency].push(price)
        }
      })
      const showSubTotal = QuoteChargeBreakdown.shouldShowSubTotal(
        currencySections,
        scope
      )
      const sortedCurrencySections = this.sortCurrencySections(currencySections, key)
      const sections = this.renderContent(
        key,
        sortedCurrencySections,
        currencyTotals,
        includedSections,
        excludedSections,
        showSubTotal
      )

      const cargoDescription = cargo && cargo.quantity
        ? CONTAINER_DESCRIPTIONS[cargo.size_class] || get(cargo, ['cargo_item_type', 'description'])
        : t('cargo:consolidatedFees')

      const description = cargo ? cargoDescription : capitalize(unitArray[0])

      return (
        <div
          key={key}
          className={`flex layout-row layout-wrap ${styles.cargo_price_section}`}
        >
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.cargo_title}`}
          >
            {cargo && cargo.quantity ? `${cargo.quantity} x ${description}` : `${description}`}
          </div>
          {sections}
        </div>
      )
    })
  }

  overrideTranslations (key) {
    const { t, scope } = this.props

    if (scope.translation_overrides && scope.translation_overrides[key]) {
      return capitalize(t(scope.translation_overrides[key]))
    }

    return capitalize(t(key))
  }

  togglePricingBreakdownModal () {
    this.setState((prevState) => ({ showPricingBreakdownModal: !prevState.showPricingBreakdownModal }))
  }

  toggleExpander (key) {
    const { scope } = this.props
    if (get(scope, ['quote_card', 'sections', key], false)) {
      this.setState({
        expander: {
          ...this.state.expander,
          [key]: !this.state.expander[key]
        }
      })
    }
  }

  showPricingBreakdown (type, price, cargo) {
    const key = price[0].toLowerCase()
    const data = this.pricingBreakdowns(cargo, key)
    const finalPrice = has(price, [1, 'total']) ? get(price, [1, 'total']) : price[1]

    this.setState({
      pricingBreakdownData: data,
      pricingBreakdownFeeKey: key,
      pricingBreakdownType: type,
      pricingBreakdownPrice: finalPrice
    }, () => this.togglePricingBreakdownModal())
  }

  pricingBreakdowns (cargo, key) {
    const { pricingBreakdowns } = this.props

    return previewPrepare(pricingBreakdowns, cargo, key)
  }

  pricingBreakdownExists (cargo, key) {
    const { pricingBreakdowns } = this.props

    return breakdownExists(pricingBreakdowns, cargo, key)
  }

  renderContent (key, currencySections, currencyTotals, includedSections, excludedSections, showSubTotal, cargo) {
    const { t, scope } = this.props

    const feeSections = currencySections.map((currencyFees) => (
      <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
        {scope.detailed_billing
          ? currencyFees[1].map((price, i) => {
            const subPrices = (
              <div
                className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}
              >
                <div className="flex-45 layout-row layout-align-start-center">
                  {
                    this.pricingBreakdownExists(cargo, price[0]) &&
                    (
                      <div
                        className={`flex-none layout-row layout-align-center-center pointy ${styles.view_breakdown}`}
                        onClick={() => this.showPricingBreakdown(key, price, cargo)}
                      >
                        <i className="fa fa-info-circle" />
                      </div>
                    )
                  }
                  <span className={this.pricingBreakdownExists(cargo, price[0]) && styles.padding_adjust}>
                    {this.dynamicSubKey(key, price, i)}
                  </span>
                </div>
                <div className="flex-50 layout-row layout-align-end-center">
                  <p>
                    {numberSpacing(
                      price[1].value || get(price, [1, 'total', 'value']),
                      2
                    )}
                    &nbsp;
                    {price[1].currency ||
                      get(price, [1, 'total', 'currency'])}
                  </p>
                </div>
              </div>
            )

            return subPrices
          })
          : ''}
        {showSubTotal && currencyFees[0] !== 'null' ? (
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.currency_header}`}
          >
            <div className="flex-70 layout-row layout-align-start-center">
              <span className="flex-none bold">
                {' '}
                {t('cargo:feesIn', { currency: currencyFees[0] })}
              </span>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <p className="flex-none bold">
                {`${numberSpacing(
                  currencyTotals[currencyFees[0]] || 0,
                  2
                )} ${currencyFees[0]}`}
              </p>
            </div>
          </div>
        ) : (
          ''
        )}
      </div>
    ))

    if (scope.detailed_billing && includedSections.length > 0) {
      const includedFees = includedSections.map((price, i) => {
        const subPrices = (
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}
          >
            <div className="flex-70 layout-row layout-align-start-center">
              <span>{this.determineSubKey(price)}</span>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              {price[0].includes('unknown') || price[0].includes('included') ? (
                ''
              ) : (
                <p>
                  {numberSpacing(
                    price[1].value || get(price, [1, 'total', 'value']),
                    2
                  )}
                    &nbsp;
                  {price[1].currency || get(price, [1, 'total', 'currency'])}
                </p>
              )}
            </div>
          </div>
        )

        return subPrices
      })
      feeSections.push(
        <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.cargo_title}`}
          >
            <p className="flex-none">{t('shipment:includedFees')}</p>
          </div>
          {includedFees}
        </div>
      )
    }
    if (scope.detailed_billing && excludedSections.length > 0) {
      const excludedFees = excludedSections.map((price, i) => {
        const subPrices = (
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}
          >
            <div className="flex-70 layout-row layout-align-start-center">
              <span>{this.determineSubKey(price)}</span>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              {price[0].includes('unknown') || price[0].includes('included') ? (
                ''
              ) : (
                <p>
                  {numberSpacing(
                    price[1].value || get(price, [1, 'total', 'value']),
                    2
                  )}
                    &nbsp;
                  {price[1].currency || get(price, [1, 'total', 'currency'])}
                </p>
              )}
            </div>
          </div>
        )

        return subPrices
      })
      feeSections.push(
        <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.cargo_title}`}
          >
            <p className="flex-none">{t('shipment:excludedFees')}</p>
          </div>
          {excludedFees}
        </div>
      )
    }

    return feeSections
  }

  renderChargeableWeight (key) {
    const {
      t, trucking, meta, cargo, scope
    } = this.props

    let target
    let value
    switch (key) {
      case 'trucking_pre':
        target = 'pre_carriage'

        break
      case 'trucking_on':
        target = 'on_carriage'
        break

      default:
        target = key
        break
    }
    switch (key) {
      case 'trucking_pre' || 'trucking_on':
        value = trucking[target].chargeable_weight
        break
      case 'cargo':
        if (get(meta, ['ocean_chargeable_weight'], false)) {
          return `(${fixedWeightChargeableString(
            cargo,
            get(meta, ['ocean_chargeable_weight'], 0),
            t,
            scope
          )})`
        }

        value = cargo.reduce(
          (acc, c) => acc + +c.chargeable_weight * +c.quantity,
          0
        )
        break
      default:
        break
    }

    return `(${t('cargo:chargeableWeightWithValue', { value })})`
  }

  render () {
    const {
      theme, quote, showBreakdowns, scope, shrinkHeaders
    } = this.props
    const {
      pricingBreakdownData,
      showPricingBreakdownModal,
      pricingBreakdownFeeKey,
      pricingBreakdownType,
      pricingBreakdownPrice
    } = this.state
    if (Object.keys(quote).length === 0) return ''
    const headerClass = shrinkHeaders ? styles.small_headers : ''
    const priceBreakdownComponent = (
      <AdminMarginPreviewRate
        rate={pricingBreakdownData}
        feeKey={pricingBreakdownFeeKey}
        type={pricingBreakdownType}
        price={pricingBreakdownPrice}
      />
    )
    const pricingBreakdownModal = (
      <Modal
        parentToggle={() => this.togglePricingBreakdownModal()}
        component={priceBreakdownComponent}
        maxWidth="800px"
        minHeight="300px"
      />
    )

    return [
      this.quoteKeys().map((key) => (
        <CollapsingBar
          showArrow={get(scope, ['quote_card', 'sections', key], false)}
          showArrowSpacer={!get(scope, ['quote_card', 'sections', key], false)}
          collapsed={
            showBreakdowns
              ? this.state.expander[`${key}`]
              : !this.state.expander[`${key}`]
          }
          theme={theme}
          contentStyle={styles.sub_price_row_wrapper}
          headerWrapClasses="flex-100 layout-row layout-wrap layout-align-start-center"
          handleCollapser={() => this.toggleExpander(`${key}`)}
          mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
          contentHeader={(
            <div
              className={`flex-100 layout-row layout-align-start-center
                ${styles.price_row} ${headerClass}`}
            >
              <div className="flex layout-row layout-align-start-center">
                <span>{quote[key] && this.motName(quote[key].name)}</span>
                {scope.show_chargeable_weight &&
                  !['import', 'export'].includes(key) ? (
                    <span
                      className={styles.chargeable_weight}
                      dangerouslySetInnerHTML={{
                        __html: this.renderChargeableWeight(key)
                      }}
                    />
                  ) : (
                    ''
                  )}
              </div>
              <div
                className={`flex-35 layout-row layout-align-end-center ${headerClass}`}
              >
                <p>{this.dynamicSectionTotal(key) || ''}</p>
              </div>
            </div>
          )}
          content={this.determineContentToGenerate(key)}
        />
      )),
      showPricingBreakdownModal ? pricingBreakdownModal : ''
    ]
  }
}

QuoteChargeBreakdown.defaultProps = {
  pricingBreakdowns: []
}

export default withNamespaces(['shipment', 'cargo', 'overrides'])(
  QuoteChargeBreakdown
)
