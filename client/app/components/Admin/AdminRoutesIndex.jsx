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
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
        >
          <div className="flex-33 layout-column layout-align-center-center">
            {/* <p className="flex-none">Upload Routes Sheet</p>
            <FileUploader
              theme={theme}
              url={hubUrl}
              type="xlsx"
              text="Routes .xlsx"
              tooltip={routeTip.upload}
            /> */}
          </div>
          <div className="flex-33 layout-column layout-align-center-center">
            <p data-tip={routeTip.new} data-for="newRouteTip" className="flex-none">
              Create New Route
            </p>
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
