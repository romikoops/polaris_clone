import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'

class AdminClientMarginsDetailTable extends Component {
  constructor (props) {
    super(props)
    this.state = {
      margins: get(props, ['row', 'original', 'marginDetails'], []),
      editable: false,
      expanded: {}
    }
    this.renderEditable = this.renderEditable.bind(this)
  }

  saveChanges () {
    const { margins } = this.state
    const { clientsDispatch } = this.props
    clientsDispatch.updateMarginValues(margins)
    this.props.toggleEdit()
  }

  renderEditable (cellInfo) {
    const { editable, handleDetailsChange, row } = this.props
    if (!editable) {
      return (
        <div
          className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          dangerouslySetInnerHTML={{
            __html: this.state.margins[cellInfo.index][cellInfo.column.id]
          }}
        />
      )
    }
    if (cellInfo.column.id === 'operator') {
      return (
        <select
          style={{ backgroundColor: '#fafafa' }}
          onChange={(e) => {
            const margins = [...this.state.margins]
            margins[cellInfo.index][cellInfo.column.id] = e.target.value
            handleDetailsChange( row.original.id, margins)
          }}
        >
          <option value="%">%</option>
          <option value="+">+</option>
        </select>
      )
    }

    return (
      <div
        style={{ backgroundColor: '#fafafa' }}
        contentEditable
        suppressContentEditableWarning
        onBlur={(e) => {
          const margins = [...this.state.margins]
          margins[cellInfo.index][cellInfo.column.id] = parseFloat(e.target.innerHTML)
          handleDetailsChange( row.original.id, margins)
        }}
        dangerouslySetInnerHTML={{
          __html: this.state.margins[cellInfo.index][cellInfo.column.id]
        }}
      />
    )
  }

  render () {
    const { t, theme, editable } = this.props
    const { margins } = this.state
    const columns = [
      {
        id: 'feeCode',
        Header: t('admin:feeCode'),
        accessor: d => d.feeCode,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.feeCode}
            </p>
          </div>
        )
      },
      {
        id: 'rateBasis',
        Header: t('admin:rateBasis'),
        accessor: d => d.rateBasis,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.rateBasis || '-'}
            </p>
          </div>
        )
      },
      {
        id: 'value',
        Header: t('admin:margin'),
        accessor: d => `${parseFloat(d.value) * 100}`,
        Cell: this.renderEditable
      },
      {
        id: 'operator',
        Header: t('admin:operator'),
        accessor: d => `${d.operator}`,
        Cell: this.renderEditable
      }
    ]

    return (
      <div className="flex-100 layout-row layout-align-center-center">
        <ReactTable
          className="flex"
          data={margins}
          columns={columns}
          defaultSorted={[
            {
              id: 'feeCode',
              desc: true
            }
          ]}
          defaultPageSize={margins.length}
          showPaginationBottom={false}
        />
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { group } = clients
  const {
    name,
    margins_list,
    users,
    itineraries,
    pricings
  } = group || {}
  const { tenant } = app
  const { theme } = tenant

  return {
    name,
    margins_list,
    users,
    itineraries,
    pricings,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientMarginsDetailTable))
