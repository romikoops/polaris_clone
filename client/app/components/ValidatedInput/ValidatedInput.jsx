import React from 'react'
import Formsy from 'formsy-react'
import PropTypes from 'prop-types'
import ValidatedInputFormsy from '../ValidatedInputFormsy/ValidatedInputFormsy'

function ValidatedInput (props) {
  return (
    <Formsy className={props.wrapperClassName}>
      <ValidatedInputFormsy {...props} />
    </Formsy>
  )
}

export default ValidatedInput

ValidatedInput.propTypes = {
  wrapperClassName: PropTypes.string
}

ValidatedInput.defaultProps = {
  wrapperClassName: ''
}
