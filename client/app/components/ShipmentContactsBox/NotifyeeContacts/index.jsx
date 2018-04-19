import React from 'react'
import styles from '../ShipmentContactsBox.scss'
import { RoundButton } from '../../RoundButton/RoundButton'
import ShipmentContactsBoxNotifyeeContactsContactCard from './ContactCard'

export default function ShipmentContactsBoxNotifyeeContacts ({
  theme, notifyees, showAddressBook, removeFunc
}) {
  const notifyeeContacts = notifyees.map((notifyee, i) => (
    <div className={`flex-40 ${i % 2 !== 0 ? 'offset-5' : ''}`} style={{ marginBottom: '20px' }}>
      <ShipmentContactsBoxNotifyeeContactsContactCard
        theme={theme}
        contactData={notifyee}
        removeFunc={() => removeFunc(i)}
      />
    </div>
  ))

  return (
    <div className="flex-100">
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div className="flex-100 layout-row layout-align-start">
          <h3>
            NOTIFYEES <span className={styles.subtext}> (Optional) </span>
          </h3>
        </div>
        <div className={
          `${styles.notifyee_contacts_sec} flex-100 ` +
          'layout-row layout-wrap layout-align-start'
        }
        >
          { notifyeeContacts }
        </div>
        <div style={{ marginRight: '40px' }}>
          <RoundButton
            theme={theme}
            text="BROWSE CONTACTS"
            size="small"
            handleNext={() => showAddressBook('notifyee', notifyees.length)}
            active
          />
        </div>
        <a onClick={null} className={styles.link}>+ add contact</a>
      </div>
    </div>
  )
}
