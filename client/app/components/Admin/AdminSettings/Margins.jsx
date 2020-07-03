import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './AdminSettings.scss'
import { AdminClientMargins } from '../Clients'
import GreyBox from '../../GreyBox/GreyBox'

class AdminMargins extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editable: true
    }
    this.toggleEditable = this.toggleEditable.bind(this)
  }

  toggleEditable () {
    this.setState((prevState) => ({ editable: !prevState.editable }))
  }

  render () {
    const { t, tenant } = this.props
    const { editable } = this.state

    return (
      <div className="flex-100 layout-row layout-align-space-between-center layout-wrap padd_20">
        { !editable && (
          <div className="flex-100 layout-row layout-align-end buffer_10">
            <GreyBox
              id="editButton"
              wrapperClassName="flex-20 layout-row pointy"
              contentClassName="flex layout-row layout-align-center-center pointy"
              onClick={this.toggleEditable}
            >
              <i className="flex-none fa fa-pencil" />
              <p className="flex-none">{t('admin:edit')}</p>
            </GreyBox>
          </div>
        ) }
        <AdminClientMargins
          toggleEdit={this.toggleEditable}
          editable={editable}
          targetId={tenant.id}
          targetType="tenant"
        />
      </div>
    )
  }
}

AdminMargins.defaultProps = {
  theme: {},
  savedEmailSuccess: false
}
export default withNamespaces(['admin', 'common', 'user', 'errors'])(AdminMargins)
