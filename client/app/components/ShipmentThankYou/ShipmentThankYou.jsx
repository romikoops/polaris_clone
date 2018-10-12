import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './ShipmentThankYou.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'

class ShipmentThankYou extends Component {
  componentDidMount () {
    const { setStage } = this.props
    setStage(6)
    window.scrollTo(0, 0)
  }
  render () {
    const {
      theme, shipmentData, shipmentDispatch, user, tenant, t
    } = this.props
    if (!shipmentData) return <h1>{t('bookconf:loading')}</h1>
    const {
      shipment
    } = shipmentData
    if (!shipment) return <h1> {t('bookconf:loading')}</h1>

    return (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center">
          <div className={`${defaults.content_width} flex-none  layout-row layout-wrap layout-align-start`}>
            <div className={` ${styles.thank_box} flex-100 layout-row layout-wrap`}>
              <div className={` ${styles.thank_you} flex-100 layout-row layout-align-start`}>
                <p className="flex-100">
                  {t('bookconf:thankYou')}
                </p>
              </div>
              <div className={`${styles.b_ref} flex-100 layout-row layout-align-start`}>
                {t('bookconf:bookingReference')}: {shipment.imc_reference}
              </div>
              <div className={`flex-100 layout-row layout-align-start layout-wrap ${styles.thank_details}`}>
                <p className="flex-100">
                  {t('bookconf:requestEmailFirst')}
                  <br />
                  {t('bookconf:requestEmailSecond')}
                  <br />
                  {t('bookconf:requestEmailThird')}
                  <br />
                  {
                    shipment.status === 'requested_by_unconfirmed_account' && (
                      <span>
                        <br />
                        {t('bookconf:emailPlease')}<b> {t('bookconf:confirmEmail')} </b> {t('bookconf:completeRequest')} <br />
                        { `${tenant.name}` } {t('bookconf:tenantWillNot')}
                        {t('bookconf:emailAssociated')} <br />
                        {t('bookconf:followLink')} <br />
                        <br />
                      </span>
                    )
                  }
                  {t('bookconf:contactUs')}
                </p>
              </div>

              <hr className={`${styles.sec_break} flex-100`} />
              <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                  <RoundButton
                    theme={theme}
                    text={t('common:back')}
                    back
                    iconClass="fa-angle0-left"
                    handleNext={() => shipmentDispatch.toDashboard(user.id)}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
ShipmentThankYou.propTypes = {
  theme: PropTypes.objectOf(PropTypes.any),
  t: PropTypes.func.isRequired,
  shipmentData: PropTypes.objectOf(PropTypes.any),
  shipmentDispatch: PropTypes.objectOf(PropTypes.any),
  setStage: PropTypes.func.isRequired,
  user: PropTypes.objectOf(PropTypes.any),
  tenant: PropTypes.tenant
}
ShipmentThankYou.defaultProps = {
  theme: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.objectOf(PropTypes.any),
  shipmentDispatch: null,
  user: {},
  tenant: null
}
export default translate(['bookconf', 'common'])(ShipmentThankYou)
