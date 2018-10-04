import React from 'react'
import PropTypes from 'prop-types'
import adminStyles from '../Admin/Admin.scss'
import styles from './GreyBox.scss'

function GreyBox ({
  title,
  content,
  wrapperClassName,
  contentClassName,
  titleAction,
  flex,
  isBox,
  flexGtLg,
  flexMd,
  padding,
  fullWidth,
  borderStyle
}) {
  return (
    <div className={`${borderStyle || adminStyles.border_box} ${wrapperClassName} 
      ${flex === 0 ? 'flex' : (`flex-${flex}`)}
      ${flexGtLg === 0 ? '' : (`flex-gt-lg-${flexGtLg}`)}
      ${flexMd === 0 ? '' : (`flex-md-${flexMd}`)}
      ${padding ? styles.boxpadding : ''}
      ${isBox ? 'layout-row flex-sm-100 flex-xs-100 layout-align-center-center' : ''} 
      ${fullWidth ? styles.fullWidth : ''}`}
    >
      <div className={contentClassName}>
        {title || titleAction ? (
          <div className="layout-align-space-between-center layout-row flex-100">
            {title ? <p className={`layout-align-start-center flex layout-row ${adminStyles.title_grey}`}>{title}</p> : ''}
            {titleAction || ''}
          </div>

        ) : (
          ''
        )}
        {content}
      </div>
    </div>
  )
}

GreyBox.propTypes = {
  flex: PropTypes.number,
  flexGtLg: PropTypes.number,
  flexMd: PropTypes.number,
  fullWidth: PropTypes.bool,
  isBox: PropTypes.bool,
  padding: PropTypes.bool,
  title: PropTypes.string,
  borderStyle: PropTypes.string,
  content: PropTypes.node,
  titleAction: PropTypes.node,
  wrapperClassName: PropTypes.string,
  contentClassName: PropTypes.string
}

GreyBox.defaultProps = {
  flex: 0,
  flexGtLg: 0,
  flexMd: 0,
  fullWidth: false,
  isBox: false,
  padding: false,
  wrapperClassName: '',
  title: '',
  borderStyle: '',
  contentClassName: '',
  content: [''],
  titleAction: false
}

export default GreyBox
