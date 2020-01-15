import React from 'react'
import { withNamespaces } from 'react-i18next'
import Autocomplete from '../../Autocomplete'
import styles from './index.scss'
import CollapsingBar from '../../../../CollapsingBar/CollapsingBar'

import CollapsableFields from './CollapsableFields'
import routeOption from '../Dropdown/routeOption'

function getOptions (targets) {
  const labels = []
  const options = []

  const guardedTargets = targets || ['origin', 'destination']

  guardedTargets.forEach((target) => {
    const option = routeOption(target)
    if (labels.includes(option.label)) return

    labels.push(option.label)
    options.push(option)
  })

  return options.sort((a, b) => (a.label > b.label ? 1 : -1))
}

function AddressFields ({
  availableTargets,
  map,
  gMaps,
  theme,
  scope,
  target,
  onDropdownSelect,
  handleHubSelect,
  hubSelected,
  onAutocompleteTrigger,
  onInputBlur,
  formData,
  t,
  countries,
  collapsed,
  onClickCollapser,
  truckingAvailable,
  requiresFullAddress
}) {
  return (
    <div className={`ccb_route_section_form_${target} ${styles.route_section_form_wrapper}`}>
      <Autocomplete
        gMaps={gMaps}
        map={map}
        theme={theme}
        scope={scope}
        onDropdownSelect={onDropdownSelect}
        hasErrors={false}
        input={formData.fullAddress}
        onAutocompleteTrigger={onAutocompleteTrigger}
        countries={countries}
        errorDispatch={{}}
        target={target}
        hubOptions={getOptions(availableTargets)}
        handleHubSelect={handleHubSelect}
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
            {!hubSelected && <CollapsableFields
              target={target}
              formData={formData}
              onInputBlur={onInputBlur}
              onClickCollapser={onClickCollapser}
              truckingAvailable={truckingAvailable}
              requiresFullAddress={requiresFullAddress}
            />}
          </div>
        </CollapsingBar>
      </div>
    </div>
  )
}

export default withNamespaces(['shipment', 'common'])(AddressFields)
