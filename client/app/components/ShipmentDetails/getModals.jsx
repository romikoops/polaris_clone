import React from 'react'
import { Modal } from '../Modal/Modal'
import { AlertModalBody } from '../AlertModalBody/AlertModalBody'

function getModal (name, theme, toggleFunc) {
  return (
    <Modal
      component={
        <AlertModalBody
          message={this.modals[name].message}
          logo={theme.logoSmall}
          toggleAlertModal={() => toggleFunc(name)}
        />
      }
      parentToggle={() => toggleFunc(name)}
    />
  )
}

export default function getModals (theme, user, tenant, toggleFunc) {
  const modals = {
    noDangerousGoods: {
      message: (
        <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
          <span>
            Hi {user.first_name} {user.last_name},<br />
            We currently do not offer freight rates for hazardous cargo in our Web Shop. Please
            contact our customer service departmentto place an order
            for your dangerous cargo:<br />
          </span>
          <br />

          <span style={{ marginRight: '10px' }}> Contact via phone:</span>
          <span>{tenant.data.phones.support}</span>
          <br />

          <span style={{ marginRight: '20px' }}> Contact via mail: </span>
          <span>
            <a href={`mailto:${tenant.data.emails.support}?subject=Dangerous Goods Request`}>
              {tenant.data.emails.support}
            </a>
          </span>
        </p>
      ),
      show: false
    },
    dangerousGoodsInfo: {
      message: <div />,
      show: false
    }
  }

  Object.keys(modals).forEach((modalName) => {
    modals[modalName].jsx = getModal(modalName, theme, toggleFunc)
  })

  return modals
}
