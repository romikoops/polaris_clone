import React from 'react'
import styles from '../AdminShipments.scss'
import PropTypes from '../../../prop-types'

export default function ShipmentOverviewShowCard ({
  et,
  hubs,
  bg,
  editTime,
  handleSaveTime,
  toggleEditTime
}) {
  return (
    <div className="flex-100 layout-row">
      <div className={`${styles.info_hub_box} flex-60 layout-column`}>
        <h3>{hubs.startHub.data.name}</h3>
        <p className={styles.address}>{hubs.startHub.data.geocoded_address}</p>
        <div className="layout-row layout-align-start-center">
          <div className="layout-column flex-60 layout-align-center-start">
            <span>
            ETD
            </span>
            <div className="layout-row layout-align-start-center">
              {et}
            </div>
          </div>
          <div className="layout-row flex-40 layout-align-center-stretch">
            {editTime ? (
              <span className="layout-column flex-100 layout-align-center-stretch">
                <div
                  onClick={handleSaveTime}
                  className={`layout-row flex-50 ${styles.save} layout-align-center-center`}
                >
                  <i className="fa fa-check" />
                </div>
                <div
                  onClick={toggleEditTime}
                  className={`layout-row flex-50 ${styles.cancel} layout-align-center-center`}
                >
                  <i className="fa fa-times" />
                </div>
              </span>
            ) : (
              <i onClick={toggleEditTime} className={`fa fa-edit ${styles.editIcon}`} />
            )}
          </div>
        </div>
      </div>
      <div className={`layout-column flex-40 ${styles.image}`} style={bg} />
    </div>
  )
}

ShipmentOverviewShowCard.propTypes = {
  et: PropTypes.node.isRequired,
  hubs: PropTypes.objectOf(PropTypes.hub).isRequired,
  bg: PropTypes.objectOf(PropTypes.string),
  editTime: PropTypes.bool,
  handleSaveTime: PropTypes.func.isRequired,
  toggleEditTime: PropTypes.func.isRequired
}

ShipmentOverviewShowCard.defaultProps = {
  bg: {},
  editTime: false
}
