import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
// import styles from '../Admin.scss'
import { AdminHubTile } from '../'
import { adminClicked as clickTip } from '../../../constants'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'

export class AdminSearchableHubs extends Component {
  static limitArray (hubs, limit) {
    return limit ? hubs.slice(0, limit) : hubs
  }
  constructor (props) {
    super(props)
    this.state = {
      hubs: props.hubs,
      selectedMot: null
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
  }
  componentDidUpdate (prevProps) {
    if (prevProps.hubs !== this.props.hubs) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  setHubFilter (e) {
    this.setState({ selectedMot: e })
    // this.handleSearchChange({ target: { value: '' } })
  }
  seeAll () {
    const { seeAll, adminDispatch } = this.props
    if (seeAll) {
      seeAll()
    } else {
      adminDispatch.goTo('/admin/hubs')
    }
  }

  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        hubs: this.filterHubsByType(this.props.hubs)
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
        keys: [key]
      }
      const fuse = new Fuse(this.props.hubs, options)
      return fuse.search(event.target.value)
    }

    const filteredHubNames = search('data.name')
    this.setState({
      hubs: this.filterHubsByType(filteredHubNames)
    })
  }
  handleClick (hub) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(hub)
    } else {
      adminDispatch.getHub(hub.id, true)
    }
  }

  filterHubsByType (array) {
    const { selectedMot } = this.state
    const { limit } = this.props
    let toLimitArray
    if (selectedMot && selectedMot.value) {
      toLimitArray = array.filter(x => x.data.hub_type === selectedMot.value)
    } else {
      toLimitArray = array
    }
    return limit === 0 ? toLimitArray : AdminSearchableHubs.limitArray(toLimitArray, limit)
  }
  render () {
    const {
      theme, seeAll
    } = this.props
    const { hubs } = this.state
    let hubsArr

    if (hubs) {
      hubsArr = this.filterHubsByType(hubs).map(hub => (
        <AdminHubTile
          key={v4()}
          hub={hub}
          theme={theme}
          handleClick={this.handleClick}
          tooltip={clickTip.related}
          showTooltip
          showIcon
        />
      ))
    }

    // const motOptions = [
    //   { label: 'Ocean', value: 'ocean' },
    //   { label: 'Rail', value: 'rail' },
    //   { label: 'Air', value: 'air' }
    // ]
    // const filters = !hideFilters ? (
    //   <div className="flex-90 layout-row layout-align-start-center">
    //     <div className="flex-20 layout-row layout-align-start-cente">
    //       <p className="flex-none">Filter by:</p>
    //     </div>
    //     <div className="flex-40 layout-row layout-align-center-center">
    //       <NamedSelect
    //         className={styles.select}
    //         options={motOptions}
    //         onChange={e => this.setHubFilter(e)}
    //         value={selectedMot}
    //         placeholder="Hub Type"
    //         name="motFilter"
    //       />
    //     </div>
    //     <div className="flex-40 layout-row layout-align-center-center input_box_full">
    //       <input
    //         type="text"
    //         name="search"
    //         placeholder="Search hubs"
    //         onChange={this.handleSearchChange}
    //       />
    //     </div>
    //   </div>
    // ) : (
    //   ''
    // )
    return (
      <div
        className="flex-80 layout-row layout-wrap layout-align-center-start"
      >

        {/* <div
                  className={`flex-100 layout-row layout-wrap layout-align-center-center ${
                    styles.searchable_header
                  }`}
                >
                  {filters}
                </div> */}
        {hubsArr}
        {seeAll !== false ? (
          <div className="flex-100 layout-row layout-align-end-center">
            <div
              className="flex-none layout-row layout-align-center-center pointy"
              onClick={this.seeAll}
            >
              <p className="flex-none">See all</p>
            </div>
          </div>
        ) : (
          ''
        )}
      </div>
    )
  }
}

AdminSearchableHubs.propTypes = {
  hubs: PropTypes.arrayOf(PropTypes.hub).isRequired,
  handleClick: PropTypes.func,
  adminDispatch: PropTypes.shape({
    getHub: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  theme: PropTypes.theme,
  limit: PropTypes.number
}

AdminSearchableHubs.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  limit: 0
}

export default AdminSearchableHubs
