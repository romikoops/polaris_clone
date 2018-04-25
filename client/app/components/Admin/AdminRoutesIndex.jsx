import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminRoutesTooltips as routeTip } from '../../constants'
import styles from './Admin.scss'
// import FileUploader from '../../components/FileUploader/FileUploader'
import { AdminSearchableRoutes } from './AdminSearchables'

export class AdminRoutesIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }
  componentDidMount () {
    const { itineraries, loading, adminDispatch } = this.props
    if (!itineraries && !loading) {
      adminDispatch.getItineraries(false)
    }
  }
  render () {
    const {
      theme, viewItinerary, hubs, itineraries, adminDispatch
    } = this.props
    if (!itineraries) {
      return ''
    }

    // const hubUrl = '/admin/itineraries/process_csv'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
          <AdminSearchableRoutes
            itineraries={itineraries}
            theme={theme}
            hubs={hubs}
            limit={40}
            showDelete
            adminDispatch={adminDispatch}
            sideScroll={false}
            handleClick={viewItinerary}
            tooltip={routeTip.related}
            showTooltip
            seeAll={false}
          />
        </div>
        <div className=" flex-20 layout-row layout-wrap layout-align-center-start">
          <div
            className={`${
              styles.action_box
            } flex-95 layout-row layout-wrap layout-align-center-start`}
          >
            <div className="flex-100 layout-row layout-align-center-center">
              <h2 className="flex-none letter_3"> Actions </h2>
            </div>

            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
              >
                <i className="flex-none fa fa-plus-circle" />
                <p className="flex-none">Create New Route</p>
              </div>
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
