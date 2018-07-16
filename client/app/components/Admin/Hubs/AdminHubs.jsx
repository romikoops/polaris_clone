import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../../prop-types'
import { AdminHubsIndex, AdminHubView, AdminHubForm } from '../'
import { AdminUploadsSuccess } from '../Uploads/Success'
import { adminActions, documentActions, appActions } from '../../../actions'
// import styles from '../Admin.scss'

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
  }
  componentDidMount () {
    const {
      hubs, adminDispatch, loading, countries, appDispatch
    } = this.props
    if (!hubs && !loading) {
      adminDispatch.getHubs(false)
    }
    if (!countries.length) {
      appDispatch.fetchCountries()
    }
  }
  getHubsFromPage (page, hubType, country, status) {
    const { adminDispatch } = this.props
    adminDispatch.getHubs(false, page, hubType, country, status)
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
  saveNewHub (hub, location) {
    const { adminDispatch } = this.props
    adminDispatch.saveNewHub(hub, location)
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
      numHubPages
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

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {uploadStatus}
        {this.state.newHub ? (
          <AdminHubForm theme={theme} close={this.closeModal} saveHub={this.saveNewHub} />
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
                toggleNewHub={this.toggleNewHub}
                viewHub={this.viewHub}
                numHubPages={numHubPages}
                documentDispatch={documentDispatch}
                getHubsFromPage={this.getHubsFromPage}
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
    )
  }
}
AdminHubs.propTypes = {
  theme: PropTypes.theme,
  hub: PropTypes.hub,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  hubs: PropTypes.arrayOf(PropTypes.hub),
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired,
  loading: PropTypes.bool,
  countries: PropTypes.arrayOf(PropTypes.any),
  numHubPages: PropTypes.number,
  appDispatch: PropTypes.shape({
    fetchCountries: PropTypes.func
  }).isRequired,
  adminDispatch: PropTypes.shape({
    getHubs: PropTypes.func,
    saveNewHub: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    uploadPricings: PropTypes.func
  }).isRequired,
  document: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminHubs.defaultProps = {
  theme: null,
  hubs: null,
  loading: false,
  hub: null,
  hubHash: null,
  countries: [],
  numHubPages: 1
}

function mapStateToProps (state) {
  const {
    authentication, tenant, admin, document, app
  } = state
  const { user, loggedIn } = authentication
  const {
    clients, hubs, hub, num_hub_pages
  } = admin
  const { countries } = app

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
