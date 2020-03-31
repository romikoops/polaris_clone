import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import { AdminHubsIndex, AdminHubView } from '..'
import AdminUploadsSuccess from '../Uploads/Success'
import { adminActions, documentActions, appActions } from '../../../actions'
import GenericError from '../../ErrorHandling/Generic'

class AdminHubs extends Component {
  constructor (props) {
    super(props)
    this.viewHub = this.viewHub.bind(this)
    this.closeSuccessDialog = this.closeSuccessDialog.bind(this)
  }

  componentDidMount () {
    const { match, setCurrentUrl } = this.props
    setCurrentUrl(match.url)
  }

  viewHub (hub) {
    const { adminDispatch } = this.props
    adminDispatch.getHub(hub.id, true)
  }

  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }

  render () {
    const {
      theme,
      hubs,
      hub,
      hubHash,
      adminDispatch,
      document,
      documentDispatch,
      tenant,
      user
    } = this.props

    const uploadStatus = document.viewer ? (
      <AdminUploadsSuccess
        theme={theme}
        data={document.results}
        closeDialog={this.closeSuccessDialog}
      />
    ) : (
      ''
    )
    const scope = tenant ? tenant.scope : {}

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          {uploadStatus}
          <Switch className="flex">
            <Route
              exact
              path="/admin/hubs"
              render={props => (
                <AdminHubsIndex
                  theme={theme}
                  adminDispatch={adminDispatch}
                  {...props}
                  user={user}
                  viewHub={this.viewHub}
                  scope={scope}
                  documentDispatch={documentDispatch}
                />
              )}
            />
            <Route
              exact
              path="/admin/hubs/:id"
              render={props => (
                <AdminHubView
                  theme={theme}
                  hubs={hubs}
                  hubHash={hubHash}
                  hubData={hub}
                  adminActions={adminDispatch}
                  {...props}
                />
              )}
            />
          </Switch>
        </div>
      </GenericError>
    )
  }
}

AdminHubs.defaultProps = {
  theme: null,
  hubs: null,
  loading: false,
  hub: null,
  hubHash: null,
  tenant: {},
  countries: [],
  numHubPages: 1
}

function mapStateToProps (state) {
  const {
    authentication, admin, document, app
  } = state
  const { user, loggedIn } = authentication
  const {
    clients, hubs, hub, num_hub_pages // eslint-disable-line
  } = admin
  const { countries, tenant } = app

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    hub,
    numHubPages: num_hub_pages,
    countries,
    clients,
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    documentDispatch: bindActionCreators(documentActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminHubs)
