import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import adminStyles from '../Admin.scss'
import { AdminHubTile } from '../'
// import { Tooltip } from '../../Tooltip/Tooltip'
import { adminClicked as clickTip } from '../../../constants'

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
  componentWillReceiveProps (nextProps) {
    if (nextProps.hubs && nextProps.hideFilters) {
      this.setState({
        hubs: this.filterHubsByType(nextProps.hubs)
      }, () => this.handleSearchChange({ target: { value: '' } }))
    }
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
      theme, seeAll, sideScroll, t
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
        />
      ))
    }
    const viewType = sideScroll ? (
      <div className={`layout-row flex-100 layout-align-start-center ${adminStyles.slider_container}`}>
        <div
          className={`layout-row flex-none layout-align-space-around-center card_margin_right ${adminStyles.slider_inner}`}
        >
          {hubsArr}
        </div>
      </div>
    ) : (
      <div className="layout-row flex-95 layout-wrap card_margin_right">
        {hubsArr}
      </div>
    )

    return (
      <div
        className={`layout-row flex-100 layout-align-start-center layout-wrap ${adminStyles.searchable}`}
      >
        {viewType}
        {seeAll !== false ? (
          <div className="flex-100 layout-row layout-align-end-center">
            <div
              className="flex-none layout-row layout-align-center-center pointy"
              onClick={this.seeAll}
            >
              <p className="flex-none">
                {t('admin:seeAll')}
              </p>
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
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  sideScroll: PropTypes.bool,
  hideFilters: PropTypes.bool,
  limit: PropTypes.number
}

AdminSearchableHubs.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  sideScroll: false,
  hideFilters: false,
  limit: 0
}

export default withNamespaces('admin')(AdminSearchableHubs)
