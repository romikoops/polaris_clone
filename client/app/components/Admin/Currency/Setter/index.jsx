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

export class AdminCurrencySetter extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentBase: {},
      calculator: {},
      results: {},
      rateBool: true,
      rates: {}
    }
  }
  componentWillMount () {
    if (this.props.currencies.length === 0) {
      this.props.appDispatch.fetchCurrenciesForBase('USD')
    } else if (this.state.currentBase === {}) {
      const baseCurrency = this.props.currencies.filter(currency => currency.rate === 1)[0]
      this.setState({ currentBase: { value: baseCurrency.key, label: baseCurrency.key } })
    }
  }
  componentWillReceiveProps (nextProps) {
    if (this.state.currentBase === {} && nextProps.currencies.length > 0) {
      const baseCurrency = nextProps.currencies.filter(currency => currency.rate === 1)[0]
      this.setState({ currentBase: { value: baseCurrency.key, label: baseCurrency.key } })
    }
    if (this.state.rateBool !== nextProps.tenant.scope.fixedRates) {
      this.setState({ rateBool: nextProps.tenant.scope.fixedRates })
    }
  }
  handleBaseChange (selection) {
    const { appDispatch } = this.props
    this.setState({ currentBase: selection }, () => {
      appDispatch.fetchCurrenciesForBase(selection.value)
    })
  }
  handleRateToggle () {
    const { appDispatch } = this.props
    this.setState({ rateBool: !this.state.rateBool }, () => {
      appDispatch.toggleTenantCurrencyMode()
    })
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
  render () {
    const { t, currencies, tenant } = this.props
    const { theme } = tenant && tenant.data ? tenant.data : {}
    const {
      currentBase, calculator, results, rateBool, rates
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

    const currencyRates = currencies.filter(currency => currency !== baseCurrency)
      .map(currency => (
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
                  placeholder={t('admin:quickConvert')}
                  name={currency.key}
                  value={calculator[currency.key]}
                  onChange={e => this.convertValue(e, currency)}
                />
              </div>
              { results[currency.key]
                ? (<div
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
                </div>)
                : ''}
            </div>
          </div>
        </div>
      ))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <TextHeading size={3} text={t('admin:currencyCenter')} />
        </div>
        <div className="flex-100 layout-row layout-align-center-start layout-wrap">
          <div className="flex-80 layout-row layout-align-center-center layout-wrap">

            <div className="flex-90 layout-row layout-align-center-start layout-wrap">
              {currencyRates}
            </div>
          </div>
          <div className="flex-20 layout-row layout-wrap layout-align-center-start">
            <div className="flex-90 layout-row layout-align-space-between-start">
              <div className="flex-90 layout-row layout-align-space-between-center">
                <p className="flex-none">{t('admin:liveRates')}</p>
                <div className="flex-5" />
                <Toggle
                  className="flex-none"
                  id="rateToggle"
                  name="rateToggle"
                  checked={rateBool}
                  onChange={e => this.handleRateToggle(e)}
                />
                <div className="flex-5" />
                <p className="flex-none">{t('admin:setRates')}</p>
              </div>
            </div>
            <div className="flex-90 layout-row layout-align-space-between-start">
              <p className="flex-none">{t('admin:baseCurrency')}</p>
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
            <div className="flex-100 layout-row layout-align-center-center" style={{ marginTop: '10px' }}>
              <SquareButton
                className="flex-90"
                handleNext={() => this.refreshRates()}
                theme={theme}
                size="small"
                text={t('admin:refreshRates')}
              />
            </div>
          </div>
        </div>
        {styleTagJSX}
      </div>
    )
  }
}

AdminCurrencySetter.propTypes = {
  t: PropTypes.func.isRequired,
  tenant: PropTypes.tenant,
  currencies: PropTypes.arrayOf(PropTypes.any),
  appDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminCurrencySetter.defaultProps = {
  tenant: {},
  currencies: [],
  appDispatch: {}
}

function mapStateToProps (state) {
  const { app, tenant } = state
  const { currencyList } = app

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

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminCurrencySetter))
