import React from 'react'

export function switchIcon (mot, style, flex, options) {
  let className
  switch (mot) {
    case 'ocean':
      className = 'fa fa-anchor'
      break
    case 'air':
      className = 'fa fa-plane'
      break
    case 'rail':
      className = 'fa fa-train'
      break
    case 'truck':
      className = 'fa fa-truck flip_icon_horizontal'
      break
    default:
      className = 'fa fa-anchor'
  }

  return (
    <i
      className={`${className} ${style ? 'clip' : ''} ${flex || ''}`}
      style={style || {}}
      data-for={options && options.dataFor}
      data-tip={options && options.dataTip}
    />
  )
}

export default switchIcon
