import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminRoutesTooltips as routeTip } from '../../constants'
import styles from './Admin.scss'
// import DocumentsDownloader from '../Documents/Downloader'
import { AdminSearchableRoutes } from './AdminSearchables'
// import FileUploader from '../FileUploader/FileUploader'
import { filters, capitalize } from '../../helpers'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import { Checkbox } from '../Checkbox/Checkbox'

export class AdminRoutesIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchFilters: {},
      searchResults: []
    }
  }
  componentWillMount () {
    if (this.props.itineraries && !this.state.searchResults.length) {
      this.prepFilters()
    }
  }
  componentDidMount () {
    const { itineraries, loading, adminDispatch } = this.props
    if (!itineraries && !loading) {
      adminDispatch.getItineraries(false)
    }
    window.scrollTo(0, 0)
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  prepFilters () {
    const { itineraries } = this.props
    const tmpFilters = {
      mot: {}
    }
    itineraries.forEach((itin) => {
      tmpFilters.mot[itin.mode_of_transport] = true
    })
    this.setState({
      searchFilters: tmpFilters,
      searchResults: itineraries
    })
  }
  toggleFilterValue (target, key) {
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        [target]: {
          ...this.state.searchFilters[target],
          [key]: !this.state.searchFilters[target][key]
        }
      }
    })
  }
  handleSearchQuery (e) {
    const { value } = e.target
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        query: value
      }
    })
  }
  applyFilters (array) {
    const { searchFilters } = this.state
    const motKeys = Object.keys(searchFilters.mot).filter(key => searchFilters.mot[key])
    const filter1 = array.filter(a => motKeys.includes(a.mode_of_transport))
    let filter2
    if (searchFilters.query && searchFilters.query !== '') {
      filter2 = filters.handleSearchChange(
        searchFilters.query,
        ['name', 'mode_of_transport'],
        filter1
      )
    } else {
      filter2 = filter1
    }

    return filter2
  }
  render () {
    const {
      theme, viewItinerary, hubs, itineraries, adminDispatch
    } = this.props
    const { expander, searchFilters, searchResults } = this.state
    if (!itineraries) {
      return ''
    }
    const typeFilters = Object.keys(searchFilters.mot).map(htk => (
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-align-center-center layout-wrap`}
      >
        <p className="flex-70">{capitalize(htk)}</p>
        <Checkbox
          onChange={() => this.toggleFilterValue('mot', htk)}
          checked={searchFilters.mot[htk]}
          theme={theme}
        />
      </div>
    ))

    const results = this.applyFilters(searchResults)

    // const hubUrl = '/admin/itineraries/process_csv'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start extra_padding_left">
        <div className={`${styles.component_view} flex-80 flex-md-70 flex-sm-100 layout-row layout-align-start-start`}>
          <AdminSearchableRoutes
            itineraries={results}
            theme={theme}
            hubs={hubs}
            limit={40}
            showDelete
            adminDispatch={adminDispatch}
            sideScroll={false}
            handleClick={viewItinerary}
            tooltip={routeTip.related}
            showTooltip
            hideFilters
            seeAll={false}
          />
        </div>
        <div className="layout-column flex-20 flex-md-30 hide-sm hide-xs layout-align-end-end">
          <SideOptionsBox
            header="Filters"
            flexOptions="layout-column flex-20 flex-md-30"
            content={
              <div>
                <div
                  className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
                >
                  <input
                    type="text"
                    className="flex-100"
                    value={searchFilters.query}
                    placeholder="Search..."
                    onChange={e => this.handleSearchQuery(e)}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <div
                    className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                    onClick={() => this.toggleExpander('mot')}
                  >
                    <div className="flex-90 layout-align-start-center layout-row">
                      <i className="flex-none fa fa-ship" />
                      <p className="flex-none">Mode of Transport</p>
                    </div>
                    <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                      {expander.mot ? (
                        <i className="flex-none fa fa-chevron-up" />
                      ) : (
                        <i className="flex-none fa fa-chevron-down" />
                      )}
                    </div>
                  </div>
                  <div
                    className={`${
                      expander.mot ? styles.open_filter : styles.closed_filter
                    } flex-100 layout-row layout-wrap layout-align-center-start`}
                  >
                    {typeFilters}
                  </div>
                </div>
              </div>
            }
          />
          <SideOptionsBox
            header="Filters"
            flexOptions="layout-column flex-20 flex-md-30"
            content={
              <div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <div
                    className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                    onClick={() => this.toggleExpander('new')}
                  >
                    <div className="flex-90 layout-align-start-center layout-row">
                      <i className="flex-none fa fa-plus-circle" />
                      <p className="flex-none">New Route</p>
                    </div>
                    <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                      {expander.new ? (
                        <i className="flex-none fa fa-chevron-up" />
                      ) : (
                        <i className="flex-none fa fa-chevron-down" />
                      )}
                    </div>
                  </div>
                  <div
                    className={`${
                      expander.new ? styles.open_filter : styles.closed_filter
                    } flex-100 layout-row layout-wrap layout-align-center-start`}
                  >
                    <div
                      className={`${
                        styles.action_section
                      } flex-100 layout-row layout-wrap layout-align-center-center`}
                    >
                      <RoundButton
                        theme={theme}
                        size="small"
                        text="New Route"
                        active
                        handleNext={this.props.toggleNewRoute}
                        iconClass="fa-plus"
                      />
                      <ReactTooltip id="newRouteTip" className={styles.tooltip} effect="solid" />
                    </div>
                  </div>
                </div>
              </div>
            }
          />
        </div>
      </div>
    )
  }
}
AdminRoutesIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getRoutes: PropTypes.func
  }).isRequired,
  viewItinerary: PropTypes.func.isRequired,
  toggleNewRoute: PropTypes.func.isRequired,
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminRoutesIndex.defaultProps = {
  theme: null,
  hubs: [],
  loading: false
}

export default AdminRoutesIndex
