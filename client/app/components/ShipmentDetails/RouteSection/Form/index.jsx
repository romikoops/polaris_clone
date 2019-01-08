import React from 'react'
import Dropdown from './Dropdown'
import AddressFields from './AddressFields'

function RouteSectionForm ({
  carriage,
  ...childProps
}) {
  return (
    <div className="route_section_form">
      {
        carriage
          ? (
            <AddressFields {...childProps} />
          )
          : (
            <Dropdown {...childProps} />
          )
      }
    </div>
  )
}

export default RouteSectionForm
