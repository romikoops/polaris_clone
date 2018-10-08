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
    if (!pricings || (pricings && pricings.index && pricings.index.itineraries.length === 0)) {
      userDispatch.getPricings(false)
    }
  }

  render() { 
    const { t, pricings } = this.props
    if (!pricings) return ''
    const { index } = pricings
    const { itineraries } = index
    
    const columns = [
      {
        Header: t('common:routing'),
        columns: [
          {
            Header: t('common:origin'),
            id: "origin_name",
            accessor: d => d.stops[0].hub.nexus.name
          },
          {
            Header: t('common:destination'),
            id: "destination_name",
            accessor: d => d.stops[1].hub.nexus.name
          }
        ]
      },
      {
        Header: t('common:pricing'),
        columns: [
          {
            Header: t('common:numPricings'),
            accessor: "pricing_count"
          },
          {
            Header: t('common:dedicated'),
            id: "has_user_pricing",
            accessor: d => d.has_user_pricing
          },
          {
            Header: t('common:view'),
            id: "view",
            Cell: d => (<div className="flex">VIEW</div>)
          }
        ]
      },
    ]
    return ( 
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">{t('common:pricings')}</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <ReactTable
             className="flex-100 height_100"
             data={itineraries}
             columns={columns}
             defaultSorted={[
               {
                 id: 'closing_date',
                 desc: true
               }
             ]}
             defaultPageSize={20}
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