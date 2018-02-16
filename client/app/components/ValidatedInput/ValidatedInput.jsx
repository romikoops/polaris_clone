import React from 'react'
import Formsy from 'formsy-react'
import PropTypes from 'prop-types'
import ValidatedInputFormsy from '../ValidatedInputFormsy/ValidatedInputFormsy'

export function ValidatedInput (props) {
  return (
    <Formsy className={props.className || props.wrapperClassName}>
      <ValidatedInputFormsy {...props} />
    </Formsy>
  )
}

export default ValidatedInput

ValidatedInput.propTypes = {
  className: PropTypes.string,
  wrapperClassName: PropTypes.string
}

ValidatedInput.defaultProps = {
  className: '',
  wrapperClassName: ''
}
