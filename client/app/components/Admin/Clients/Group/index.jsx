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
import GreyBox from '../../../GreyBox/GreyBox'
import SquareButton from '../../../SquareButton'
import FileUploader from '../../../FileUploader/FileUploader'
import TextHeading from '../../../TextHeading/TextHeading'
import { AdminClientMarginPreview } from '..'

class AdminClientGroup extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editUsers: false,
      currentView: 'members',
      editMargins: false
    }
    this.getItineraryNameFromMargin = this.getItineraryNameFromMargin.bind(this)
    this.toggleMarginEdit = this.toggleMarginEdit.bind(this)
    this.viewMember = this.viewMember.bind(this)
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
    const { id, human_type } = original
    const { clientsDispatch } = this.props
    switch (human_type) {
      case 'user':
        clientsDispatch.goTo(`/admin/clients/client/${id}`)
        break
      case 'company':
        clientsDispatch.goTo(`/admin/clients/companies/${id}`)
        break
      case 'group':
        clientsDispatch.goTo(`/admin/clients/groups/${id}`)
        break

      default:
        break
    }
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

  render () {
    const {
      member_list, t, name, id, margins_list, theme
    } = this.props

    const { editUsers, currentView, editMargins } = this.state
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
      }
    ]

    const userTable = editUsers ? <AdminClientAdder close={() => this.toggleUserEdit()} groupId={id} /> : (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap ">
        <ReactTable
          className="flex height_100"
          data={member_list}
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
    const view = currentView === 'margins' ? (
      <AdminClientMargins
        targetId={id}
        targetType="group"
        editable={editMargins}
        toggleEdit={this.toggleMarginEdit}
      />
    ) : userTable

    const rightButtons = currentView === 'margins' ? [
      (<div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:editMargins')}
          theme={theme}
          handleNext={() => this.toggleMarginEdit()}
          size="small"
          border
          active
        />
      </div>)
      ,
      (<div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:newMargins')}
          theme={theme}
          handleNext={() => this.newMargin()}
          size="small"
          border
          active
        />
      </div>
      )
      ,
      (
        <FileUploader
          text={t('admin:uploadGroupMargins')}
          theme={theme}
          dispatchFn={file => this.uploadMargins(file)}
          size="small"
          active
          square
        />
      )
    ] : [
      (<div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:editMembers')}
          theme={theme}
          handleNext={() => this.toggleUserEdit()}
          size="small"
          border
          active
        />
      </div>)
    ]
    const statBoxes = groupBy(member_list, m => m.human_type)

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap ">
        <div className="flex layout-row layout-wrap padd_20">
          <div className={`flex-100 layout-row ${styles.group_header}`}>
            <h2 className="flex-none">
              {`${t('admin:groupName')}: `}
            </h2>
            <h1 className="flex-none">
              {' '}
              {name}
              {' '}
            </h1>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-45 layout-row layout-align-center-center">
              <GreyBox
                wrapperClassName="flex tile_padding pointy"
                contentClassName="flex layout-row layout-align-center-center"
                onClick={() => this.setView('members')}
              >
                <i className="flex-none fa fa-users" />
                <p
                  className="flex center"

                >
                  {t('admin:members')}
                </p>
              </GreyBox>
            </div>
            <div className="flex-45 layout-row layout-align-center-center">
              <GreyBox
                wrapperClassName="flex tile_padding pointy"
                contentClassName="flex layout-row layout-align-center-center"
                onClick={() => this.setView('margins')}
              >
                <i className="flex-none fa fa-percent" />
                <p
                  className="flex center"

                >
                  {t('admin:margins')}
                </p>
              </GreyBox>
            </div>
          </div>
          <div className="flex-100 layout-row layout-aling-center-start layout-wrap margin_top">
            {view}
          </div>
        </div>
        <div className="flex-20 layout-row layout-wrap padd_20 layout-align-center-start">
          <div className={`flex-100 layout-row ${styles.group_header}`}>
            <h2 className="flex-none">
              {`${t('admin:groupDetails')}: `}
            </h2>
          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap">
            {
              Object.entries(statBoxes).map(statArr => (
                <div
                  className={`flex-100 five_m layout-row layout-align-start-center ${styles.stat_box}`}
                >
                  <h4
                    className="flex"
                  >
                    {`${t(`admin:${statArr[0]}Count`)}: ${statArr[1].length}`}
                  </h4>
                </div>
              ))
            }

            <div
              className={`flex-100 five_m layout-row layout-align-center-center ${styles.stat_box}`}
            >
              <h4
                className="flex"
              >
                {`${t(`admin:marginCount`)}: ${margins_list.length}`}
              </h4>
            </div>

          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap tile_padding">
            <div className={`flex-100 layout-align layout-row ${styles.group_header}`}>
              <h2 className="flex-none">
                {`${t('admin:groupActions')}: `}
              </h2>
            </div>
            {rightButtons}
          </div>

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
AdminClientGroup.defaultProps = {
  member_list: [],
  margins_list: []
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { group } = clients
  const { theme } = app.tenant
  const {
    name,
    margins_list,
    member_list,
    itineraries,
    pricings,
    id
  } = group || {}

  return {
    name,
    margins_list,
    member_list,
    itineraries,
    pricings,
    id,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch),
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientGroup))