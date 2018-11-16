import React, {Component} from 'react'
import { translate } from 'i18next'
import PropTypes from 'prop-types'
import { Modal } from '../../Modal/Modal'


class AdminEmailEditor extends Component {
  constructor(props) {
    super(props)
    this.state {
      updateEmail: false
    }
  }

  toggleUpdate () {

  }

  updateEmail () {
    this.state.updateEmail: true
  }

  render() {
    const {t, scope} = this.props
  }

  return () {
    <div>
      <Modal
        component={
          <AdminEmailForm theme={theme} close={this.toggleUpdate} saveEmail={this.updateEmail} tenant={tenant} />
          }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleUpdate}
      />
    </div>
  }
}

AdminEmailEditor.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.tenant.isRequired,
  adminDispatch: PropTypes.shape({
    updateEmails: PropTypes.func
  }).isRequired
}

AdminEmailEditor.defaultProps = {
  theme: {}
}
export default translate()(AdminEmailEditor)