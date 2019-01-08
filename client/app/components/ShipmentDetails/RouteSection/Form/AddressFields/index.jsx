import React from 'react'
import FormsyInput from '../../../../FormsyInput/FormsyInput'
import Autocomplete from '../../Autocomplete'
import CollapsingContent from '../../../../CollapsingBar/Content'
import styles from './index.scss'

function AddressFields ({
  map,
  gMaps,
  theme,
  scope,
  target,
  carriage,
  onAutocompleteTrigger,
  onInputBlur,
  formData,
  countries
}) {
  // TODO: Add Collapsing logic
  const hideFields = false

  return (
    <div className="route_section_form">
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

      <CollapsingContent collapsed={hideFields}>
        <FormsyInput
          name={`${target}-street`}
          value={formData.street}
          onBlur={onInputBlur}
        />
        <FormsyInput
          name={`${target}-number`}
          value={formData.number}
          onBlur={onInputBlur}
        />
        <FormsyInput
          name={`${target}-zipCode`}
          value={formData.zipCode}
          onBlur={onInputBlur}
        />
        <FormsyInput
          name={`${target}-city`}
          value={formData.city}
          onBlur={onInputBlur}
        />
        <FormsyInput
          name={`${target}-country`}
          value={FormData.street}
          onBlur={onInputBlur}
        />
        <div className="flex-100 layout-row layout-align-start-center">
          <div
            className={`${styles.clear_sec} flex-none layout-row layout-align-end-center`}
            onClick={console.log}
          >
            <i className="fa fa-times flex-none" />
            <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
              {/* {t('common:clear')} */}
            </p>
          </div>
        </div>

      </CollapsingContent>
    </div>
  )
}

export default AddressFields
