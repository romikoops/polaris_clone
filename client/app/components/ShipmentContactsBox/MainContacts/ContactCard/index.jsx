import React from 'react'
import { v4 } from 'node-uuid'
import { ContactCard } from '../../../ContactCard/ContactCard'

export default function ShipmentContactsBoxMainContactsContactCard ({
  theme, contactData, contactType
}) {
  return (
    <ContactCard
      contactData={contactData}
      theme={theme}
      select={null} // TBD - Edit setContactForEdit
      key={v4()}
      contactType={contactType}
    />
  )
}
