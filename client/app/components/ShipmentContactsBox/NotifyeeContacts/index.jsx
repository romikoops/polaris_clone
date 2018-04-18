import React from 'react'
import styles from '../ShipmentContactsBox.scss'
import { RoundButton } from '../../RoundButton/RoundButton'

export default function ShipmentContactsBoxNotifyeeContacts ({
  theme, notifyees
}) {
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-center">
      <div className="flex-100 layout-row layout-align-start">
        <h3>
          NOTIFYEES <span className={styles.subtext}> (Optional) </span>
        </h3>
      </div>
      <div style={{ marginRight: '40px' }}>
        <RoundButton theme={theme} text="BROWSE CONTACTS" size="small" active />
      </div>
      <a onClick={null} className={styles.link}>+ add contact</a>
    </div>
  )
}
