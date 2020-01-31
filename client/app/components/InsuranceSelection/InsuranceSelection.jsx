import React, { Component } from 'react'
import Toggle from 'react-toggle'
import defaults from '../../styles/default_classes.scss'
import TextHeading from '../TextHeading/TextHeading'

class InsuranceSelection extends Component {
  constructor (props) {
    super(props)
    this.toggleInsurance = this.toggleInsurance.bind(this)
  }

  toggleInsurance (bool) {
    const { handleInsurance } = this.props
    handleInsurance(bool)
  }

  render () {
    const {
      t,
      theme,
      tenant,
      insuranceBool
    } = this.props

    const insurancePercentage = (parseFloat(tenant.scope.transport_insurance_rate) * 100)

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
                  {t('cargo:quoteInsurance', { tenantRate: insurancePercentage })}
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
                  {t('cargo:noQuoteInsurance', { tenantName: tenant.name })}
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
