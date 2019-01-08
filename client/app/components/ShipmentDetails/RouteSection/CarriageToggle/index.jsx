import React from 'react'
import { withNamespaces } from 'react-i18next'
import Toggle from 'react-toggle'

function CarriageToggle ({
  carriage, checked, onChange, t
}) {
  return (
    <label>
      { carriage === 'pre' ? t('shipment:pickUp') : t('shipment:delivery') }
      <Toggle
        className={`flex-none ccb_${carriage}_carriage`}
        id={`${carriage}Carriage`}
        name={`${carriage}Carriage`}
        tabIndex="-1"
        checked={checked}
        onChange={onChange}
      />
    </label>
  )
}

export default withNamespaces('shipment')(CarriageToggle)
