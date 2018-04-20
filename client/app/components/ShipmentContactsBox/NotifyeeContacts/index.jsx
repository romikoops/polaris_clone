import React from 'react'
import styles from '../ShipmentContactsBox.scss'
import ShipmentContactsBoxNotifyeeContactsContactCard from './ContactCard'
import ShipmentContactsBoxNotifyeeContactsAddContactButton from './AddContactButton'

export default function ShipmentContactsBoxNotifyeeContacts ({
  theme, notifyees, showAddressBook, removeFunc
}) {
  const notifyeeContacts = notifyees.map((notifyee, i) => (
    <div className={`flex-40 ${i % 2 === 0 ? 'offset-5' : ''}`} style={{ marginBottom: '20px' }}>
      <ShipmentContactsBoxNotifyeeContactsContactCard
        theme={theme}
        contactData={notifyee}
        removeFunc={() => removeFunc(i)}
      />
    </div>
  ))
  notifyeeContacts.unshift((
    <div className="flex-40" style={{ marginBottom: '20px' }}>
      <ShipmentContactsBoxNotifyeeContactsAddContactButton
        onClick={() => showAddressBook('notifyee', notifyees.length)}
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
      </div>
    </div>
  )
}
