import React from 'react'
import PropTypes from 'prop-types'
import styles from './index.scss'
import { capitalize } from '../../../helpers'
import { Modal } from '../../Modal/Modal'

export const HelpContact = ({ tenant }) => {
  const { theme, emails } = tenant.data
  const iconStyle = { color: theme.colors.primary }
  const emailsToRender = Object.keys(emails.support)
    .filter(ek => ek !== 'general')
    .map(ek => (
      <div className={`${styles.email_row} flex-100 layout-row layout-align-space-between-center`}>
        <div className="flex-55 layout-row layout-align-start-center">
          <p className="flex-none no_m">{capitalize(ek)}:</p>
        </div>
        <div className={`${styles.email_box} flex-45 layout-row layout-align-space-around-center`}>
          <div className="flex-20 layout-row layoutalign-center-center">
            <i className="fa fa-envelope flex-none" style={iconStyle} />
          </div>
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
        <h3 className="flex-90 offset-5">Need help?</h3>
      </div>
      <div className="flex-100 layout-row.layout-align-start-center layout-wrap">
        <p className="flex-none offset-5"> Send an email detailing your issues to:</p>
      </div>
      <div
        className={`${styles.help_content} flex-100 layout-row layout-align-start-start layout-wrap`}
      >
        <div className={`${styles.email_row} flex-100 layout-row layout-align-space-between-center`}>
          <div className="flex-55 layout-row layout-align-start-center">
            <p className="flex-none no_m">General Enquiries: </p>
          </div>
          <div className={`${styles.email_box} flex-45 layout-row layout-align-end-center`}>
            <div className="flex-20 layout-row layoutalign-center-center">
              <i className="fa fa-envelope flex-none" style={iconStyle} />
            </div>
            <a href={`mailto:${emails.support.general}`} className="flex-80 pointy">
              {emails.support.general}
            </a>
          </div>
        </div>
        {emailsToRender}
      </div>
    </div>
  )

  return <Modal component={componentToRender} theme={theme} />
}

HelpContact.propTypes = {
  tenant: PropTypes.tenant
}

HelpContact.defaultProps = {
  tenant: {}
}

export default HelpContact
