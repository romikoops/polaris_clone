import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../../prop-types'
import { AdminHubsIndex, AdminHubView, AdminHubForm } from '../'
import AdminUploadsSuccess from '../Uploads/Success'
import { adminActions, documentActions, appActions } from '../../../actions'
import { Modal } from '../../Modal/Modal'
import GenericError from '../../../components/ErrorHandling/Generic'

class AdminHubs extends Component {
  constructor (props) {
    super(props)
    this.state = {
      newHub: false
    }
    this.viewHub = this.viewHub.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.toggleNewHub = this.toggleNewHub.bind(this)
    this.saveNewHub = this.saveNewHub.bind(this)
    this.closeModal = this.closeModal.bind(this)
    this.closeSuccessDialog = this.closeSuccessDialog.bind(this)
    this.getHubsFromPage = this.getHubsFromPage.bind(this)
    this.searchHubsFromPage = this.searchHubsFromPage.bind(this)
  }
  componentDidMount () {
    const {
      hubs, adminDispatch, loading, countries, appDispatch, match
    } = this.props
    if (!hubs && !loading) {
      adminDispatch.getHubs(false)
    }
    if (!countries.length) {
      appDispatch.fetchCountries()
    }
    this.props.setCurrentUrl(match.url)
  }
  getHubsFromPage (page, hubType, country, status) {
    const { adminDispatch } = this.props
    adminDispatch.getHubs(false, page, hubType, country, status)
  }
  searchHubsFromPage (text, page, hubType, country, status) {
    const { adminDispatch } = this.props
    adminDispatch.searchHubs(text, page, hubType, country, status)
  }
  fetchCountries () {
    const { appDispatch } = this.props
    appDispatch.fetchCountries()
  }
  viewHub (hub) {
    const { adminDispatch } = this.props
    adminDispatch.getHub(hub.id, true)
  }
  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }
  backToIndex () {
    const { adminDispatch } = this.props
    adminDispatch.goTo('/admin/hubs')
  }
  toggleNewHub () {
    this.setState({ newHub: !this.state.newHub })
  }
  closeModal () {
    this.setState({ newHub: false })
  }
  saveNewHub (hub, address) {
    const { adminDispatch } = this.props
    adminDispatch.saveNewHub(hub, address)
  }

  render () {
    const {
      theme,
      hubs,
      countries,
      hub,
      hubHash,
      adminDispatch,
      document,
      documentDispatch,
      numHubPages,
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
          {this.state.newHub ? (
            <Modal
              component={
                <AdminHubForm theme={theme} close={this.toggleNewHub} saveHub={this.saveNewHub} />
              }
              verticalPadding="30px"
              horizontalPadding="40px"
              parentToggle={this.toggleNewHub}
            />

          ) : (
            ''
          )}
          <Switch className="flex">
            <Route
              exact
              path="/admin/hubs"
              render={props => (
                <AdminHubsIndex
                  theme={theme}
                  hubs={hubs}
                  countries={countries}
                  adminDispatch={adminDispatch}
                  {...props}
                  user={user}
                  toggleNewHub={this.toggleNewHub}
                  viewHub={this.viewHub}
                  scope={scope}
                  numHubPages={numHubPages}
                  documentDispatch={documentDispatch}
                  getHubsFromPage={this.getHubsFromPage}
                  searchHubsFromPage={this.searchHubsFromPage}
                />
              )}
            />
            <Route
              exact
              path="/admin/hubs/:id"
              render={props => (
                <AdminHubView
                  setView={this.setView}
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
