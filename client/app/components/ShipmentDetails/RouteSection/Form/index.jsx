import React from 'react'
import AddressFields from './AddressFields'
import Dropdown from './Dropdown'

function RouteSectionForm ({
  ...childProps
}) {
  if (childProps.truckTypes.length > 0) {
    return (
      <div className="route_section_form flex-gt-md-70 flex-100 flex-layout-row layout-wrap">
        <AddressFields {...childProps} />
      </div>
    )
  }

  return (
    <div className="route_section_form flex-gt-md-70 flex-100 flex-layout-row layout-wrap">
      <Dropdown {...childProps} />
    </div>

  )
}

export default RouteSectionForm
