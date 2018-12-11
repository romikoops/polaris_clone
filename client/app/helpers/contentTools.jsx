import React, { Fragment } from 'react'

export function contentToHtml (contentArray) {
  return contentArray.sort((a,b) => a.index - b.index).map(contentObj => (
    <Fragment>
      <div dangerouslySetInnerHTML={{ __html: contentObj.text }} />
    </Fragment>
  ))
}
