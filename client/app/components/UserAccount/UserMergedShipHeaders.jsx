import React from 'react'
import PropTypes from 'prop-types'

export function UserMergedShipHeaders (props) {
  const { title, total } = props
  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <div className="flex-40 layout-row layout-align-start-center">
        <h3 className="flex-none" style={{ paddingRight: '10px' }}>
          {title}
        </h3>
        <h3 className="flex-none">({total})</h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none"> Reference </h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none">Status </h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none">Incoterm </h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none">Requires Action </h3>
      </div>
    </div>
  )
}

UserMergedShipHeaders.propTypes = {
  title: PropTypes.string.isRequired,
  total: PropTypes.string.isRequired
}

export default UserMergedShipHeaders
