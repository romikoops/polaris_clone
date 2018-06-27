import React from 'react'
import styles from './SideOptionsBox.scss'
import PropTypes from '../../../prop-types'

function SideOptionsBox (props) {
  const { content, header, flexOptions } = props

  return (
    <div className={`hide-sm hide-xs ${flexOptions} ${styles.panel_wrap}`}>
      <h1><span>{header}</span></h1>
      {content}
    </div>
  )
}

SideOptionsBox.propTypes = {
  content: PropTypes.node,
  header: PropTypes.string,
  flexOptions: PropTypes.string
}

SideOptionsBox.defaultProps = {
  content: null,
  header: '',
  flexOptions: ''
}

export default SideOptionsBox
