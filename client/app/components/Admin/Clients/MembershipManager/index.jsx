import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get, range } from 'lodash'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import Checkbox from '../../../Checkbox/Checkbox'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import RoundButton from '../../../RoundButton/RoundButton'

class AdminClientMembershipManager extends Component {
  static getDerivedStateFromProps (nextProps, prevState) {
    const { memberships, groupData } = nextProps
    const nextState = {}
    const prioritiesSet = groupData.some(g => g.priority)
    if (!prioritiesSet && memberships && memberships.length > 1) {
      nextState.groups = groupData.map((g) => {
        const targetMembership = memberships.filter(m => m.group_id === g.id)[0]
        const editedGroup = g
        if (targetMembership) {
          editedGroup.priority = targetMembership.priority
        }

        return editedGroup
      }).sort((a,b) => a.priority - b.priority).map((g, i)=> {
        return { ...g, priority: i }
      })
    }

    return nextState
  }

  constructor (props) {
    super(props)
    this.state = {
      groupId: null,
      showCreator: true,
      groups: get(props, ['groupData'], []),
      memberships: get(props, ['memberships'], []),
      addedGroups: get(props, ['addedGroups'], [])
    }
    this.fetchData = this.fetchData.bind(this)
    this.getPriorityOptions = this.getPriorityOptions.bind(this)
    this.handlePriorityChange = this.handlePriorityChange.bind(this)
    this.handleTargetUpdate = this.handleTargetUpdate.bind(this)
    this.saveChanges = this.saveChanges.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch, targetId, targetType } = this.props
    clientsDispatch.getGroupsForList({ page: 1, pageSize: 10 })
    if (targetId) {
      clientsDispatch.membershipData({ targetId, targetType })
    }
  }

  fetchData (tableState) {
    const { clientsDispatch } = this.props

    clientsDispatch.getGroupsForList({
      page: tableState.page + 1,
      filters: tableState.filtered,
      pageSize: tableState.pageSize
    })

    this.setState({ filters: tableState.filtered })
  }

  addMember (id) {
    this.setState((prevState) => {
      const { addedGroups } = prevState

      if (!addedGroups.includes(id)) {
        addedGroups.push(id)
      }

      return { addedGroups }
    })
  }

  removeMember (id) {
    this.setState((prevState) => {
      const { addedGroups } = prevState
      const updatedMembers = addedGroups.filter(c => c !== id)

      return { addedGroups: updatedMembers }
    })
  }

  getPriorityOptions (id) {
    const { memberships } = this.state
    const targetMembership = memberships.filter(m => m.group_id === id)[0]
    if (targetMembership) {
      return range(15).filter(n => n !== targetMembership.priority).map(n => ({ label: n, value: n }))
    }

    return range(15).map(n => ({ label: n, value: n }))
  }

  getSelectedOption (id) {
    const { memberships } = this.state
    const targetMembership = memberships.filter(m => m.group_id === id)[0]

    return {
      label: get(targetMembership, ['priority'], ''),
      value: get(targetMembership, ['priority'], '')
    }
  }

  handleMemberChange (id) {
    const { addedGroups } = this.state
    if (addedGroups.includes(id)) {
      this.removeMember(id)
    } else {
      this.addMember(id)
    }
  }

  handleTargetUpdate () {
    const { clientsDispatch, targetId, targetType } = this.props
    switch (targetType) {
      case 'user':
        clientsDispatch.viewClient(targetId)
        break
      case 'group':
        clientsDispatch.viewGroup(targetId)
        break
      case 'company':
        clientsDispatch.viewCompany(targetId)
        break

      default:
        break
    }
  }

  saveChanges () {
    const { addedGroups, groups } = this.state
    const {
      clientsDispatch, targetId, targetType, toggleEdit
    } = this.props
    const membershipOrder = groups.map(g => ({id: g.id, priority: g.priority}))
    clientsDispatch.editMemberships({
      addedGroups, targetId, targetType, memberships: membershipOrder
    })
    this.handleTargetUpdate()
    toggleEdit()
  }

  handlePriorityChange (id, delta) {
    const { groups } = this.state
    const targetGroupIndex = groups.findIndex(g => g.id === id)
    const indexToChange = targetGroupIndex + delta
    if (indexToChange < 0 || indexToChange >= groups.length) { return }
    groups[targetGroupIndex].priority += delta
    groups[indexToChange].priority -= delta
    const sortedGroups = groups.sort((a,b) => a.priority - b.priority).map((g, i)=> {
      return { ...g, priority: i }
    })
    this.setState({ groups: sortedGroups })
  }

  render () {
    const {
      groupData, t, page, numPages, theme, targetId
    } = this.props
    const {
      groups, addedGroups, memberships
    } = this.state
    const isButtonActive = addedGroups.length > 0 && (groupData.map(e => e.id) !== addedGroups.map(m => m.id))
    const columns = [
      {
        Header: t('admin:groupName'),
        accessor: 'name',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleMemberChange(rowData.original.id)}
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
        Header: t('admin:userCount'),
        accessor: 'memberCount',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleMemberChange(rowData.original.id)}
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
            onClick={() => this.handleMemberChange(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.marginCount}
            </p>
          </div>
        )
      }
    ]
    if (targetId) {
      columns.push({
        id: 'priority',
        Header: t('admin:priority'),
        accessor: 'priority',
        className: styles.select_row,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} ${styles.dpb} flex layout-row layout-align-start-center pointy`}
          >
            { addedGroups.includes(rowData.original.id) ? [
              (<div
                className="flex layout-row layout-align-center-center"
                style={{visibility: rowData.original.priority === 0 ? 'hidden' : 'visible'}}
                onClick={() => this.handlePriorityChange(rowData.original.id, -1)}
              >
                <i className="flex-none fa fa-arrow-up" />
              </div>),
              (<div
                className="flex layout-row layout-align-center-center"
                style={{visibility: rowData.original.priority === addedGroups.length - 1 ? 'hidden' : 'visible'}}
                onClick={() => this.handlePriorityChange(rowData.original.id, 1)}
              >
                <i className="flex-none fa fa-arrow-down" />
              </div>)] : '' }
          </div>
        ),
        maxWidth: 75
      })
    }
    if (addedGroups) {
      columns.push({
        id: 'added',
        Header: t('admin:added'),
        accessor: d => addedGroups.includes(d.id),
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
          >
            <Checkbox
              checked={rowData.row.added}
              theme={theme}
              onChange={() => this.handleMemberChange(rowData.original.id)}
            />
          </div>
        ),
        maxWidth: 75
      })
    }
    const table = (
      <ReactTable
        className="flex-100 height_100"
        data={groups}
        columns={columns}
        defaultSorted={[
          {
            id: 'priority',
            desc: false
          }
        ]}
        defaultPageSize={10}
        filterable
        pages={numPages}
        manual
        onFetchData={this.fetchData}
      />
    )

    return (
      <div className="flex-100 layout-row layout-align-center-center padding_top layout-wrap">
        { table }
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <RoundButton
            handleNext={this.saveChanges}
            text={t('admin:saveChanges')}
            theme={theme}
            size="full"
            active={isButtonActive}
            disabled={!isButtonActive}
          />
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { groups, margins, users } = clients
  const {
    groupData, numPages, page, memberships
  } = groups || {}
  const { tenant } = app
  const { theme } = tenant

  return {
    groups,
    margins,
    groupData,
    numPages,
    page,
    memberships,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientMembershipManager))
