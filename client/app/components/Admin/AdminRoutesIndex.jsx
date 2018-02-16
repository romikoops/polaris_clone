import React, { Component } from 'react'
import PropTypes from '../../prop-types'
// import {AdminRouteTile} from './';
import styles from './Admin.scss'
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader'
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
    const hubUrl = '/admin/itineraries/process_csv'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
        >
          <p className="flex-none">Upload Routes Sheet</p>
          <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Routes .xlsx" />
        </div>
        <AdminSearchableRoutes
          itineraries={itineraries}
          theme={theme}
          hubs={hubs}
          adminDispatch={adminDispatch}
          sideScroll={false}
          handleClick={viewItinerary}
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
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminRoutesIndex.defaultProps = {
  theme: null,
  hubs: [],
  loading: false
}

export default AdminRoutesIndex
