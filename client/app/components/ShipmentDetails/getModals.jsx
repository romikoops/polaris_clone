import React from 'react'
import { Modal } from '../Modal/Modal'
import { AlertModalBody } from '../AlertModalBody/AlertModalBody'

function modalJSX (name, modal, theme, toggleFunc) {
  return (
    <Modal
      component={
        <AlertModalBody
          message={modal.message}
          logo={theme.logoSmall}
          toggleAlertModal={() => toggleFunc(name)}
          maxWidth={modal.maxWidth}
        />
      }
      parentToggle={() => toggleFunc(name)}
    />
  )
}

export default function getModals (props, toggleFunc) {
  if (!props) return null
  const { user, tenant } = props
  if (!user || !tenant) return null

  const dangerousGoodsClasses = [
    'Explosives',
    'Gases',
    'Flammable Liquids',
    'Flammable Solids',
    'Oxidizing Substances',
    'Toxic & Infectious Substances',
    'Radioactive Material',
    'Corrosives',
    'Miscellaneous Dangerous Goods',
    'Cargo partly consisting of above can also be DGR'
  ]
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
      maxWidth: '600px',
      show: false
    },
    dangerousGoodsInfo: {
      message: (
        <div>
          <h3>DANGEROUS GOODS</h3>
          <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
            {'\''}Dangerous goods{'\''} are materials or items with
            hazardous properties which, if not properly controlled,
            present a potential hazard to human health and safety,
            infrastructure and/ or their means of transport.<br />
            <br />
            The transportation of dangerous goods is controlled and
            governed by a variety of different regulatory regimes,
            operating at both the national and international levels.
            Prominent regulatory frameworks for the transportation of
            dangerous goods include the United Nations Recommendations on the
            Transport of Dangerous Goods, ICAO’s Technical Instructions,
            IATA’s Dangerous Goods Regulations and the IMO’s
            International Maritime Dangerous Goods Code.<br />
            <br />
            Collectively, these regulatory regimes mandate the means by which
            dangerous goods are to be handled, packaged, labelled and transported.<br />
            <br />
            Regulatory frameworks incorporate comprehensive classification systems
            of hazards to provide a taxonomy of dangerous goods.
            Classification of dangerous goods is broken down into nine classes
            according to the type of danger materials or items present;<br />
            <br />
            Batteries are dangerous goods;
            batteries are used in many electronic devices such as
            cameras, cell phones, laptop computers, medical equipment and power tools.<br />
            <br />
          </p>
          <ol>
            { dangerousGoodsClasses.map(dangerousGoodsClass => <li> { dangerousGoodsClass} </li>) }
          </ol>
        </div>
      ),
      maxWidth: '800px',
      show: false
    }
  }

  Object.keys(modals).forEach((modalName) => {
    modals[modalName].jsx =
      modalJSX(modalName, modals[modalName], tenant.data.theme, toggleFunc)
  })

  return modals
}
