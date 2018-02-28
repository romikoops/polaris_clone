import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { history, capitalize } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
import { TruckingDisplayPanel } from './AdminAuxilliaries'
import { NamedSelect } from '../NamedSelect/NamedSelect'

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      currentQuery: false,
      queryFilter: 'either'
    }
    this.viewQuery = this.viewQuery.bind(this)
    this.setQueryFilter = this.setQueryFilter.bind(this)
    this.cellGenerator = this.cellGenerator.bind(this)
    this.closeQueryView = this.closeQueryView.bind(this)
  }
  setQueryFilter (selection) {
    this.setState({ queryFilter: selection })
  }
  viewQuery (query) {
    this.setState({ currentQuery: query })
  }
  closeQueryView () {
    this.setState({ currentQuery: false })
  }

  cellGenerator (truckingHub, queries) {
    const { queryFilter } = this.state
    const filteredQueries = queryFilter.value === 'either' ? queries : queries.filter(q => q.query.direction === queryFilter.value)
    switch (truckingHub.modifier) {
      case 'zipcode':
        return filteredQueries.map(q => (
          <div
            key={v4()}
            className={`flex-20 layout-row layout-align-center-center pointy layout-wrap ${
              styles.trucking_display_cell
            }`}
            onClick={() => this.viewQuery(q)}
          >
            <p className="flex-100">Zipcode range</p>
            <p className="flex-100">{`${q.query.zipcode.lower_zip} - ${
              q.query.zipcode.upper_zip
            }`}</p>
          </div>
        ))
      case 'city':
        return filteredQueries.map(q => (
          <div
            key={v4()}
            className={`flex-20 layout-row layout-align-center-center pointy layout-wrap ${
              styles.trucking_display_cell
            }`}
            onClick={() => this.viewQuery(q)}
          >
            <p className="flex-100">City</p>
            <p className="flex-100">{`${capitalize(q.query.city.city)}, ${capitalize(q.query.city.province)}`}</p>
          </div>
        ))
      case 'distance':
        return filteredQueries.map(q => (
          <div
            key={v4()}
            className={`flex-20 layout-row layout-align-center-center pointy layout-wrap ${
              styles.trucking_display_cell
            }`}
            onClick={() => this.viewQuery(q)}
          >
            <p className="flex-100">Distances</p>
            <p className="flex-100">{`${q.query.distance.lower_distance} - ${
              q.query.distance.upper_distance
            }`}</p>
          </div>
        ))

      default:
        return []
    }
  }
  render () {
    const { theme, truckingDetail, nexuses } = this.props
    if (!truckingDetail) {
      return ''
    }
    const queryFilterOptions = [
      { value: 'either', label: 'Import/Export' },
      { value: 'export', label: 'Export' },
      { value: 'import', label: 'Import' }
    ]
    const { currentQuery, queryFilter } = this.state
    const { truckingHub, truckingQueries } = truckingDetail
    const nexus = nexuses.filter(n => n.id === truckingHub.nexus_id)[0]
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={AdminTruckingView.backToIndex}
          iconClass="fa-chevron-left"
        />
      </div>
    )
    console.log(nexus)
    const displayPanel = (
      <TruckingDisplayPanel
        theme={theme}
        truckingInstance={currentQuery}
        truckingHub={truckingHub}
        closeView={this.closeQueryView}
      />
    )
    const truckView = currentQuery ? displayPanel : this.cellGenerator(truckingHub, truckingQueries)
    const queryFilterRow = (
      <div className="flex-100 layout-row layout-align-end-center">
        <div className="flex-25 layout-row layout-align-center-center">
          <NamedSelect
            name="queryFilter"
            classes={`${styles.select}`}
            value={queryFilter}
            options={queryFilterOptions}
            className="flex-100"
            onChange={this.setQueryFilter}
          />
        </div>
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {nexus.name}
          </p>
          {backButton}
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Rates </p>
          </div>
          <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
            {currentQuery ? '' : queryFilterRow}
            {truckView}
          </div>
        </div>
      </div>
    )
  }
}
AdminTruckingView.propTypes = {
  theme: PropTypes.theme,
  nexuses: PropTypes.objectOf(PropTypes.object),
  truckingDetail: PropTypes.shape({
    truckingHub: PropTypes.object,
    pricing: PropTypes.object
  })
}

AdminTruckingView.defaultProps = {
  theme: null,
  nexuses: null,
  truckingDetail: null
}

export default AdminTruckingView
