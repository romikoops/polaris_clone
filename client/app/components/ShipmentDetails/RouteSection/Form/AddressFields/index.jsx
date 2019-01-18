import React from 'react'
import { withNamespaces } from 'react-i18next'
import FormsyInput from '../../../../FormsyInput/FormsyInput'
import Autocomplete from '../../Autocomplete'
import CollapsingContent from '../../../../CollapsingBar/Content'
import styles from './index.scss'
import CollapsingBar from '../../../../CollapsingBar/CollapsingBar'

function AddressFields ({
  map,
  gMaps,
  theme,
  scope,
  target,
  onAutocompleteTrigger,
  onInputBlur,
  formData,
  t,
  countries
}) {
  // TODO: Add Collapsing logic
  const hideFields = false

  return (
    <div className={`route_section_form ${styles.route_section_form_wrapper}`}>
      <Autocomplete
        gMaps={gMaps}
        map={map}
        theme={theme}
        scope={scope}
        hasErrors={false}
        input={formData.fullAddress}
        onAutocompleteTrigger={onAutocompleteTrigger}
        countries={countries}
        errorDispatch={{}}
        target={target}
      />
      <div
        className={`
          flex-100 layout-row layout-wrap layout-align-center ccb_on_address_form 
          ${styles.address_form}
        `}
      >
        <CollapsingBar
          headerWrapClasses={`${styles.header_wrapper}`}
          wrapperContentClasses={`${styles.content_wrapper}`}
          contentHeader={(
            <div className={`${styles.btn_address_form}`}>
              <i className={`${styles.down} flex-none fa fa-angle-double-down`} />
              <i className={`${styles.up} flex-none fa fa-angle-double-up ccb_origin_expand`} />
            </div>
          )}
          content={(
            <div>
              <div className={`flex-100 layout-row ${styles.form_title}`}>
                <h5>{target === 'origin' ? t('shipment:enterPickUp') : t('shipment:enterDelivery')}</h5>
              </div>
              <FormsyInput
                wrapperClassName="flex-100 layout-row layout-align-center"
                placeholder="Street"
                name={`${target}-street`}
                value={formData.street}
                onBlur={onInputBlur}
              />
              <FormsyInput
                wrapperClassName="flex-100 layout-row layout-align-center"
                placeholder="Number"
                name={`${target}-number`}
                value={formData.number}
                onBlur={onInputBlur}
              />
              <FormsyInput
                wrapperClassName="flex-100 layout-row layout-align-center"
                placeholder="ZIP Code"
                name={`${target}-zipCode`}
                value={formData.zipCode}
                onBlur={onInputBlur}
              />
              <FormsyInput
                wrapperClassName="flex-100 layout-row layout-align-center"
                placeholder="City"
                name={`${target}-city`}
                value={formData.city}
                onBlur={onInputBlur}
              />
              <FormsyInput
                wrapperClassName="flex-100 layout-row layout-align-center"
                placeholder="Country"
                name={`${target}-country`}
                value={FormData.street}
                onBlur={onInputBlur}
              />
              <div className="flex-100 pointy layout-row layout-align-start-center">
                <div
                  className={`${styles.clear_sec} flex-none layout-row layout-align-end-center`}
                  onClick={console.log}
                >
                  <i className="fa fa-times flex-none" />
                  <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
                    {t('common:clear')}
                  </p>
                </div>
              </div>
            </div>
          )}
        />
        <CollapsingContent collapsed={hideFields} />
      </div>
    </div>
  )
}

export default withNamespaces(['shipment', 'common'])(AddressFields)
