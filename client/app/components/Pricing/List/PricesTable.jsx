import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import { userActions, appActions } from '../../../actions'

class PricesTable extends PureComponent {
  constructor(props) {
    super(props);
    this.state = {  }
  }

  componentDidMount() {
    const { pricings, userDispatch, row } = this.props
    if (!pricings || (pricings && pricings.index && pricings.index.itineraries.length === 0)) {
      userDispatch.getPricings(false)
    }
  }



  render() { 
    const { t, pricings } = this.props
    if (!pricings) return ''
    const { show } = pricings
    debugger
    const data = show[row.id]
    if (!data) return ''
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
      <ReactTable
             className="flex-100 height_100"
             data={itineraries}
             columns={columns}
             defaultSorted={[
               {
                 id: 'origin_name',
                 desc: true
               }
             ]}
             defaultPageSize={20}
             SubComponent={row => this.generateSubComponent(row)}
          />
    )
  }
}

PricesTable.proptypes = {
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

 
export default translate(['common'])(connect(mapStateToProps, mapDispatchToProps)(PricesTable));