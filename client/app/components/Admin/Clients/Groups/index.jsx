import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import { AdminClientMargins } from '..'
import Checkbox from '../../../Checkbox/Checkbox'
import NamedSelect from '../../../NamedSelect/NamedSelect'

class AdminClientGroups extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      groupId: null,
      showCreator: true
    }
    this.fetchData = this.fetchData.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch, targetId, targetType } = this.props
    clientsDispatch.getGroupsForList({ page: 1, pageSize: 10, targetId, targetType })
  }

  handleClick (id) {
    const { clientsDispatch, handleClick } = this.props

    if (handleClick) {
      return handleClick(id)
    }
    clientsDispatch.goTo(`/admin/clients/groups/${id}`)
    this.setState({ groupId: id })
  }

  determineSubTable (row) {
    const { withMargins } = this.props
    if (withMargins) {
      return (
        <div className={styles.nested_table}>
          <AdminClientMargins
            targetId={row.original.id}
            targetType='group'
            className={styles.nested_table}
          />
        </div>
      )
    }

    return ''
  }

  fetchData (tableState) {
    const { clientsDispatch, targetId, targetType } = this.props

    clientsDispatch.getGroupsForList({
      targetId,
      targetType,
      page: tableState.page + 1,
      filters: tableState.filtered,
      pageSize: tableState.pageSize
    })

    this.setState({ filters: tableState.filtered })
  }

  render () {
    const {
      groupData, t, page, numPages, isPage, addedMembers, theme, targetId
    } = this.props

    const columns = [
      {
        Header: t('admin:groupName'),
        accessor: 'name',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.name}
            </p>
          </div>
        )
      },
      {
        id: 'memberCount',
        Header: t('admin:memberCount'),
        accessor: 'memberCount',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.memberCount}
            </p>
          </div>
        )
      },
      {
        id: 'marginCount',
        Header: t('admin:marginCount'),
        accessor: 'marginCount',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.marginCount}
            </p>
          </div>
        )
      }
    ]
    
    if (addedMembers) {
      columns.push({
        id: 'added',
        Header: t('admin:added'),
        accessor: d => addedMembers.map(a => a.id).includes(d.id),
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
          >
            <Checkbox
              checked={rowData.row.added}  
              theme={theme}
              onChange={() => this.handleClick(rowData.original.id)}
            />
          </div>
        ),
        maxWidth: 75
      })
    }
    const table = (
      <ReactTable
        className="flex-100 height_100"
        data={groupData.filter(g => g.id !== targetId)}
        columns={columns}
        defaultSorted={[
          {
            id: 'name',
            desc: true
          }
        ]}
        defaultPageSize={10}
        filterable
        pages={numPages}
        manual
        onFetchData={this.fetchData}
        expanded={this.state.expanded}
        onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
        SubComponent={subRow => this.determineSubTable(subRow)}
      />
    )
    const wrapperClasses = isPage ? 'flex-100 layout-row layout-align-center-center header_buffer extra_padding'
    : 'flex-100 layout-row layout-align-center-center'
    return (
      <div className={wrapperClasses}>
        { table }
      </div>
    )
  }
}

AdminClientGroups.defaultProps = {
  groupData: []
}

function mapStateToProps (state) {
  const { clients, app } = state
  const  { theme } = app.tenant
  const { groups, margins, users } = clients
  const { groupData, numPages, page } = groups || {}

  return {
    groups,
    margins,
    groupData,
    numPages,
    page,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientGroups))
