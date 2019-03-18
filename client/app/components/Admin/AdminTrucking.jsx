import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../prop-types'
import { AdminTruckingIndex, AdminTruckingView, AdminTruckingCreator } from './'
import { adminActions, appActions } from '../../actions'
import { history } from '../../helpers'
import GenericError from '../../components/ErrorHandling/Generic'

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
  componentWillMount () {
    if (!this.props.trucking) {
      this.props.adminDispatch.getTrucking()
    }
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }

  viewTrucking (hub) {
    const { adminDispatch } = this.props
    adminDispatch.viewTrucking({hubId: hub.id, page: 1})
  }
  toggleCreator () {
    this.setState({ creatorView: !this.state.creatorView })
  }

  render () {
    const {
      theme, adminDispatch, trucking, loading, truckingDetail, hubs, appDispatch
    } = this.props
    if (!trucking) {
      return ''
    }
    const { truckingNexuses, nexuses } = trucking

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <Switch className="flex">
            <Route
              exact
              path="/admin/pricings"
              render={props => (
                <AdminTruckingIndex
                  theme={theme}
                  truckingNexuses={truckingNexuses}
                  {...props}
                  hubs={hubs}
                  adminDispatch={adminDispatch}
                  appDispatch={appDispatch}
                  loading={loading}
                  viewTrucking={this.viewTrucking}
                />
              )}
            />
            <Route
              exact
              path="/admin/pricings/trucking/:id"
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
      </GenericError>
    )
  }
}

AdminTrucking.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    viewTrucking: PropTypes.func,
    getTrucking: PropTypes.func
  }).isRequired,
  trucking: PropTypes.shape({
    truckingHubs: PropTypes.array,
    truckingPrices: PropTypes.array
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  truckingDetail: PropTypes.shape({ truckingHub: PropTypes.object, pricing: PropTypes.object }),
  appDispatch: PropTypes.objectOf(PropTypes.func).isRequired
}

AdminTrucking.defaultProps = {
  theme: null,
  hubs: [],
  hubHash: {},
  loading: false,
  truckingDetail: null
}

function mapStateToProps (state) {
  const { authentication, app, admin } = state
  const { tenant } = app
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
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminTrucking)
