import React, { Component } from 'react'
import { get } from 'lodash'
import Toggle from 'react-toggle'
import defaults from '../../styles/default_classes.scss'
import TextHeading from '../TextHeading/TextHeading'

class InsuranceSelection extends Component {
  constructor (props) {
    super(props)
    this.toggleInsurance = this.toggleInsurance.bind(this)
    this.quoteInsuranceMessage = this.quoteInsuranceMessage.bind(this)
    this.quoteNoInsuranceMessage = this.quoteNoInsuranceMessage.bind(this)
  }

  toggleInsurance (bool) {
    const { handleInsurance } = this.props
    handleInsurance(bool)
  }

  quoteInsuranceMessage () {
    const { t, tenant } = this.props
    const customMessage = get(tenant, 'scope.insurance.messages.accept', null)

    if (customMessage) {
      return customMessage
    }

    const insurancePercentage = (parseFloat(tenant.scope.transport_insurance_rate) * 100).toFixed(2)

    return t('cargo:quoteInsurance', { tenantRate: insurancePercentage })
  }

  quoteNoInsuranceMessage () {
    const { t, tenant } = this.props
    const customMessage = get(tenant, 'scope.insurance.messages.decline', null)

    if (customMessage) {
      return customMessage
    }

    return t('cargo:noQuoteInsurance', { tenantName: tenant.name })
  }

  render () {
    const {
      t,
      theme,
      insuranceBool
    } = this.props

    return (
      <div className="flex-100">
        <div className="flex-100 layout-row layout-align-center padd_top">
          <div
            className={`flex-none ${
              defaults.content_width
            } layout-row layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-space-between-start">
              <div className="flex-none layout-row layout-align-space-around-center">
                <TextHeading
                  theme={theme}
                  size={2}
                  text={t('cargo:transportInsurance')}
                  fontWeight="bold"
                  color="#4F4F4F"
                />
              </div>
            </div>
          </div>
        </div>
        <div
          className="flex-100 layout-row layout-align-space-around-center layout-wrap"
        >
          <div
            className={`flex-none ${
              defaults.content_width
            } layout-row layout-wrap`}
          >
            <div className="flex-100 layout-row layout-wrap layout-align-end-center padd_top">
              <div className="flex-20 layout-row layout-align-end-center">
                <Toggle
                  id="yes_insurance"
                  className="ccb_yes_insurance"
                  onChange={() => this.toggleInsurance(!insuranceBool)}
                  checked={insuranceBool}
                  theme={theme}
                />
              </div>
              <div className="flex-5" />
              <div className="flex-75 layout-row layout-align-start-center">
                <label htmlFor="yes_insurance" className="pointy">
                  <b>{t('common:yes')}</b>
                  {'. '}
                  {this.quoteInsuranceMessage()}
                </label>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-end-center padd_top">
              <div className="flex-20 layout-row layout-align-end-center">
                <Toggle
                  id="no_insurance"
                  className="ccb_no_insurance"
                  onChange={() => this.toggleInsurance(false)}
                  checked={insuranceBool === null ? null : !insuranceBool}
                  theme={theme}
                />
              </div>
              <div className="flex-5" />
              <div className="flex-75 layout-row layout-align-start-center">
                <label htmlFor="no_insurance" className="pointy">
                  <b>{t('common:no')}</b>
                  {'. '}
                  {this.quoteNoInsuranceMessage()}
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>

    )
  }
}

export default InsuranceSelection
