import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get, range } from 'lodash'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import DayPickerInput from 'react-day-picker/lib/src/DayPickerInput'
import {
  formatDate,
  parseDate
} from 'react-day-picker/moment'
import '../../../../styles/day-picker-custom.scss'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import RoundButton from '../../../RoundButton/RoundButton'
import AdminClientMarginsDetailTable from './DetailTable'
import { moment } from '../../../../constants'

class AdminClientMargins extends Component {
  constructor (props) {
    super(props)
    this.state = {
      margins: get(props, ['margins'], []).sort((a, b) => a.applicationOrder - b.applicationOrder),
      editable: get(props, ['editable'], false),
      expanded: {}
    }
    this.renderEditable = this.renderEditable.bind(this)
    this.handleDetailsChange = this.handleDetailsChange.bind(this)
    this.handleOrderChange = this.handleOrderChange.bind(this)
    this.saveChanges = this.saveChanges.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch, targetId, targetType } = this.props
    clientsDispatch.getMarginsForList({
      page: 1, pageSize: 10, targetId, targetType
    })
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.margins.length !== nextProps.margins.length) {
      this.setState({ margins: nextProps.margins.sort((a, b) => a.applicationOrder - b.applicationOrder) })
    }
  }

  saveChanges () {
    const { margins } = this.state
    const { clientsDispatch, toggleEdit } = this.props
    clientsDispatch.updateMarginValues({ margins })
    toggleEdit()
  }

  deleteMargin (id) {
    const { clientsDispatch } = this.props
    this.setState(prevState => ({ margins: prevState.margins.filter(m => m.id !== id) }), () => {
      clientsDispatch.deleteMargin(id)
    })
  }

  handleDetailsChange (target, values) {
    const { margins } = this.state
    const targetMargin = margins.filter(m => m.id === target)[0]
    const targetIndex = margins.indexOf(targetMargin)
    margins[targetIndex].marginDetails = values
    this.setState({ margins })
  }

  handleOrderChange (id, delta) {
    const { margins } = this.state
    const targetGroupIndex = margins.findIndex(g => g.id === id)
    const targetMargin = margins[targetGroupIndex]
    const indexToChange = targetGroupIndex + delta

    if (indexToChange < 0 || indexToChange >= margins.length) { return }
    margins[targetGroupIndex].applicationOrder += delta
    margins[indexToChange].applicationOrder -= delta
    const sortedMargins = margins.sort((a, b) => a.applicationOrder - b.applicationOrder).map((g, i) => ({ ...g, applicationOrder: i }))
    this.setState({ margins: sortedMargins })
  }

  determineSubTable (row) {
    const { editable } = this.props
    if (row.original.marginDetails.length > 0) {
      return (
        <div className={styles.nested_table}>
          <AdminClientMarginsDetailTable
            row={row}
            className={styles.nested_table}
            handleDetailsChange={this.handleDetailsChange}
            editable={editable}
          />
        </div>
      )
    }

    return ''
  }

  renderEditable (cellInfo) {
    const { editable } = this.props
    const { margins } = this.state
    if (!editable) {
      let cellToRender
      if (cellInfo.column.id === 'operator') {
        cellToRender = (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center center`}
            dangerouslySetInnerHTML={{
              __html: margins[cellInfo.index][cellInfo.column.id]
            }}
          />
        )
      } else if (['effectiveDate', 'expirationDate'].includes(cellInfo.column.id)) {
        cellToRender = (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center center`}
            dangerouslySetInnerHTML={{
              __html: moment(margins[cellInfo.index][cellInfo.column.id]).format('DD/MM/YY')
            }}
          />
        )
      } else if (cellInfo.column.id === 'applicationOrder') {
        cellToRender = (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center center`}
            dangerouslySetInnerHTML={{
              __html: margins[cellInfo.index][cellInfo.column.id]
            }}
          />
        )
      } else {
        let value
        const rawValue = margins[cellInfo.index][cellInfo.column.id]
        if (rawValue) {
          const { operator } = margins[cellInfo.index]
          value = operator === '+' ? rawValue : parseFloat(rawValue) * 100
        } else {
          value = '-'
        }
        cellToRender = (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center center`}
            dangerouslySetInnerHTML={{
              __html: value
            }}
          />
        )
      }

      return cellToRender
    }
    if (cellInfo.column.id === 'operator') {
      return (
        <select
          style={{ backgroundColor: '#fafafa', textAlign: 'center' }}
          onChange={(e) => {
            const margins = [...this.state.margins]
            margins[cellInfo.index][cellInfo.column.id] = e.target.value
            this.setState({ margins })
          }}
          value={margins[cellInfo.index][cellInfo.column.id]}
        >
          <option value="%">%</option>
          <option value="+">+</option>
        </select>
      )
    }

    if (cellInfo.column.id === 'applicationOrder') {
      return (
        <div
          className={`${styles.table_cell} edit flex layout-row layout-align-start-center pointy`}
        >
          <div
            className="flex layout-row layout-align-center-center"
            style={{ visibility: margins[cellInfo.index].applicationOrder === 0 ? 'hidden' : 'visible' }}
            onClick={() => this.handleOrderChange(margins[cellInfo.index].id, -1)}
          >
            <i className="flex-none fa fa-arrow-up" />
          </div>
          <div
            className="flex layout-row layout-align-center-center"
            style={{ visibility: margins[cellInfo.index].applicationOrder === margins.length - 1 ? 'hidden' : 'visible' }}
            onClick={() => this.handleOrderChange(margins[cellInfo.index].id, 1)}
          >
            <i className="flex-none fa fa-arrow-down" />
          </div>
        </div>
      )
    }
    if (['effectiveDate', 'expirationDate'].includes(cellInfo.column.id)) {
      const dayPickerProps = {
        disabledDays: {
          before: new Date(moment()
            .add(7, 'days'))
        },
        month: new Date(
          moment()
            .add(7, 'days')
            .format('YYYY'),
          moment()
            .add(7, 'days')
            .format('M') - 1
        ),
        name: 'dayPicker'
      }

      return (
        <div className={styles.day_picker}>
          <DayPickerInput
            name="dayPicker"
            format="LL"
            formatDate={formatDate}
            classNames={
              {
                overlayWrapper: styles.day_picker_overlay_wrapper,
                container: 'input_box_full'
              }
            }
            parseDate={parseDate}
            placeholder={`${formatDate(new Date())}`}
            value={moment(this.state.margins[cellInfo.index][cellInfo.column.id]).format('DD/MM/YYYY')}
            onDayChange={(e) => {
              const margins = [...this.state.margins]
              margins[cellInfo.index][cellInfo.column.id] = e
              this.setState({ margins })
            }}
            dayPickerProps={dayPickerProps}
          />
        </div>
      )
    }

    if (cellInfo.column.id === 'applicationOrder') {
      return (
        <div
          className={`${styles.table_cell} edit flex layout-row layout-align-start-center pointy`}
        >
          <div
            className="flex layout-row layout-align-center-center"
            style={{ visibility: margins[cellInfo.index].applicationOrder === 0 ? 'hidden' : 'visible' }}
            onClick={() => this.handleOrderChange(margins[cellInfo.index].id, -1)}
          >
            <i className="flex-none fa fa-arrow-up" />
          </div>
          <div
            className="flex layout-row layout-align-center-center"
            style={{ visibility: margins[cellInfo.index].applicationOrder === margins.length - 1 ? 'hidden' : 'visible' }}
            onClick={() => this.handleOrderChange(margins[cellInfo.index].id, 1)}
          >
            <i className="flex-none fa fa-arrow-down" />
          </div>
        </div>
      )
    }
    if (['effectiveDate', 'expirationDate'].includes(cellInfo.column.id)) {
      const dayPickerProps = {
        disabledDays: {
          before: new Date(moment()
            .add(7, 'days'))
        },
        month: new Date(
          moment()
            .add(7, 'days')
            .format('YYYY'),
          moment()
            .add(7, 'days')
            .format('M') - 1
        ),
        name: 'dayPicker'
      }

      return (
        <div className={styles.day_picker}>
          <DayPickerInput
            name="dayPicker"
            format="LL"
            formatDate={formatDate}
            classNames={
              {
                overlayWrapper: styles.day_picker_overlay_wrapper,
                container: 'input_box_full'
              }
            }
            parseDate={parseDate}
            placeholder={`${formatDate(new Date())}`}
            value={moment(this.state.margins[cellInfo.index][cellInfo.column.id]).format('DD/MM/YYYY')}
            onDayChange={(e) => {
              const margins = [...this.state.margins]
              margins[cellInfo.index][cellInfo.column.id] = e
              this.setState({ margins })
            }}
            dayPickerProps={dayPickerProps}
          />
        </div>
      )
    }
    let value
    const rawValue = margins[cellInfo.index][cellInfo.column.id]
    const { operator } = margins[cellInfo.index]
    if (rawValue) {
      value = operator === '+' ? rawValue : parseFloat(rawValue) * 100
    } else {
      value = '-'
    }
    return (
      <div
        style={{ backgroundColor: '#fafafa', textAlign: 'center' }}
        contentEditable
        suppressContentEditableWarning
        onBlur={(e) => {
          const margins = [...this.state.margins]
          const newValue = operator === '+' ? e.target.innerHTML : parseFloat(e.target.innerHTML) / 100
          margins[cellInfo.index][cellInfo.column.id] = newValue
          this.setState({ margins })
        }}
        dangerouslySetInnerHTML={{
          __html: value
        }}
      />
    )
  }

  render () {
    const {
      t, theme, editable, compact
    } = this.props
    const { margins } = this.state
    const columns = [
      {
        id: 'marginType',
        Header: t('admin:marginType'),
        accessor: d => d.marginType,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          >
            <p className="flex-none">
              {' '}
              {t(`admin:${rowData.row.marginType}`)}
            </p>
          </div>
        ),
        maxWidth: 100,
        Filter: ({ filter, onChange }) => (
          <select
            onChange={event => onChange(event.target.value)}
            style={{ width: '100%' }}
            value={filter ? filter.value : 'all'}
          >
            <option value="all">All</option>
            <option value="freight_margin">{t('admin:freight_margin')}</option>
            <option value="import_margin">{t('admin:import_margin')}</option>
            <option value="export_margin">{t('admin:export_margin')}</option>
            <option value="trucking_on_margin">{t('admin:trucking_on_margin')}</option>
            <option value="trucking_pre_margin">{t('admin:trucking_pre_margin')}</option>
          </select>
        )
      },
      {
        id: 'effectiveDate',
        Header: t('admin:validFrom'),
        accessor: d => d.effectiveDate,
        Cell: this.renderEditable
      },
      {
        id: 'expirationDate',
        Header: t('admin:validTo'),
        accessor: d => d.expirationDate,
        Cell: this.renderEditable
      },
      {
        id: 'itineraryName',
        Header: t('admin:itinerary'),
        accessor: d => d.itineraryName,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center center`}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.itineraryName}
            </p>
          </div>
        )
      },
      {
        id: 'serviceLevel',
        Header: t('admin:serviceLevel'),
        accessor: d => d.serviceLevel,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.serviceLevel}
            </p>
          </div>
        ),
        maxWidth: 100
      },
      {
        id: 'cargoClass',
        Header: t('admin:cargoClass'),
        accessor: d => d.cargoClass,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.cargoClass}
            </p>
          </div>
        ),
        maxWidth: 100
      },
      {
        id: 'mot',
        Header: t('admin:modeOfTransport'),
        accessor: d => d.modeOfTransport,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center`}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.mot}
            </p>
          </div>
        ),
        maxWidth: 100
      },
      {
        id: 'value',
        Header: t('admin:margin'),
        accessor: d => d.operator === '%' ? `${parseFloat(d.value) * 100}` : d.value,
        Cell: this.renderEditable,
        maxWidth: 75
      },
      {
        id: 'operator',
        Header: t('admin:operator'),
        accessor: d => `${d.operator}`,
        Cell: this.renderEditable,
        maxWidth: 75
      }
    ]
    if (editable) {
      columns.push({
        id: 'delete',
        Header: t('admin:delete'),
        accessor: d => d.id,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.deleteMargin(rowData.original.id)}
          >
            <i className="flex-none fa fa-trash red" />
          </div>
        ),
        maxWidth: 75
      })
    }

    return (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap">
        <ReactTable
          className="flex"
          data={margins}
          columns={columns}
          defaultSorted={[
            {
              id: 'applicationOrder',
              desc: false
            }
          ]}
          filterable
          defaultPageSize={compact ? margins.length : 10}
          expanded={this.state.expanded}
          onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
          SubComponent={subRow => this.determineSubTable(subRow)}
        />
        <div
          className={`flex-100 layout-row layout-align-space-between-center padd_20 
            ${editable ? '' : styles.hidden}`}
        >
          <div className="flex-33 layout-row layout-align-center-center">
            <RoundButton
              size="full"
              text={t('common:cancel')}
              theme={theme}
              handleNext={() => this.props.toggleEdit()}
            />
          </div>
          <div className="flex-33 layout-row layout-align-center-center">
            <RoundButton
              active
              size="full"
              text={t('common:save')}
              theme={theme}
              handleNext={() => this.saveChanges()}
            />
          </div>
        </div>
      </div>
    )
  }
}

AdminClientMargins.defaultProps = {
  compact: false,
  margins: []
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { margins } = clients
  const {
    name,
    marginData,
    users
  } = margins || {}
  const { tenant } = app
  const { theme } = tenant

  return {
    name,
    margins: marginData,
    users,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientMargins))
