import React from 'react'
import styles from './SideOptionsBox.scss'
import PropTypes from '../../../prop-types'

function SideOptionsBox (props) {
  const { content, header } = props

  return (
    <div className={styles.panel_wrap}>
      <h1><span>{header}</span></h1>
      {content}
    </div>
  )
}

SideOptionsBox.propTypes = {
  content: PropTypes.node,
  header: PropTypes.string
}

SideOptionsBox.defaultProps = {
  content: null,
  header: ''
}

export default SideOptionsBox
