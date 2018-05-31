import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../../prop-types'
import { AdminHubsIndex, AdminHubView, AdminHubForm } from '../'
import { AdminUploadsSuccess } from '../Uploads/Success'
import { adminActions, documentActions } from '../../../actions'
import { TextHeading } from '../../TextHeading/TextHeading'
import styles from '../Admin.scss'

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
  }
  componentDidMount () {
    const { hubs, adminDispatch, loading } = this.props
    if (!hubs && !loading) {
      adminDispatch.getHubs(false)
    }
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
      hub,
      hubHash,
      adminDispatch,
      document,
      documentDispatch
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
        <div className={`flex-100 layout-row layout-wrap layout-align-space-between-center ${styles.sec_title}`}>
          <TextHeading theme={theme} size={1} text="Hubs" />
        </div>
        {/* <div className="flex-none layout-row layout-align-start-center">
                  {showTooltip ? (
                    <Tooltip icon="na-info-circle" theme={theme} toolText={truckTip.hubs} />
                  ) : (
                    ''
                  )}
                  {icon ? <Tooltip theme={theme} icon={icon} toolText={tooltip} /> : ''}
                </div> */}
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
                hubHash={hubHash}
                adminDispatch={adminDispatch}
                {...props}
                toggleNewHub={this.toggleNewHub}
                viewHub={this.viewHub}
                documentDispatch={documentDispatch}
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
  hubHash: null
}

function mapStateToProps (state) {
  const {
    authentication, tenant, admin, document
  } = state
  const { user, loggedIn } = authentication
  const { clients, hubs, hub } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    hub,
    clients,
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminHubs)
