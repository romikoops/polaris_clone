import React, { Component } from 'react'
import styles from './SideOptionsBox.scss'

function SideOptionsBox (props) {
  const { content, header } = props

  return (
    <div className={styles.panel_wrap}>
      <h1><span>{header}</span></h1>
      {content}
    </div>
  )
}

export default SideOptionsBox
