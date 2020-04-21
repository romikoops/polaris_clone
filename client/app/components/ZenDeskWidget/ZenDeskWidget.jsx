import React, { useEffect } from 'react'
import { Helmet } from 'react-helmet'
import { get } from 'lodash'

export const ZenDeskWidget = (props) => {
  const { zenDeskKey, user } = props

  useEffect(() => {
    if (!window.zE) { return }
    if (get(user, ['role', 'name'], '') === 'admin') {
      window.zE('webWidget', 'show')
      window.zE('webWidget', 'identify', {
        email: user.email,
        organization: user.company,
        name: `${user.first_name} ${user.last_name}`
      })
    } else {
      window.zE('webWidget', 'hide')
    }
  })

  return (
    <Helmet>
      <script
        id="ze-snippet"
        type="text/javascript"
        src={`https://static.zdassets.com/ekr/snippet.js?key=${zenDeskKey}`}
        async
        defer
      />
    </Helmet>
  )
}

export default ZenDeskWidget
