import React, { PureComponent } from 'react'
import AdminShipmentsComp from './Shipments/Comp' // eslint-disable-line

export class AdminShipmentsIndex extends PureComponent {
  componentDidMount () {
    window.scrollTo(0, 0)
  }

  render () {
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {/* {listView} */}
        <AdminShipmentsComp />
      </div>
    )
  }
}
AdminShipmentsIndex.propTypes = {
}

AdminShipmentsIndex.defaultProps = {
}

export default AdminShipmentsIndex
