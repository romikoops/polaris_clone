import React from 'react'

export function switchIcon (mot) {
  switch (mot) {
    case 'ocean':
      return <i className="fa fa-ship" />
    case 'air':
      return <i className="fa fa-plane" />
    case 'rail':
      return <i className="fa fa-train" />
    default:
      return <i className="fa fa-ship" />
  }
}

export default switchIcon
