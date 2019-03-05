import React from 'react'
import { withNamespaces } from 'react-i18next'
import Autocomplete from '../../Autocomplete'
import styles from './index.scss'
import CollapsingBar from '../../../../CollapsingBar/CollapsingBar'

import CollapsableFields from './CollapsableFields'

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
  countries,
  collapsed,
  onClickCollapser,
  truckingAvailable
}) {
  return (
    <div className={`ccb_route_section_form_${target} ${styles.route_section_form_wrapper}`}>
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
          collapsed={collapsed}
          contentHeader={(
            <div className={`${styles.btn_address_form}`} onClick={() => onClickCollapser(target)}>
              <i className={`${collapsed && styles.collapsed} flex-none fa fa-angle-double-${collapsed ? 'down' : 'up'}`} />
            </div>
          )}
        >
          <div className={`layout-row layout-align-center-center ${styles.collapsable_fields_wrapper}`}>
            <CollapsableFields
              target={target}
              formData={formData}
              onClickCollapser={onClickCollapser}
              truckingAvailable={truckingAvailable}
            />
          </div>
        </CollapsingBar>
      </div>
    </div>
  )
}

export default withNamespaces(['shipment', 'common'])(AddressFields)
