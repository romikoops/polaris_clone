import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../../prop-types'
import { userActions, appActions } from '../../../../actions'

class PricingList extends PureComponent {
  constructor(props) {
    super(props);
    this.state = {  }
  }

  componentWillMount() {
    
  }

  render() { 
    return ( 
      <div className="flex-100 layout-row layout-align-start-start">

      </div>
     );
  }
}

PricingList.proptypes = {
  t: PropTypes.func.isRequired
}

function mapStateToProps (state) {
  const {
    authentication, tenant, users
  } = state
  const { theme } = tenant.data
  const { user, loggedIn } = authentication
  const {
    pricings
  } = users

  return {
    user,
    tenant,
    loggedIn,
    theme,
    pricings,
    countries
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

 
export default translate(['common'])(connect(mapStateToProps, mapDispatchToProps)(PricingList));