import React, { Fragment } from 'react'
import { get } from 'lodash'

export function contentToHtml (contentArray) {
  return contentArray.sort((a,b) => a.index - b.index).map(contentObj => (
    <Fragment>
      <div dangerouslySetInnerHTML={{ __html: contentObj.text }} />
    </Fragment>
  ))
}

export function formatAddress (address) {
  const keys = [['street_number',
    'street'],
  ['city',
    'zip_code'],
  ['country.name']]

  const addressComponents = []
  keys.forEach((keyArray) => {
    const section = keyArray.map(k => get(address, k, false)).filter(x => x).join(', ')
    if (section.length > 0) {
      addressComponents.push(section)
      addressComponents.push(<br />)
    }
  })

  return addressComponents
}
