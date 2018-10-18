import React from 'react'
import { Modal } from '../Modal/Modal'
import AlertModalBody from '../AlertModalBody/AlertModalBody'

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

export default function getModals (props, toggleFunc, t) {
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
    nonStackable: {
      message: (
        <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
          <span>
            {t('common:hi')} {user.first_name} {user.last_name},<br />
            {t('cargo:nonStackableFirst')} {t('cargo:nonStackableSecond')}<br />
          </span>
          <br />

          <span style={{ marginRight: '10px' }}> {t('dangerousGoods:contactPhone')}:</span>
          <span>{tenant.data.phones.support}</span>
          <br />

          <span style={{ marginRight: '20px' }}> {t('dangerousGoods:contactEmail')} </span>
          <br />
          <span style={{ marginRight: '20px', marginLeft: '10px', fontSize: '12px' }}> - {t('common:oceanFreight')}: </span>
          <span>
            <a href={`mailto:${tenant.data.emails.support.ocean}?subject=Nonstackable Goods Request`}>
              {tenant.data.emails.support.ocean}
            </a>
          </span>
          <br />
          <span style={{ marginRight: '38px', marginLeft: '10px', fontSize: '12px' }}> - {t('common:airFreight')}: </span>
          <span>
            <a href={`mailto:${tenant.data.emails.support.air}?subject=Nonstackable Goods Request`}>
              {tenant.data.emails.support.air}
            </a>
          </span>
        </p>
      ),
      maxWidth: '600px',
      show: false
    },
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
          <span style={{ marginRight: '20px', marginLeft: '10px', fontSize: '12px' }}> - {t('common:oceanFreight')}: </span>
          <span>
            <a href={`mailto:${tenant.data.emails.support.ocean}?subject=Dangerous Goods Request`}>
              {tenant.data.emails.support.ocean}
            </a>
          </span>
          <br />
          <span style={{ marginRight: '38px', marginLeft: '10px', fontSize: '12px' }}> - {t('common:airFreight')}: </span>
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
          <h3>{t('dangerousGoods:dangerousCaps')}</h3>
          <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
            {'\''}{t('dangerousGoods:dangerousGoods')}{'\''} {t('dangerousGoods:dangerousGoodsOne')}
            {t('dangerousGoods:dangerousGoodsTwo')}<br />
            <br />
            {t('dangerousGoods:dangerousGoodsThree')} {t('dangerousGoods:dangerousGoodsFour')}
            {t('dangerousGoods:dangerousGoodsFive')} {t('dangerousGoods:dangerousGoodsSix')}
            {t('dangerousGoods:dangerousGoodsSeven')}<br />
            <br />
            {t('dangerousGoods:dangerousGoodsEight')} {t('dangerousGoods:dangerousGoodsNine')}<br />
            <br />
            {t('dangerousGoods:dangerousGoodsTen')}
            {t('dangerousGoods:dangerousGoodsEleven')}
            {t('dangerousGoods:dangerousGoodsTwelve')}<br />
            <br />
            {t('dangerousGoods:dangerousGoodsThirteen')}
            {t('dangerousGoods:dangerousGoodsFourteen')}
            {t('dangerousGoods:dangerousGoodsFifteen')}<br />
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
