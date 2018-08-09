import React from 'react'
import PropTypes from 'prop-types'
import adminStyles from '../Admin/Admin.scss'

function GreyBox ({
  title,
  content,
  wrapperClassName,
  contentClassName,
  titleAction
}) {
  return (
    <div className={`${adminStyles.border_box} ${wrapperClassName}`}>
      <div className={contentClassName}>
        {title || titleAction ? (
          <div className={`layout-align-space-between-center flex layout-row ${adminStyles.title_grey}`}>
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
  title: PropTypes.string.isRequired,
  content: PropTypes.node,
  titleAction: PropTypes.node,
  wrapperClassName: PropTypes.string,
  contentClassName: PropTypes.string
}

GreyBox.defaultProps = {
  wrapperClassName: '',
  contentClassName: '',
  content: [''],
  titleAction: false
}

export default GreyBox
