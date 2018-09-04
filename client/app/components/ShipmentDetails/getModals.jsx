import React from 'react'
import { translate } from 'react-i18next'
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

function getModals (props, toggleFunc, t) {
  if (!props) return null
  const { user, tenant } = props
  if (!user || !tenant) return null

  const dangerousGoodsClasses = [
    t('dangerousGoods:explosives'),
    t('dangerousGoods:gases'),
    t('dangerousGoods:flammableLiquids'),
    t('dangerousGoods:flammableSolids'),
    t('dangerousGoods:oxidizingSubstances'),
    t('dangerousGoods:toxicSubstances'),
    t('dangerousGoods:radioactive'),
    t('dangerousGoods:corrosives'),
    t('dangerousGoods:miscellaneous'),
    t('dangerousGoods:partlyDangerous')
  ]
  const modals = {
    noDangerousGoods: {
      message: (
        <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
          <span>
            {t('common:hi')} {user.first_name} {user.last_name},<br />
            {t('dangerousGoods:noDangerousFirst')} {t('dangerousGoods:noDangerousSecond')}<br />
          </span>
          <br />

          <span style={{ marginRight: '10px' }}> {t('dangerousGoods:contactPhone')}:</span>
          <span>{tenant.data.phones.support}</span>
          <br />

          <span style={{ marginRight: '20px' }}> {t('dangerousGoods:contactEmail')} </span>
          <br />
          <span style={{ marginRight: '20px', marginLeft: '10px', fontSize: '12px' }}> - ocean freight: </span>
          <span>
            <a href={`mailto:${tenant.data.emails.support.ocean}?subject=Dangerous Goods Request`}>
              {tenant.data.emails.support.ocean}
            </a>
          </span>
          <br />
          <span style={{ marginRight: '38px', marginLeft: '10px', fontSize: '12px' }}> - air freight: </span>
          <span>
            <a href={`mailto:${tenant.data.emails.support.air}?subject=Dangerous Goods Request`}>
              {tenant.data.emails.support.air}
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

export default translate(['dangerousGoods', 'common'])(getModals)
