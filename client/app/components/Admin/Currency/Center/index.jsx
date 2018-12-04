import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Toggle from 'react-toggle'
import PropTypes from '../../../../prop-types'
import styles from './index.scss'
import TextHeading from '../../../TextHeading/TextHeading'
import { appActions } from '../../../../actions'
import { NamedSelect } from '../../../NamedSelect/NamedSelect'
import SquareButton from '../../../SquareButton'
import { currencyOptions } from '../../../../constants'
import GenericError from '../../../ErrorHandling/Generic'

const CurrencyViewTile = ({
  currency, convertValue, results, baseCurrency, calculator
}) => (
  <div className={`${styles.currency_tile} flex-25 layout-row layout-align-space-between-center layout-wrap`}>
    <div className={`${styles.currency_tile_content} flex layout-row layout-align-space-between-center layout-wrap`}>
      <div className="flex-100 layout-row layout-align-space-around-center">
        <p className="flex-none">{currency.key}</p>
        <p className="flex-none">{currency.rate}</p>
      </div>
      <div
        className="flex-100 layout-row layout-align-space-around-center layout-wrap"
        style={{ marginBottom: '10px' }}
      >
        <div
          className="flex-100 layout-row layout-align-space-around-center
                layout-wrap input_box"
        >
          <input
            className="flex-90"
            type="number"
            placeholder="Quick convert"
            name={currency.key}
            value={calculator[currency.key]}
            onChange={e => convertValue(e, currency)}
          />
        </div>
        { results[currency.key]
          ? (
            <div
              className="flex-100 layout-row layout-align-space-around-center layout-wrap"
            >
              <p className="flex-90 margin_5 center">
                {`${baseCurrency.key} ${calculator[currency.key].toFixed(2)}`}
              </p>
              <p className="flex-90 no_m center">
                     =
              </p>
              <p className="flex-90 margin_5 center">
                {`${currency.key} ${results[currency.key].toFixed(2)}`}
              </p>
            </div>
          )
          : ''}
      </div>

    </div>
  </div>
)
CurrencyViewTile.propTypes = {
  baseCurrency: PropTypes.objectOf(PropTypes.any).isRequired,
  calculator: PropTypes.objectOf(PropTypes.any).isRequired,
  results: PropTypes.objectOf(PropTypes.any).isRequired,
  currency: PropTypes.objectOf(PropTypes.any).isRequired,
  convertValue: PropTypes.func.isRequired
}

CurrencyViewTile.defaultProps = {

}

const CurrencySetTile = ({
  currency, setValue, newValues
}) => (
  <div className={`${styles.currency_tile} flex-25 layout-row layout-align-space-between-center layout-wrap`}>
    <div className={`${styles.currency_tile_content} flex layout-row layout-align-space-between-center layout-wrap`}>
      <div className="flex-100 layout-row layout-align-space-around-center">
        <p className="flex-none">{currency.key}</p>
        <p className="flex-none">{currency.rate}</p>
      </div>
      <div
        className="flex-100 layout-row layout-align-space-around-center layout-wrap"
        style={{ marginBottom: '10px' }}
      >
        <div
          className="flex-100 layout-row layout-align-space-around-center
                layout-wrap input_box"
        >
          <input
            className="flex-90"
            type="number"
            placeholder="Set Exchange Rate"
            name={currency.key}
            value={newValues[currency.key]}
            onChange={e => setValue(e, currency)}
          />
        </div>
      </div>
    </div>
  </div>
)
CurrencySetTile.propTypes = {
  newValues: PropTypes.objectOf(PropTypes.any).isRequired,
  currency: PropTypes.objectOf(PropTypes.any).isRequired,
  setValue: PropTypes.func.isRequired
}

CurrencySetTile.defaultProps = {

}

class AdminCurrencyCenter extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentBase: {},
      calculator: {},
      results: {},
      rateBool: true,
      rates: {},
      newValues: {},
      editBool: false,
      searchString: ''
    }
  }

  componentWillMount () {
    if (this.props.currencies.length === 0) {
      this.props.appDispatch.fetchCurrenciesForBase('USD')
    }
    if (!this.state.currentBase.label && this.props.currencies.length > 0) {
      const baseCurrency = this.props.currencies.filter(currency => currency.rate === 1)[0]
      this.setState({ currentBase: { value: baseCurrency.key, label: baseCurrency.key } })
    }
    this.props.setCurrentUrl('/admin/currencies')
  }

  componentWillReceiveProps (nextProps) {
    if (!this.state.currentBase.label && nextProps.currencies.length > 0) {
      const baseCurrency = nextProps.currencies.filter(currency => currency.rate === 1)[0]
      this.setState({ currentBase: { value: baseCurrency.key, label: baseCurrency.key } })
    }
    if (this.state.rateBool !== nextProps.tenant.scope.fixed_exchange_rates) {
      this.setState({ rateBool: nextProps.tenant.scope.fixed_exchange_rates })
    }
    if (nextProps.currencies !== this.props.currencies) {
      this.setDefaultValues()
    }
  }

  setValue (e, currency) {
    const { value } = e.target
    this.setState({
      newValues: {
        ...this.state.newValues,
        [currency.key]: parseFloat(value)
      }
    })
  }

  setDefaultValues () {
    const { currencies } = this.props
    const newValues = {}
    currencies.forEach((c) => {
      newValues[c.key] = c.rate
    })
    this.setState({ newValues })
  }

  refreshRates () {
    const { appDispatch } = this.props
    const { currentBase } = this.state
    appDispatch.refreshRates(currentBase.value)
  }

  convertValue (e, currency) {
    const { value } = e.target
    const convertedValue = value * currency.rate
    this.setState({
      calculator: {
        ...this.state.calculator,
        [currency.key]: parseFloat(value)
      },
      results: {
        ...this.state.results,
        [currency.key]: convertedValue
      }
    })
  }

  handleRateToggle () {
    const { appDispatch } = this.props
    this.setState({ rateBool: !this.state.rateBool }, () => {
      appDispatch.toggleTenantCurrencyMode()
    })
  }

  handleBaseChange (selection) {
    const { appDispatch } = this.props
    this.setState({ currentBase: selection }, () => {
      appDispatch.fetchCurrenciesForBase(selection.value)
    })
  }

  handleSearch (event) {
    const { value } = event.target
    this.setState({ searchString: value })
  }

  saveChanges () {
    const { appDispatch, currencies } = this.props
    const { newValues } = this.state
    const baseCurrency = currencies.filter(currency => currency.rate === 1)[0].key
    appDispatch.setTenantCurrencyRates(baseCurrency, newValues)
    this.toggleEdit()
  }

  toggleEdit () {
    this.setState(prevState => ({ editBool: !prevState.editBool }))
  }

  render () {
    const { t, currencies, tenant } = this.props
    const { theme } = tenant
    const {
      currentBase, calculator, results, rateBool, rates, newValues, editBool, searchString
    } = this.state
    if (!currencies.length) {
      return ''
    }

    console.log(rates)
    const baseCurrency = currencies.filter(currency => currency.rate === 1)[0]
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: 
          ${theme.colors.brightPrimary} !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: ${theme.colors.brightSecondary} !important;
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

    const currencyRates =
    currencies
      .filter(currency => currency !== baseCurrency)
      .filter(currency => currency.key.includes(searchString.toUpperCase()))
      .map(currency => (editBool
        ? (
          <CurrencySetTile
            currency={currency}
            setValue={(e, curr) => this.setValue(e, curr)}
            saveChanges={e => this.saveChanges(e)}
            theme={theme}
            newValues={newValues}
          />
        )
        : (
          <CurrencyViewTile
            currency={currency}
            convertValue={(e, curr) => this.convertValue(e, curr)}
            results={results}
            baseCurrency={baseCurrency}
            calculator={calculator}
            theme={theme}
          />
        )))
    const editorButtons = editBool
      ? (
        <div className="flex-100 layout-row layout-wrap layout-align-center-center" style={{ marginTop: '10px' }}>
          <SquareButton
            className="flex-90"
            handleNext={() => this.saveChanges()}
            theme={theme}
            size="small"
            text={t('admin:saveRates')}
          />
          <SquareButton
            className="flex-90"
            handleNext={() => this.toggleEdit()}
            theme={theme}
            size="small"
            text={t('admin:cancelEdit')}
          />
        </div>
      )
      : (
        <div className="flex-100 layout-row layout-align-center-center" style={{ marginTop: '10px' }}>
          <SquareButton
            className="flex-90"
            handleNext={() => this.toggleEdit()}
            theme={theme}
            size="small"
            text={t('admin:editRates')}
          />
          {' '}
        </div>
      )

    const refreshButton = (
      <div className="flex-100 layout-row layout-align-center-center" style={{ marginTop: '10px' }}>
        <SquareButton
          className="flex-90"
          handleNext={() => this.refreshRates()}
          theme={theme}
          size="small"
          text={t('admin:refreshRates')}
        />
      </div>
    )

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading size={3} text="Currency Center" />
          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap">
            <div className="flex-80 layout-row layout-align-center-center layout-wrap">

              <div className="flex-90 layout-row layout-align-center-start layout-wrap">
                {currencyRates}
              </div>
            </div>
            <div className="flex-20 layout-row layout-wrap layout-align-center-start">

              <div
                className="flex-100 layout-row layout-align-space-around-center
                      layout-wrap input_box"
              >
                <input
                  className="flex-90"
                  type="text"
                  placeholder="Search Currencies"
                  value={searchString}
                  onChange={e => this.handleSearch(e)}
                />
              </div>
              <div className="flex-90 layout-row layout-align-space-between-start">
                <div className="flex-90 layout-row layout-align-space-between-center">
                  <p className="flex-none">Live Rates</p>
                  <div className="flex-5" />
                  <Toggle
                    className="flex-none"
                    id="rateToggle"
                    name="rateToggle"
                    checked={rateBool}
                    onChange={e => this.handleRateToggle(e)}
                  />
                  <div className="flex-5" />
                  <p className="flex-none">Set Rates</p>
                </div>
              </div>
              <div className="flex-90 layout-row layout-align-space-between-start">
                <p className="flex-none">Base Currency</p>
                <p className="flex-none">{baseCurrency.key}</p>
              </div>
              <div className="flex-100 layout-row layout-align-center-center">
                <NamedSelect
                  className="flex-100"
                  options={currencyOptions}
                  value={currentBase}
                  onChange={e => this.handleBaseChange(e)}
                />
              </div>
              { rateBool
                ? editorButtons
                : refreshButton
              }
              <div className="flex-100 layout-row layout-align-center-center" />
            </div>
          </div>
          {styleTagJSX}
        </div>
      </GenericError>
    )
  }
}

AdminCurrencyCenter.propTypes = {
  t: PropTypes.func.isRequired,
  tenant: PropTypes.tenant,
  setCurrentUrl: PropTypes.func.isRequired,
  currencies: PropTypes.arrayOf(PropTypes.any),
  appDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminCurrencyCenter.defaultProps = {
  tenant: {},
  currencies: [],
  appDispatch: {}
}

function mapStateToProps (state) {
  const { app } = state
  const { tenant, currencyList } = app

  return {
    currencies: currencyList,
    tenant
  }
}
function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminCurrencyCenter))
