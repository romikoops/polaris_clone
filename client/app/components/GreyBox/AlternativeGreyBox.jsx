import React from 'react'
import PropTypes from 'prop-types'
import adminStyles from '../Admin/Admin.scss'

export default function AlternativeGreyBox ({
  title,
  content,
  wrapperClassName,
  contentClassName
}) {
  return (
    <div className={`${adminStyles.border_box} ${wrapperClassName}`}>
      <div className={contentClassName}>
        {title ? (
          <p className={`layout-align-start-center flex-100 layout-row ${adminStyles.title_grey}`}>{title}</p>
        ) : (
          ''
        )}
        {content}
      </div>
    </div>
  )
}

AlternativeGreyBox.propTypes = {
  title: PropTypes.string.isRequired,
  content: PropTypes.node,
  wrapperClassName: PropTypes.string,
  contentClassName: PropTypes.string
}

AlternativeGreyBox.defaultProps = {
  wrapperClassName: '',
  contentClassName: '',
  content: ['']
}
