import React from 'react'
import PropTypes from 'prop-types'
import styles from './GreyBox.scss'

export function GreyBox (props) {
  const {
    flex,
    flexGtLg,
    flexMd,
    padding,
    fullWidth,
    component,
    noMargin
  } = props
  /* eslint prefer-template: 0 */
  return (
    <div
      className={
        `layout-row ${flex === 0 ? 'flex' : ('flex-' + flex)}
           ${flexGtLg === 0 ? '' : ('flex-gt-lg-' + flexGtLg)}
           ${flexMd === 0 ? '' : ('flex-md-' + flexMd)}
          flex-sm-100 flex-xs-100 layout-align-center-center
          ${padding ? styles.boxpadding : ''}
          ${fullWidth ? styles.fullWidth : ''}`
      }
    >
      <div className={`flex layout-row layout-align-center-stretch ${styles.greyboxborder}  ${noMargin ? styles.no_margin : ''}`}>
        {component}
      </div>

    </div>
  )
}

GreyBox.propTypes = {
  component: PropTypes.element,
  flex: PropTypes.number,
  flexGtLg: PropTypes.number,
  flexMd: PropTypes.number,
  fullWidth: PropTypes.bool,
  padding: PropTypes.bool,
  noMargin: PropTypes.bool
}

GreyBox.defaultProps = {
  component: null,
  flex: 0,
  flexGtLg: 0,
  flexMd: 0,
  fullWidth: false,
  padding: false,
  noMargin: false
}

export default GreyBox
