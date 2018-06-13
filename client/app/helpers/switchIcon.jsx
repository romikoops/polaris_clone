import React from 'react'

export function switchIcon (mot, style) {
  switch (mot) {
    case 'ocean':
      return <i className="fa fa-anchor" />
    case 'air':
      return <i className={`fa fa-plane ${style ? 'clip' : ''}`} style={style} />
    case 'rail':
      return <i className={`fa fa-train ${style ? 'clip' : ''}`} style={style} />
    case 'truck':
      return <i className={`fa fa-truck flip_icon_horizontal ${style ? 'clip' : ''}`} style={style} />
    default:
      return <i className="fa fa-anchor" />
  }
}

export default switchIcon
