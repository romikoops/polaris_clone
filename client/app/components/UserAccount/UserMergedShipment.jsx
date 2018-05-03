import React from 'react'
import PropTypes from 'prop-types'
import styles from './UserAccount.scss'
import { capitalize } from '../../helpers'

export function UserMergedShipment ({ ship, viewShipment }) {
  return (
    <div
      className={`flex-100 layout-row layout-align-start-center pointy ${styles.ship_row}`}
      onClick={() => viewShipment(ship)}
    >
      <div className={`flex-40 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
        <p className="flex-none">
          {ship.originHub} - {ship.destinationHub}
        </p>
      </div>
      <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
        <p className="flex-none">{ship.imc_reference}</p>
      </div>
      <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
        <p className="flex-none">{capitalize(ship.status)}</p>
      </div>
      <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
        {/* <p className="flex-none">{ship.incoterm}</p> */}
      </div>
      <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
        <p className="flex-none"> Yes </p>
      </div>
    </div>
  )
}

UserMergedShipment.propTypes = {
  viewShipment: PropTypes.func.isRequired,
  ship: PropTypes.shape({
    originHub: PropTypes.string,
    destinationHub: PropTypes.string,
    imc_reference: PropTypes.string,
    status: PropTypes.string,
    incoterm: PropTypes.string
  }).isRequired
}

export default UserMergedShipment
