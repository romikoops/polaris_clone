import React, { Component } from 'react'
import PropTypes from '../../prop-types'
// import {AdminRouteTile} from './';
import styles from './Admin.scss'
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader'
import { AdminSearchableHubs } from './AdminSearchables'

export class AdminTruckingIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }
  componentDidMount () {
    const { truckingHubs, loading, adminDispatch } = this.props
    if (!truckingHubs && !loading) {
      adminDispatch.getTrucking(false)
    }
  }
  render () {
    const {
      theme, viewTrucking, hubs, truckingHubs, adminDispatch
    } = this.props
    if (!truckingHubs) {
      return ''
    }

    const cityUrl = '/admin/trucking/trucking_city_pricings'
    const zipUrl = '/admin/trucking/trucking_zip_pricings'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
        >
          <div className="flex-50 layout-row layout-wrap layout-align-start-start">
            <p className="flex-90">Upload Trucking City Sheet</p>
            <FileUploader theme={theme} url={cityUrl} type="xlsx" text="Routes .xlsx" />
          </div>
          <div className="flex-50 layout-row layout-wrap layout-align-start-start">
            <p className="flex-90">Upload Trucking Zip Code Sheet</p>
            <FileUploader theme={theme} url={zipUrl} type="xlsx" text="Routes .xlsx" />
          </div>
        </div>
        <AdminSearchableHubs
          theme={theme}
          hubs={hubs}
          adminDispatch={adminDispatch}
          sideScroll={false}
          handleClick={viewTrucking}
        />
      </div>
    )
  }
}
AdminTruckingIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  viewTrucking: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getTrucking: PropTypes.func
  }).isRequired,
  truckingHubs: PropTypes.arrayOf(PropTypes.shape({
    _id: PropTypes.number
  }))
}

AdminTruckingIndex.defaultProps = {
  theme: null,
  hubs: [],
  loading: false,
  truckingHubs: []
}

export default AdminTruckingIndex
