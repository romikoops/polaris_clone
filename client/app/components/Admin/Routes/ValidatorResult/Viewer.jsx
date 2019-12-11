import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminActions, appActions } from '../../../../actions'
import ValidatorGroupResult from './GroupResult'

class ValidatorResultsViewer extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {}
   
  }

  render () {
    const {
      t, validationResult
    } = this.props
    

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap">
        { validationResult.map(groupResult => <ValidatorGroupResult data={groupResult} />)}
      </div>
    )
  }
}

function mapStateToProps (state) {
  const {
    app, admin
  } = state
  const { tenant } = app
  const { theme } = tenant
  const {
    itinerary
  } = admin
  const { validationResult } = itinerary || {}

  return {
    tenant,
    theme,
    itinerary: itinerary.itinerary,
    validationResult
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'admin'])(connect(mapStateToProps, mapDispatchToProps)(ValidatorResultsViewer))
