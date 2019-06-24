import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { set } from 'lodash'
import { clientsActions } from '../../../../actions'
import styles from './index.scss'
import AdminScopeEditorRow from './Row'
import AdminScopeEditorHashRow from './HashRow'
import GreyBox from '../../../GreyBox/GreyBox'

class AdminScopesEditor extends Component {
  static getDerivedStateFromProps (nextProps, prevState) {
    const nextState = {}
    const { targetScope, serviceScope } = nextProps.scopes
    if (nextProps.scopeToEdit && !prevState.scopeToEdit) {
      nextState.scopeToEdit = targetScope
    }
    nextState.serviceScope = serviceScope

    return nextState
  }

  constructor (props) {
    super(props)
    this.state = {
    }
    this.handleScopeChange = this.handleScopeChange.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch, match } = this.props
    const { targetId, targetType } = match.params
    clientsDispatch.fetchTargetScope({ targetId, targetType })
  }

  determineRowToRender (key) {
    const { scopes } = this.props
    const { selectOptions } = scopes
    const { serviceScope, scopeToEdit } = this.state

    if (typeof serviceScope[key] === 'object') {
      return (
        <AdminScopeEditorHashRow
          data={serviceScope[key]}
          scopeKey={key}
          selectedValue={serviceScope[key]}
          selectOptions={selectOptions[key]}
          handleChange={this.handleScopeChange}
        />
      )
    }

    return (
      <AdminScopeEditorRow
        data={serviceScope[key]}
        scopeKey={key}
        selectedValue={serviceScope[key]}
        selectOptions={selectOptions[key]}
        handleChange={this.handleScopeChange}
      />
    )
  }

  handleScopeChange (target, value) {
    const { scopeToEdit } = this.state
    set(scopeToEdit, target, value)
    this.setState({ scopeToEdit })
  }

  render () {
    const {
      t, tenant
    } = this.props
    const { serviceScope } = this.state
    if (!serviceScope) { return '' }

    return (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap">
        <GreyBox
          wrapperClassName="flex-90 layout-row"
          contentClassName="layout-row layout-wrap flex-100 layout-align-center-center"
        >
          <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.filter_row}`}>
            <div className="flex-25 layout-row layout-align-center-center layout-wrap">
              <h4 className="flex-none">{t('admin:filters')}</h4>
            </div>

          </div>
          <div className="flex-100 layout-row layout-align-center-center layout-wrap">
            {Object.keys(serviceScope).map(k => this.determineRowToRender(k))}
          </div>
        </GreyBox>

      </div>
    )
  }
}

AdminScopesEditor.defaultProps = {
  compact: false,
  scopes: {}
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { scopes } = clients
  const { tenant } = app
  const { theme } = tenant

  return {
    scopes,
    tenant,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminScopesEditor))
