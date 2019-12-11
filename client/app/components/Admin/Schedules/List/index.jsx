import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { adminActions } from '../../../../actions'
import { moment } from '../../../../constants'
import GenericError from '../../../ErrorHandling/Generic'

class AdminSchedulesList extends Component {
  constructor (props) {
    super(props)
    this.state = {
    }
  }

  componentWillMount () {
    const { schedules, itineraryId, adminDispatch } = this.props
    if (schedules.length === 0) {
      adminDispatch.loadItinerarySchedules(itineraryId, false)
    }
  }

  componentDidMount () {
    window.scrollTo(0, 0)
  }

  render () {
    const {
      t,
      theme,
      schedules
    } = this.props

    const columns = [
      {
        Header: t('common:closingDate'),
        accessor: 'closing_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: 'ETD',
        accessor: 'start_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: 'ETA',
        accessor: 'end_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: t('admin:serviceLevel'),
        accessor: 'service_level'
      },
      {
        Header: t('admin:carrier'),
        accessor: 'carrier'
      },
      {
        Header: t('admin:voyageCode'),
        accessor: 'voyage_code'
      },
      {
        Header: t('admin:vesselName'),
        accessor: 'vessel'
      }
    ]

    return (
      <GenericError theme={theme}>
        <div className="layout-row flex-95 layout-wrap layout-align-start-center">
          <ReactTable
            className="flex-100 height_100"
            data={schedules}
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
      </GenericError>
    )
  }
}

AdminSchedulesList.defaultProps = {
  theme: null,
  schedules: []
}
function mapStateToProps (state) {
  const { admin } = state
  const { itinerarySchedules } = admin
  const { schedules } = itinerarySchedules || {}

  return {
    schedules
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withNamespaces(['admin', 'common', 'account'])(connect(mapStateToProps, mapDispatchToProps)(AdminSchedulesList))
