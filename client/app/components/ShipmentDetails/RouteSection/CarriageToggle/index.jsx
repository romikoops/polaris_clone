import React from 'react'
import { withNamespaces } from 'react-i18next'
import Toggle from 'react-toggle'
import styles from './index.scss'

function CarriageToggle ({
  carriage, checked, onChange, t, theme, labelOnly
}) {
  const label = (
    <label
      htmlFor={`${carriage}Carriage`}
      className={`flex-100 layout-row layout-align-end-start layout-wrap ${styles.carriage_label}`}
    >
      <p style={{ marginRight: '15px' }}>{ carriage === 'pre' ? t('shipment:pickUp') : t('shipment:delivery') }</p>
    </label>
  )

  if (labelOnly) return label

  const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: ${theme.colors.brightPrimary} !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: #bbb !important;
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(200, 200, 200, 0.5);
      }
    `
  const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

  return (
    <div className="flex-100 layout-row layout-align-end-end">
      {label}
      <Toggle
        className={`flex-none ccb_${carriage}_carriage ${styles.toggle}`}
        id={`${carriage}Carriage`}
        name={`${carriage}Carriage`}
        tabIndex="-1"
        checked={checked}
        onChange={onChange}
      />
      {styleTagJSX}
    </div>
  )
}

CarriageToggle.defaultProps = {
  theme: { colors: { brightPrimary: 'blue' } }
}

export default withNamespaces('shipment')(CarriageToggle)
