import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { AdminNexusTile } from '../'
import { Tooltip } from '../../Tooltip/Tooltip'
import TextHeading from '../../TextHeading/TextHeading'
import { adminClicked as clickTip, adminTrucking as truckTip } from '../../../constants'

export class AdminSearchableTruckings extends Component {
  constructor (props) {
    super(props)
    this.state = {
      truckings: props.truckings
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
  }
  componentDidUpdate (prevProps) {
    if (prevProps.truckings !== this.props.truckings) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  handleClick (hub) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(hub)
    } else {
      adminDispatch.getHub(hub.id, true)
    }
  }
  seeAll () {
    const { seeAll, adminDispatch } = this.props
    if (seeAll) {
      seeAll()
    } else {
      adminDispatch.goTo('/truckings')
    }
  }
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        truckings: this.props.truckings
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
      const fuse = new Fuse(this.props.truckings, options)

      return fuse.search(event.target.value)
    }

    const filteredHubNames = search('data.name')
    // ;
    this.setState({
      truckings: filteredHubNames
    })
  }
  render () {
    const {
      theme, seeAll, showTooltip, icon, tooltip, t
    } = this.props
    const { truckings } = this.state
    let truckingsArr
    if (truckings) {
      truckingsArr = truckings.map(trucking => (<AdminNexusTile
        key={v4()}
        nexus={trucking.nexus}
        theme={theme}
        // eslint-disable-next-line no-underscore-dangle
        handleClick={() => this.handleClick(trucking.trucking._id)}
        tooltip={clickTip.related}
        showTooltip
      />))
    }
    const viewType = (truckingsArr.length > 3) ? (
      <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
        <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
          {truckingsArr}
        </div>
      </div>
    ) : (
      <div className="layout-row flex-100 layout-align-start-center ">
        <div className="layout-row flex-none layout-align-start-center layout-wrap">
          {truckingsArr}
        </div>
      </div>
    )

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`} >
        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.searchable_header}`} >
          <div className="flex-60 layput-row layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-none layout-row layout-align-start-center" >
                <div className="flex-none" >
                  <TextHeading
                    theme={theme}
                    size={1}
                    text={t('admin:truckingCities')}
                  />
                </div>
                { showTooltip ? <Tooltip
                  icon="na-info-circle"
                  theme={theme}
                  text={truckTip.truckings}
                  toolText
                /> : '' }
                { icon ? <Tooltip
                  theme={theme}
                  icon={icon}
                  text={tooltip}
                  toolText
                /> : '' }
              </div>
            </div>
          </div>
          <div className={`${styles.input_box} flex-40 layput-row layout-align-start-center`}>
            <input
              type="text"
              name="search"
              placeholder={t('admin:searchTruckingCities')}
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        {viewType}
        {seeAll !== false ? (
          <div className="flex-100 layout-row layout-align-end-center">
            <div
              className="flex-none layout-row layout-align-center-center"
              onClick={this.seeAll}
            >
              <p className="flex-none">{t('admin:seeAll')}</p>
            </div>
          </div>
        ) : (
          ''
        )}
      </div>
    )
  }
}

AdminSearchableTruckings.propTypes = {
  truckings: PropTypes.arrayOf(PropTypes.object).isRequired,
  handleClick: PropTypes.func,
  t: PropTypes.func.isRequired,
  adminDispatch: PropTypes.shape({
    getHub: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  theme: PropTypes.theme,
  showTooltip: PropTypes.bool,
  icon: PropTypes.string,
  tooltip: PropTypes.string
}

AdminSearchableTruckings.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  showTooltip: false,
  icon: '',
  tooltip: ''
}

export default withNamespaces('admin')(AdminSearchableTruckings)
