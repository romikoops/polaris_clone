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
    this.state = { 
      expanded: {}
     }
  }

  componentDidMount() {
    const { pricings, userDispatch } = this.props
    if (!pricings || (pricings && pricings.index && pricings.index.itineraries.length === 0)) {
      userDispatch.getPricings(false)
    }
  }

  generateSubComponent (row) {
    const { pricings, userDispatch } = this.props
    const rowId = row.original.id
    if (!pricings.show || (pricings.show && !pricings.show[rowId])) {
      userDispatch.getPricingsForItinerary(rowId)
      return ''
    }
    const { show } = pricings
    
    const data = show[rowId]
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
      }
    ]
    console.log(this.state.expanded)
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
                 id: 'origin_name',
                 desc: true
               }
             ]}
             expanded={this.state.expanded}
             onExpandedChange={expanded => this.setState({ expanded })}
             defaultPageSize={20}
             SubComponent={d => (<div className="flex"></div>)}
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