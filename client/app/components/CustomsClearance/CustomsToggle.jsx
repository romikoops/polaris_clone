import React from 'react'
import Toggle from 'react-toggle'
import { capitalize, numberSpacing } from '../../helpers'

export default function CustomsToggle ({
  t, tenant, toggleCustoms, customsView, target, port, customsFee
}) {
  const { scope, currency } = tenant

  return (
    <div
      className="flex-100 layout-wrap layout-row layout-align-space-around-center"
    >
      <div className="flex-100 layout-row layout-align-end-center padd_top">
        <Toggle
          id="yes_clearance"
          checked={customsView}
          onChange={() => toggleCustoms(!customsView, target)}
        />
        <div className="flex-5" />
        <div className="flex-75 layout-row layout-align-start-center">
          <label htmlFor="yes_clearance" className="pointy">
            <b>
              {capitalize(port)}
              &nbsp;
              {t('cargo:customsClearance')}
            </b>
            { customsView ? t('cargo:clearanceYes', {
              tenantName: tenant.name,
              clearanceFee: numberSpacing(customsFee.value, 2),
              port,
              currency: customsFee.currency
            }) : t('cargo:clearanceNo', {
              tenantName: tenant.name,
              port
            })}
            {(scope.hs_fee > 0) ? t('cargo:plusHS', {
              hsFee: scope.hs_fee,
              currency
            }) : ''}
          </label>
        </div>
      </div>
    </div>
  )
}
