import React from 'react'

export function switchIcon (mot) {
  let icon
  switch (mot) {
    case 'ocean':
      icon = <i className="fa fa-ship" />
      break
    case 'air':
      icon = <i className="fa fa-plane" />
      break
    case 'train':
      icon = <i className="fa fa-train" />
      break
    default:
      icon = <i className="fa fa-ship" />
      break
  }
  return icon
}

export default switchIcon
