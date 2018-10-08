import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import { userActions, appActions } from '../../../actions'

class PricingList extends PureComponent {
  constructor(props) {
    super(props);
    this.state = {  }
  }

  componentDidMount() {
    const { pricings, userDispatch } = this.props
    if (!pricings || (pricings && pricings.index.length === 0)) {
      userDispatch.getPricings(false)
    }
  }

  render() { 

    const columns = [
      {
        Header: t('common:routing'),
        columns: [
          {
            Header: t('common:origin'),
            accessor: "origin_hub.name"
          },
          {
            Header: t('common:destination'),
            id: "destination_hub.name",
            accessor: d => d.lastName
          }
        ]
      },
    ]
    return ( 
      <div className="flex-100 layout-row layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">{t('common:pricings')}</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <ReactTable

          />
        </div>

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
    pricings
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

 
export default translate(['common'])(connect(mapStateToProps, mapDispatchToProps)(PricingList));