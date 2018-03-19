import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../prop-types'
import { AdminTruckingIndex, AdminTruckingView, AdminTruckingCreator } from './'
// import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions } from '../../actions'
import { history } from '../../helpers'
import { Tooltip } from '../Tooltip/Tooltip'
import { adminTrucking as truckTip } from '../../constants'
import { TextHeading } from '../TextHeading/TextHeading'

class AdminTrucking extends Component {
  static backToIndex () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedRoute: false,
      creatorView: false
    }
    this.viewTrucking = this.viewTrucking.bind(this)
    this.toggleCreator = this.toggleCreator.bind(this)
  }
  viewTrucking (hub) {
    const { adminDispatch } = this.props
    adminDispatch.viewTrucking(hub.id)
    this.setState({ selectedRoute: true })
  }
  toggleCreator () {
    this.setState({ creatorView: !this.state.creatorView })
  }

  render () {
    const { selectedRoute } = this.state
    const {
      theme, adminDispatch, trucking, loading, truckingDetail, hubs
    } = this.props
    if (!trucking) {
      return ''
    }
    const { truckingNexuses, nexuses } = trucking

    const title = selectedRoute ? 'Trucking Overview' : 'Trucking'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-none layout-row layout-align-start-center">
            <div className="flex-none">
              <TextHeading theme={theme} size={1} text={title} />
            </div>
            <Tooltip icon="fa-info-circle" theme={theme} text={truckTip.manage} toolText />
          </div>
        </div>
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
