import React from 'react'
import { withNamespaces } from 'react-i18next'
import AlertModalBody from '../AlertModalBody/AlertModalBody'
import { Modal } from '../Modal/Modal'

function DeleteAccountModal ({
  tenant, user, theme, closeModal, t
}) {
  if (!user || !tenant || !theme) return ''

  return (
    <Modal
      component={(
        <AlertModalBody
          message={(
            <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
              <span>
                {t('common:hi')}
                {' '}
                {user.first_name}
                {' '}
                {user.last_name}
                {','}
                <br />
                {t('account:deleteAccountRequestParagraph')}
                {':'}
                <br />
              </span>
              <br />

              <span style={{ marginRight: '10px' }}>
                {' '}
                {t('account:contactPhone')}
                {':'}
              </span>
              <span>{tenant.phones.support}</span>
              <br />
              <span style={{ marginRight: '10px' }}>
                {' '}
                {t('account:contactEmail')}
                {':'}
              </span>
              <span>
                <a href={`mailto:${tenant.emails.support.general}?subject=Request Delete Account`}>
                  {tenant.emails.support.general}
                </a>
              </span>
            </p>
          )}
          logo={theme.logoSmall}
          toggleAlertModal={closeModal}
        />
      )}
      parentToggle={closeModal}
    />
  )
}

export default withNamespaces(['common', 'account'])(DeleteAccountModal)
