import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator } from '../../../helpers'

function IncotermExtras ({
  theme, shipment, feeHash, tenant, t
}) {
  const selectedStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
  const deselectedStyle = {
    ...gradientTextGenerator('rgb(0, 0, 0)', 'rgb(25, 25, 25)'),
    opacity: '0.5'
  }
  const { scope } = tenant.data
  const customsStyle =
    feeHash && feeHash.customs ? selectedStyle : deselectedStyle
  const insuranceStyle =
    feeHash && feeHash.insurance ? selectedStyle : deselectedStyle
  const exportPaperStyle =
    feeHash && feeHash.addons && feeHash.addons.customs_export_paper ? selectedStyle : deselectedStyle
  const insuranceFeesValue = feeHash ? (
    <div
      className={`${
        styles.fee_value
      } flex-none width_100 layout-row layout-align-center-center layout-wrap`}
    >
      {feeHash.insurance && feeHash.insurance.val ? (
        <p className="flex-none no_m center">{feeHash.insurance.currency}</p>
      ) : (
        ''
      )}
      <p className="flex-none no_m center">
        {feeHash.insurance && feeHash.insurance.val
          ? `${parseFloat(feeHash.insurance.val).toFixed(2)}`
          : t('common:none')}
      </p>
    </div>
  ) : (
    ''
  )

  const requested = (
    <div
      className={`${
        styles.fee_value
      } flex-none width_100 layout-row layout-align-center-center layout-wrap`}
    >
      <p className="flex-none no_m center">{t('shipment:requested')}</p>
    </div>
  )
  const none = (
    <div
      className={`${
        styles.fee_value
      } flex-none width_100 layout-row layout-align-center-center layout-wrap`}
    >
      <p className="flex-none no_m center">{t('common:none')}</p>
    </div>
  )

  const customsFeesValue = feeHash ? (
    <div
      className={`${
        styles.fee_value
      } flex-none width_100 layout-row layout-align-center-center layout-wrap`}
    >
      {feeHash.customs && feeHash.customs.val ? (
        <p className="flex-none no_m center">{feeHash.customs.currency}</p>
      ) : (
        ''
      )}
      <p className="flex-none no_m center">
        {feeHash.customs && feeHash.customs.val
          ? `${parseFloat(feeHash.customs.val).toFixed(2)}`
          : t('common:none')}
      </p>
    </div>
  ) : (
    ''
  )
  const exportPaperFeesValue = feeHash ? (
    <div
      className={`${
        styles.fee_value
      } flex-none width_100 layout-row layout-align-center-center layout-wrap`}
    >
      {feeHash.addons && feeHash.addons && feeHash.addons.customs_export_paper ? (
        <p className="flex-none no_m center">{feeHash.addons.customs_export_paper.currency}</p>
      ) : (
        ''
      )}
      <p className="flex-none no_m center">
        {feeHash.addons && feeHash.addons && feeHash.addons.customs_export_paper
          ? `${parseFloat(feeHash.addons.customs_export_paper.value).toFixed(2)}`
          : t('common:none')}
      </p>
    </div>
  ) : (
    ''
  )

  const customsFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-row layout-align-space-around-center`}>
      <div className="flex-none layout-row layout-align-center-center ">
        <i className="fa fa-id-card clip flex-none" style={customsStyle} />
      </div>
      <div className="flex layout-row layout-align-center-space-around layout-wrap">
        <div className={`${styles.fee_text} flex-100 layout-row layout-align-center-center `}>
          <h4 className="flex-none no_m">{t('shipment:customs')}</h4>
        </div>
        {scope.detailed_billing && feeHash.customs ? customsFeesValue : ''}
        {!scope.detailed_billing && feeHash.customs ? requested : ''}
        {!feeHash || (feeHash && !feeHash.customs) ? none : ''}
      </div>
    </div>
  )
  const insuranceFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-row layout-align-space-around-center`}>
      <div className="flex-none layout-row layout-align-center-center ">
        <i className="fa fa-umbrella clip flex-none" style={insuranceStyle} />
      </div>
      <div className="flex layout-row layout-align-center-space-around layout-wrap">
        <div className={`${styles.fee_text} flex-100 layout-row layout-align-center-center `}>
          <h4 className="flex-none no_m">{t('shipment:insurance')}</h4>
        </div>
        {scope.detailed_billing && feeHash.insurance ? insuranceFeesValue : ''}
        {!scope.detailed_billing && feeHash.insurance ? requested : ''}
        {!feeHash || (feeHash && !feeHash.insurance) ? none : ''}
      </div>
    </div>
  )
  const exportPaperFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-row layout-align-space-around-center`}>
      <div className="flex-none layout-row layout-align-center-center ">
        <i className="fa fa-id-card clip flex-none" style={exportPaperStyle} />
      </div>
      <div className="flex layout-row layout-align-center-space-around layout-wrap">
        <div className={`${styles.fee_text} flex-100 layout-row layout-align-center-center `}>
          <h4 className="flex-none no_m">{t('shipment:adb')}</h4>
        </div>
        {scope.detailed_billing && feeHash.addons && feeHash.addons.customs_export_paper ? exportPaperFeesValue : ''}
        {!scope.detailed_billing && feeHash.addons && feeHash.addons.customs_export_paper ? requested : ''}
        {!feeHash || (feeHash && feeHash.addons && !feeHash.addons.customs_export_paper) ? none : ''}
        {shipment.eori || ''}
      </div>
    </div>
  )

  return (
    <div
      className={`flex-100 layout-row layout-align-space-around-center  ${styles.incoterm_wrapper}`}
    >
      {scope.has_customs ? customsFeesTile : ''}
      {scope.has_insurance ? insuranceFeesTile : '' }
      {scope.customs_export_paper ? exportPaperFeesTile : '' }
    </div>
  )
}

IncotermExtras.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  feeHash: PropTypes.objectOf(PropTypes.any),
  tenant: PropTypes.tenant,
  shipment: PropTypes.objectOf(PropTypes.any).isRequired
}

IncotermExtras.defaultProps = {
  theme: null,
  feeHash: {},
  tenant: {}
}

export default withNamespaces(['common', 'shipment'])(IncotermExtras)
