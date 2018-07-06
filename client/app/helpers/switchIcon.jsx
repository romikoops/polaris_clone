import React from 'react'

export function switchIcon (mot, style, flex) {
  switch (mot) {
    case 'ocean':
      return <i className={`fa fa-anchor ${style ? 'clip' : ''} ${flex || ''}`} style={style || {}} />
    case 'air':
      return <i className={`fa fa-plane ${style ? 'clip' : ''} ${flex || ''}`} style={style || {}} />
    case 'rail':
      return <i className={`fa fa-train ${style ? 'clip' : ''} ${flex || ''}`} style={style || {}} />
    case 'truck':
      return <i className={`fa fa-truck flip_icon_horizontal ${style ? 'clip' : ''} ${flex || ''}`} style={style || {}} />
    default:
      return <i className={`fa fa-anchor ${style ? 'clip' : ''} ${flex || ''}`} style={style || {}} />
  }
}

export default switchIcon
