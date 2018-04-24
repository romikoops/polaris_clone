import React from 'react'
import styles from '../Body.scss'
import ContactSetterBodyNotifyeeContactsContactCard from './ContactCard'
import ContactSetterBodyNotifyeeContactsAddContactButton from './AddContactButton'
import PropTypes from '../../../../prop-types'

export default function ContactSetterBodyNotifyeeContacts ({
  theme, notifyees, showAddressBook, removeFunc
}) {
  const notifyeeContacts = notifyees.map((notifyee, i) => (
    <div className={`flex-40 ${i % 2 === 0 ? 'offset-5' : ''}`} style={{ marginBottom: '20px' }}>
      <ContactSetterBodyNotifyeeContactsContactCard
        theme={theme}
        contactData={notifyee}
        removeFunc={() => removeFunc(i)}
      />
    </div>
  ))
  notifyeeContacts.unshift((
    <div className="flex-40" style={{ marginBottom: '20px' }}>
      <ContactSetterBodyNotifyeeContactsAddContactButton
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
ContactSetterBodyNotifyeeContacts.propTypes = {
  theme: PropTypes.theme,
  notifyees: PropTypes.arrayOf(PropTypes.shape({
    contact: PropTypes.object,
    location: PropTypes.object
  })).isRequired,
  showAddressBook: PropTypes.func.isRequired,
  removeFunc: PropTypes.func.isRequired
}

ContactSetterBodyNotifyeeContacts.defaultProps = {
  theme: null
}
