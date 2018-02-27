import React, { Component } from 'react'
import PropTypes from '../../prop-types'
// import {AdminRouteTile} from './';
import styles from './Admin.scss'
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader'
import { AdminSearchableTruckings } from './AdminSearchables'
import { RoundButton } from '../RoundButton/RoundButton'

export class AdminTruckingIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }
  componentDidMount () {
    const { truckingNexuses, loading, adminDispatch } = this.props
    if (!truckingNexuses && !loading) {
      adminDispatch.getTrucking(false)
    }
  }
  render () {
    const {
      theme, viewTrucking, truckingNexuses, adminDispatch
    } = this.props
    if (!truckingNexuses) {
      return ''
    }
    const cityUrl = '/admin/trucking/trucking_city_pricings'
    const zipUrl = '/admin/trucking/trucking_zip_pricings'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
        >
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90">Upload Trucking City Sheet</p>
            <FileUploader theme={theme} url={cityUrl} type="xlsx" text="Routes .xlsx" />
          </div>
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90">Upload Trucking Zip Code Sheet</p>
            <FileUploader theme={theme} url={zipUrl} type="xlsx" text="Routes .xlsx" />
          </div>
          <div className="flex-33 layout-row layout-align-center-center">
            <p className="flex-90">Create a New Trucking Price</p>
            <RoundButton
              theme={theme}
              size="small"
              text="New Price"
              active
              handleNext={() => adminDispatch.goTo('/admin/trucking/new/creator')}
              iconClass="fa-plus"
            />
          </div>
        </div>
        <AdminSearchableTruckings
          theme={theme}
          truckings={truckingNexuses}
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
  viewTrucking: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getTrucking: PropTypes.func
  }).isRequired,
  truckingNexuses: PropTypes.arrayOf(PropTypes.shape({
    _id: PropTypes.number
  }))
}

AdminTruckingIndex.defaultProps = {
  theme: null,
  loading: false,
  truckingNexuses: []
}

export default AdminTruckingIndex
