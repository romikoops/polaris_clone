import React, { PureComponent } from 'react'
import Truncate from 'react-truncate'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
import defaults from '../../styles/default_classes.scss'
import { filters } from '../../helpers'

function determinePerPage (locations) {
  const width = window.innerWidth
  const perPage = width >= 1920 ? 5 : 3
  const pages = Math.ceil(locations.length / perPage)

  return { perPage, locations, pages }
}

class UserLocationsBox extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      page: 1,
      pages: 1,
      perPage: 6,
      searchText: '',
      locations: []
    }
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)
    this.handleSearchChange = this.handleSearchChange.bind(this)
  }

  componentWillMount () {
    this.setState(determinePerPage(this.props.locations))
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.locations === this.props.locations) return

    this.setState((prevState) => {
      if (!this.prevPage.searchText) {
        return { locations: nextProps.locations }
      }

      return { locations: this.filterLocations(prevState.searchText) }
    })
  }

  nextPage () {
    this.handlePage(1)
  }
  prevPage () {
    this.handlePage(-1)
  }
  handlePage (delta) {
    this.setState(prevState => ({ page: prevState.page + (1 * delta) }))
  }

  filterLocations (value) {
    const { locations } = this.props

    return filters.handleSearchChange(
      value,
      [
        'location.country',
        'location.city',
        'location.geocoded_address',
        'location.street',
        'location.street_number'
      ],
      locations
    )
  }

  handleSearchChange (e) {
    const locations = this.filterLocations(e.target.value)

    this.setState({ searchText: e.target.value, locations, page: 1 })
  }

  render () {
    const {
      gradient,
      toggleActiveView,
      makePrimary,
      cols,
      t,
      destroyLocation,
      editLocation
    } = this.props

    const {
      page, pages, perPage, locations, searchText
    } = this.state
    const locationCards = [<div
      key="addLocationButton"
      className={`pointy ${cols === 2 ? 'flex-45' : 'flex-30'} flex-md-45 margin_bottom layout-row layout-align-start-stretch tile_padding ${styles.loc_info}`}
      onClick={() => toggleActiveView('newLocation')}
    >
      <div
        className={`${styles['location-box']} ${
          styles['new-address']
        } layout-row layout-align-center-center layout-wrap`}
      >
        <div className="layout-row layout-align-center flex-100">
          <div className={`${styles['plus-icon']}`} />
        </div>

        <div className="layout-row layout-align-center flex-100">
          <h3>
            {t('user:addLocation')}
          </h3>
        </div>
      </div>
    </div>]
    const startIndex = (page - 1) * perPage
    const endIndex = page * perPage

    if (locations.length) {
      locations.sort((a, b) => b.user.primary - a.user.primary).slice(startIndex, endIndex).forEach((op) => {
        locationCards.push(<div
          key={v4()}
          className={`${cols === 2 ? 'flex-45' : 'flex-30'} flex-md-45 margin_bottom tile_padding layout-row layout-align-start-stretch ${styles.loc_info}`}
        >
          <div className={`${styles['location-box']} flex-100 layout-column`}>
            <div className={`${styles.header} layout-row layout-align-end-center`}>
              {op.user.primary ? (
                <i className={`fa fa-star clip ${styles.icon_primary}`} style={gradient} />
              ) : (
                <div className={`layout-row ${styles.icon_primary}`}>
                  <div className="layout-row">
                    <div
                      className={`${styles.makePrimary} pointy`}
                      onClick={() => {
                        makePrimary(op.location.id)
                        this.setState({ page: 1 })
                      }}
                    >
                      <i className="fa fa-star-o clip" style={gradient} />
                    </div>
                  </div>
                </div>
              )}
              <span className={`${defaults.emulate_link}`} onClick={() => editLocation(op.location)}>
                <i className="fa fa-pencil" />
              </span>
              <span
                className={`${defaults.emulate_link}`}
                onClick={() =>
                  destroyLocation(op.location.id)
                }
              >
                <i className={`fa fa-trash ${styles.icon_trash}`} />
              </span>
            </div>
            <div className={`layout-row flex-100 ${styles.location_address}`}>
              <i className="flex-10 fa fa-map-marker clip" style={gradient} />
              <div className={`${styles.content} flex layout-wrap layout-align-space-between`}>
                {op && op.location.street_number && op.location.street ? (
                  <p className="flex-100">{op.location.street_number} {op.location.street} </p>
                ) : ''}
                {op.location.city ? (
                  <p className="flex-100"><strong>{op.location.city}</strong></p>
                ) : ''}
                {op.location.zip_code ? (
                  <p className="flex-100">{op.location.zip_code}</p>
                ) : ''}
                {op.location.country ? (
                  <p className="flex-100"> <Truncate lines={2}>{op.location.country} </Truncate></p>
                ) : ''}
              </div>
            </div>
          </div>
        </div>)
      })
    }

    return (
      <div
        className={`layout-row flex-100
         layout-wrap layout-align-start-center ${styles.paginate_box}`}
      >
        <div
          className={`flex-100 layout-row layout-align-end-center ${
            styles.searchable_header
          }`}
        >
          <div
            className="input_box_full flex-40 layout-row layout-align-end-center"
          >
            <input
              type="text"
              name="search"
              value={searchText}
              placeholder="Search Shipments"
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start height_100">
          {locationCards}
        </div>
        <div className="flex-95 layout-row layout-align-center-center margin_bottom">
          <div
            className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${parseInt(page, 10) === 1 ? styles.disabled : ''}
                    `}
            onClick={parseInt(page, 10) > 1 ? this.prevPage : null}
          >
            <i className="fa fa-chevron-left" />
            <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
          </div>
          {}
          <p>{page} / {pages} </p>
          <div
            className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${parseInt(page, 10) < pages ? '' : styles.disabled}
            `}
            onClick={parseInt(page, 10) < pages ? this.nextPage : null}
          >
            <p>Next&nbsp;&nbsp;&nbsp;&nbsp;</p>
            <i className="fa fa-chevron-right" />
          </div>
        </div>

      </div>

    )
  }
}
UserLocationsBox.propTypes = {
  locations: PropTypes.arrayOf(PropTypes.object),
  makePrimary: PropTypes.func,
  toggleActiveView: PropTypes.func,
  destroyLocation: PropTypes.func,
  editLocation: PropTypes.func,
  gradient: PropTypes.objectOf(PropTypes.string),
  cols: PropTypes.number,
  t: PropTypes.func.isRequired
}

UserLocationsBox.defaultProps = {
  locations: [],
  makePrimary: null,
  toggleActiveView: null,
  destroyLocation: null,
  editLocation: null,
  gradient: {},
  cols: 3
}

export default UserLocationsBox
