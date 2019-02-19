import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import { capitalize } from '../../../helpers'
import { Modal } from '../../Modal/Modal'

const HelpContact = ({ tenant, t, parentToggle }) => {
  const { theme, emails, phones } = tenant
  const iconStyle = { color: theme.colors.primary, marginRight: '10px' }
  const emailsToRender = Object.keys(emails.support)
    .filter(ek => ek !== 'general')
    .map(ek => (
      <div className={`${styles.email_row} flex-100 layout-row layout-align-space-between-center`}>
        <div className="flex-30 layout-row layout-align-start-center">
          <p className="flex-none no_m"><strong>{capitalize(ek)}:</strong></p>
        </div>
        <div className={`${styles.email_box} flex-70 layout-row layout-align-start-center`}>
          <i className="fa fa-envelope flex-none" style={iconStyle} />
          <a href={`mailto:${emails.support[ek]}`} className="flex-80 pointy">
            {emails.support[ek]}
          </a>
        </div>
      </div>
    ))
  const componentToRender = (
    <div
      className={`${
        styles.body_wrapper
      } flex-100 layout-row layout-align-center-center layout-wrap`}
    >
      <div className={`${styles.help_header} flex-100 layout-row.layout-align-start-center `}>
        <h3 className="flex-90 offset-5">{t('help:needHelp')}</h3>
      </div>
      <div className={`${styles.help_content} flex-100 layout-row.layout-align-start-center layout-wrap`}>
        <p className="flex-none" style={{ marginTop: '18px' }}>{t('help:sendEmail')}</p>
      </div>
      <div
        className={`${styles.help_content} flex-100 layout-row layout-align-start-start layout-wrap`}
      >
        <div className={`${styles.email_row} flex-100 layout-row layout-align-space-between-center layout-wrap`}>
          <div className="flex-30 layout-row layout-align-start-center">
            <p className="flex-none no_m"><strong>{t('help:enquiries')}</strong></p>
          </div>
          <div className={`${styles.email_box} flex-70 layout-row layout-align-start-center layout-wrap`}>
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-envelope flex-none" style={iconStyle} />
              <a href={`mailto:${emails.support.general}`} className="flex-80 pointy">
                {emails.support.general}
              </a>
            </div>
            { phones.support ? (<div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-phone flex-none" style={iconStyle} />
              <a href={`tel:${phones.support}`} className="flex-80 pointy">
                {phones.support}
              </a>
            </div>) : '' }
          </div>

        </div>
        {emailsToRender}
      </div>
    </div>
  )

  return <Modal component={componentToRender} theme={theme} parentToggle={parentToggle}/>
}


HelpContact.defaultProps = {
  tenant: {}
}

export default withNamespaces('help')(HelpContact)
