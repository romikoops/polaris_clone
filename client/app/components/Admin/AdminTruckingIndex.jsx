import React, { Component } from 'react'
import AdminHubsComp from './Hubs/AdminHubsComp' // eslint-disable-line

export class AdminTruckingIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }

  render () {
    const {
      viewTrucking
    } = this.props

    return (
      <div className="flex-100 layout-row layout-align-center-start">
        <AdminHubsComp handleClick={viewTrucking} showLocalExpiry={false}/>
      </div>
    )
  }
}

AdminTruckingIndex.defaultProps = {
  loading: false
}

export default AdminTruckingIndex
