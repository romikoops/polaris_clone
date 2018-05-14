import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../prop-types'
import { AdminTruckingIndex, AdminTruckingView, AdminTruckingCreator } from './'
import { adminActions } from '../../actions'
import { history } from '../../helpers'

class AdminTrucking extends Component {
  static backToIndex () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.state = {
      creatorView: false
    }
    this.viewTrucking = this.viewTrucking.bind(this)
    this.toggleCreator = this.toggleCreator.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  viewTrucking (hub) {
    const { adminDispatch } = this.props
    adminDispatch.viewTrucking(hub.id)
  }
  toggleCreator () {
    this.setState({ creatorView: !this.state.creatorView })
  }

  render () {
    const {
      theme, adminDispatch, trucking, loading, truckingDetail, hubs
    } = this.props
    if (!trucking) {
      return ''
    }
    const { truckingNexuses, nexuses } = trucking
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Switch className="flex">
          <Route
            exact
            path="/admin/trucking"
            render={props => (
              <AdminTruckingIndex
                theme={theme}
                truckingNexuses={truckingNexuses}
                {...props}
                hubs={hubs}
                adminDispatch={adminDispatch}
                loading={loading}
                viewTrucking={this.viewTrucking}
              />
            )}
          />
          <Route
            exact
            path="/admin/trucking/:id"
            render={props => (
              <AdminTruckingView
                theme={theme}
                nexuses={nexuses}
                truckingDetail={truckingDetail}
                loading={loading}
                adminDispatch={adminDispatch}
                {...props}
              />
            )}
          />
          <Route
            exact
            path="/admin/trucking/new/creator"
            render={props => (
              <AdminTruckingCreator
                theme={theme}
                nexuses={nexuses}
                hub={truckingDetail.hub}
                adminDispatch={adminDispatch}
                closeForm={this.toggleCreator}
              />
            )}
          />
        </Switch>
      </div>
    )
  }
}

AdminTrucking.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    viewTrucking: PropTypes.func
  }).isRequired,
  trucking: PropTypes.shape({
    truckingHubs: PropTypes.array,
    truckingPrices: PropTypes.array
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired,
  loading: PropTypes.bool,
  truckingDetail: PropTypes.shape({ truckingHub: PropTypes.object, pricing: PropTypes.object })
}

AdminTrucking.defaultProps = {
  theme: null,
  hubs: [],
  hubHash: {},
  loading: false,
  truckingDetail: null
}

function mapStateToProps (state) {
  const { authentication, tenant, admin } = state
  const { user, loggedIn } = authentication
  const {
    hubs, trucking, truckingDetail, loading
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    trucking,
    loading,
    truckingDetail
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminTrucking)
