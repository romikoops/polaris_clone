import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { history, capitalize } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
import { TruckingDisplayPanel } from './AdminAuxilliaries'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import DocumentsSelector from '../../components/Documents/Selector'

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }
  static getTruckingPricingKey (truckingPricing) {
    if (truckingPricing.zipcode) {
      return truckingPricing.zipcode.join(' - ')
    }
    if (truckingPricing.city_name) {
      return truckingPricing.city_name
    }
    if (truckingPricing.distance) {
      return truckingPricing.distance.join(' - ')
    }
    return ''
  }

  constructor (props) {
    super(props)
    this.state = {
      currentQuery: false,
      queryFilter: { value: 'either', label: 'Import/Export' }
    }
    this.viewQuery = this.viewQuery.bind(this)
    this.setQueryFilter = this.setQueryFilter.bind(this)
    this.cellGenerator = this.cellGenerator.bind(this)
    this.closeQueryView = this.closeQueryView.bind(this)
  }
  componentWillMount () {
    if (this.props.truckingDetail && this.props.truckingDetail.truckingPricings) {
      this.handleSearchChange({ target: { value: '' } })
    }
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
    const filteredQueries =
      queryFilter.value === 'either'
        ? queries
        : queries.filter(q => q.query.direction === queryFilter.value)
    if (!truckingHub) {
      return ''
    }
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
  toggleNew () {
    this.setState({ newRow: !this.state.newRow })
  }
  selectTruckingPricing (truckingPricing) {
    this.setState({ currentTruckingPricing: truckingPricing })
  }
  handleUpload (file, dir, type) {
    const { adminDispatch, truckingDetail } = this.props
    const { hub } = truckingDetail
    const url =
      type === 'city'
        ? `/admin/trucking/trucking_city_pricings/${hub.id}`
        : `/admin/trucking/trucking_zip_pricings/${hub.id}`
    adminDispatch.uploadTrucking(url, file, dir)
  }
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        filteredTruckingPricings: this.props.truckingDetail.truckingPricings
      })
      return
    }
    const search = (key) => {
      const options = {
        shouldSort: true,
        tokenize: true,
        threshold: 0.2,
        location: 0,
        distance: 50,
        maxPatternLength: 32,
        minMatchCharLength: 5,
        keys: key
      }
      const fuse = new Fuse(this.props.truckingDetail.truckingPricings, options)
      return fuse.search(event.target.value)
    }

    const filteredTruckingPricings = search(['zipcode', 'city_name', 'distance'])
    // ;
    this.setState({
      filteredTruckingPricings
    })
  }
  render () {
    const { theme, truckingDetail, adminDispatch } = this.props
    if (!truckingDetail) {
      return ''
    }
    const queryFilterOptions = [
      { value: 'either', label: 'Import/Export' },
      { value: 'export', label: 'Export' },
      { value: 'import', label: 'Import' }
    ]
    const {
      currentQuery,
      queryFilter,
      newRow,
      filteredTruckingPricings,
      searchFilter,
      currentTruckingPricing
    } = this.state
    const { truckingHub, truckingQueries, hub } = truckingDetail
    // const nexus = truckingHub ? nexuses.filter(n => n.id === truckingHub.nexus_id)[0] : {}
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          active
          text="New"
          handleNext={() => this.toggleNew()}
          iconClass="fa-plus"
        />
      </div>
    )
    const displayPanel = (
      <TruckingDisplayPanel
        theme={theme}
        truckingInstance={currentTruckingPricing}
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
    const uploadOptions = [
      { value: 'import', label: 'Import Only' },
      { value: 'export', label: 'Export Only' },
      { value: 'either', label: 'Import/Export' }
    ]
    const searchResults = filteredTruckingPricings.map(tp => (
      <div
        className="flex-100 layout-row layout-align-start-center"
        key={v4()}
        onClick={() => this.selectTruckingPricing(tp)}
      >
        <p className="flex-none"> {AdminTruckingView.getTruckingPricingKey(tp)}</p>
      </div>
    ))

    const panelStyle = newRow ? styles.showPanel : styles.hidePanel
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {hub.name}
          </p>
          {newButton}
        </div>
        <div
          className={`${panelStyle} ${
            styles.panelDefault
          } flex-100 layout-row layout-align-space-between-center`}
        >
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90 center">Create New Trucking Pricing</p>
            <RoundButton
              theme={theme}
              size="small"
              active
              text="New Pricing"
              handleNext={() => adminDispatch.goTo('/admin/trucking/new/creator')}
              iconClass="fa-plus"
            />
          </div>
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90 center">Upload Trucking City Sheet</p>
            <DocumentsSelector
              theme={theme}
              dispatchFn={(file, dir) => this.handleUpload(file, dir, 'city')}
              type="xlsx"
              text="Routes .xlsx"
              options={uploadOptions}
            />
          </div>
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90 center">Upload Trucking Zip Code Sheet</p>
            <DocumentsSelector
              theme={theme}
              dispatchFn={(file, dir) => this.handleUpload(file, dir, 'zip')}
              type="xlsx"
              text="Routes .xlsx"
              options={uploadOptions}
            />
          </div>
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Rates </p>
          </div>
          <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
            <div className="flex-25 layout-row layout-align-center-start layout-wrap">
              <div className="flex-100 layout-row layout-alignstart-center input_box_full">
                <input
                  type="text"
                  value={searchFilter}
                  onCHange={e => this.handleSearchChange(e)}
                />
              </div>
              <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                {searchResults}
              </div>
            </div>
            <div className="flex-75 layout-row layout-align-start-start layout-wrap">
              {truckView}
            </div>
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
  adminDispatch: PropTypes.shape({
    uploadTrucking: PropTypes.func
  }).isRequired,
  truckingDetail: PropTypes.shape({
    truckingHub: PropTypes.object,
    truckingPricings: PropTypes.array,
    pricing: PropTypes.object
  })
}

AdminTruckingView.defaultProps = {
  theme: null,
  truckingDetail: null
}

export default AdminTruckingView
