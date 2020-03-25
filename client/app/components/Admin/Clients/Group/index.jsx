import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get, groupBy } from 'lodash'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { clientsActions, documentActions } from '../../../../actions'
import styles from '../index.scss'
import AdminClientAdder from '../Adder'
import AdminClientMargins from '../Margins'
import SquareButton from '../../../SquareButton'
import { AdminClientMarginPreview } from '..'
import AdminPricesGroupTable from '../../Pricing/GroupTable'
import AdminPricesGroupLocalCharges from '../../Pricing/GroupLocalCharges'
import Tab from '../../../Tabs/Tab'
import Tabs from '../../../Tabs/Tabs'
import MarginButtons from './MarginButtons'
import PricingButtons from './PricingButtons'
import LocalChargeButtons from './LocalChargeButtons'
import { RoundButton } from '../../../RoundButton/RoundButton'
import { LoadingSpinner } from '../../../LoadingSpinner/LoadingSpinner'
import GroupName from './GroupName'

class AdminClientGroup extends Component {
  static defaultProps = {
    memberList: [],
    marginsList: []
  }

  constructor (props) {
    super(props)
    this.state = {
      editUsers: false,
      currentView: 'members',
      editMargins: false
    }
    this.getItineraryNameFromMargin = this.getItineraryNameFromMargin.bind(this)
    this.toggleMarginEdit = this.toggleMarginEdit.bind(this)
    this.newMargin = this.newMargin.bind(this)
    this.uploadMargins = this.uploadMargins.bind(this)
    this.uploadGroupPricings = this.uploadGroupPricings.bind(this)
    this.uploadGroupLocalCharges = this.uploadGroupLocalCharges.bind(this)
    this.viewMember = this.viewMember.bind(this)
    this.editGroupName = this.editGroupName.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    const id = get(this.props, ['match', 'params', 'id'], '')
    clientsDispatch.viewGroup(id)
  }

  getItineraryNameFromMargin (margin) {
    const { pricings, itineraries } = this.props
    const pricing = pricings.filter(p => p.id === margin.pricing_id)[0]
    const itinerary = itineraries.filter(it => it.id === pricing.itinerary_id)[0]

    return get(itinerary, ['name'], '')
  }

  setView (view) {
    this.setState({ currentView: view })
  }

  viewMember (row) {
    const { original } = row
    const { original_member_id, human_type } = original
    const { clientsDispatch } = this.props

    switch (human_type) {
      case 'client':
        clientsDispatch.goTo(`/admin/clients/client/${original_member_id}`)
        break
      case 'company':
        clientsDispatch.goTo(`/admin/clients/companies/${original_member_id}`)
        break
      case 'group':
        clientsDispatch.goTo(`/admin/clients/groups/${original_member_id}`)
        break

      default:
        break
    }
  }

  removeMembership (rowData) {
    const { original } = rowData
    const { id } = original
    const { clientsDispatch } = this.props
    clientsDispatch.removeMembership(id)
  }

  newMargin () {
    const { clientsDispatch, id } = this.props
    clientsDispatch.newMarginFromGroup(id)
  }

  toggleUserEdit () {
    const { clientsDispatch, id } = this.props
    this.setState((prevState) => {
      if (prevState.editUsers) {
        clientsDispatch.viewGroup(id)
      }

      return { editUsers: !prevState.editUsers }
    })
  }

  toggleMarginEdit () {
    const { clientsDispatch, id } = this.props
    this.setState((prevState) => {
      if (prevState.editMargins) {
        clientsDispatch.viewGroup(id)
      }

      return { editMargins: !prevState.editMargins }
    })
  }

  uploadMargins (file) {
    const { documentDispatch, id } = this.props
    const args = {
      file,
      targetId: id,
      targetType: 'group'
    }
    documentDispatch.uploadMargins(args)
  }

  uploadGroupPricings (file) {
    const { documentDispatch, id } = this.props
    const args = {
      file,
      groupId: id
    }
    documentDispatch.uploadGroupPricings(args)
  }

  uploadGroupLocalCharges (file) {
    const { documentDispatch, id } = this.props
    documentDispatch.uploadLocalCharges(file, '', id)
  }

  editGroupName (name) {
    const { clientsDispatch, id } = this.props
    clientsDispatch.editGroupName(id, name)
  }

  render () {
    const {
      memberList,
      t,
      name,
      id,
      theme,
      loading
    } = this.props

    const { editUsers, editMargins } = this.state
    const userColumns = [
      {
        id: 'member_name',
        Header: t('admin:name'),
        accessor: 'member_name',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.viewMember(rowData)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.member_name}
            </p>
          </div>
        )
      },
      {
        id: 'member_email',
        Header: t('admin:email'),
        accessor: 'member_email',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.viewMember(rowData)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.member_email || '-'}
            </p>
          </div>
        )
      },
      {
        id: 'human_type',
        Header: t('admin:type'),
        accessor: 'human_type',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.viewMember(rowData)}
          >
            <p className="flex-none">
              {' '}
              {t(`admin:${rowData.row.human_type}`) || '-'}
            </p>
          </div>
        )
      },
      {
        id: 'remove_member',
        Header: t('admin:removeMembership'),
        accessor: 'remove_member',
        Cell: (rowData) => (
          <RoundButton
            theme={theme}
            size="full"
            text={t('admin:remove')}
            handleNext={() => this.removeMembership(rowData)}
            iconClass="fa-trash"
            classNames="five_m"
          />
        )
      }
    ]

    const userTable = editUsers ? <AdminClientAdder close={() => this.toggleUserEdit()} groupId={id} /> : (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap ">
        <ReactTable
          className="flex height_100"
          data={memberList}
          columns={userColumns}
          defaultSorted={[
            {
              id: 'fullName',
              desc: true
            }
          ]}
          defaultPageSize={10}
        />
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap ">
        <div className="flex layout-row layout-wrap padd_20">
          <div className={`flex-100 layout-row ${styles.group_header}`}>
            <h2 className="flex-none">
              {`${t('admin:groupName')}: `}
            </h2>
            <GroupName name={name} onEdit={this.editGroupName} />
          </div>
          <Tabs
            wrapperTabs="layout-row flex margin_bottom"
            paddingFixes
          >
            <Tab
              tabTitle={t('admin:members')}
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex flex-xs-100 layout-row">
                  {loading ? <LoadingSpinner size="medium" /> : userTable}
                </div>
                <div className="flex-15 flex-xs-100 layout-row layout-wrap">
                  <div className="flex-100 layout-row layout-align-center-start margin_5">
                    <SquareButton
                      text={t('admin:editMembers')}
                      theme={theme}
                      handleNext={() => this.toggleUserEdit()}
                      size="small"
                      border
                      active
                    />
                  </div>
                </div>
              </div>
            </Tab>
            <Tab
              tabTitle={t('admin:pricings')}
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex flex-xs-100 layout-row">
                  {<AdminPricesGroupTable groupId={id} />}
                </div>
                <div className="flex-15 flex-xs-100 layout-row layout-wrap">
                  <PricingButtons
                    theme={theme}
                    toggleEdit={this.toggleMarginEdit}
                    newFn={this.newMargin}
                    uploadFn={this.uploadGroupPricings}
                    t={t}
                  />
                </div>
              </div>

            </Tab>
            <Tab
              tabTitle={t('admin:localCharges')}
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex flex-xs-100 layout-row">
                  {<AdminPricesGroupLocalCharges groupId={id} />}
                </div>
                <div className="flex-15 flex-xs-100 layout-row layout-wrap">
                  <LocalChargeButtons
                    theme={theme}
                    toggleEdit={this.toggleMarginEdit}
                    newFn={this.newMargin}
                    uploadFn={this.uploadGroupLocalCharges}
                    t={t}
                  />
                </div>
              </div>

            </Tab>
            <Tab
              tabTitle={t('admin:margins')}
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex flex-xs-100 layout-row">
                  <AdminClientMargins
                    targetId={id}
                    targetType="group"
                    editable={editMargins}
                    toggleEdit={this.toggleMarginEdit}
                  />
                </div>
                <div className="flex-15 flex-xs-100 layout-row layout-wrap">
                  <MarginButtons
                    theme={theme}
                    toggleEdit={this.toggleMarginEdit}
                    newFn={this.newMargin}
                    uploadFn={this.uploadMargins}
                    t={t}
                  />
                </div>
              </div>

            </Tab>
          </Tabs>
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center padd_20">
          <AdminClientMarginPreview
            targetId={id}
            targetType="group"
          />
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { group, loading } = clients
  const { theme } = app.tenant
  const {
    name,
    margins_list: marginsList,
    member_list: memberList,
    itineraries,
    pricings,
    id
  } = group || {}

  return {
    name,
    marginsList,
    memberList,
    itineraries,
    pricings,
    id,
    theme,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch),
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientGroup))
