import React from 'react'
import { Modal } from '../Modal/Modal'
import AlertModalBody from '../AlertModalBody/AlertModalBody'
import { capitalize } from '../../helpers/stringTools'

function modalJSX (name, modal, theme, toggleFunc) {
  return (
    <Modal
      component={(
        <AlertModalBody
          message={modal.message}
          logo={theme.logoSmall}
          toggleAlertModal={() => toggleFunc(name)}
          maxWidth={modal.maxWidth}
        />
      )}
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

  const supportEmailObjs = tenant.emails.support
  const supportEmailTexts = supportEmailObjs ? Object.keys(supportEmailObjs).map((keyDepartment, i) => {
    const department = (() => {
      switch (keyDepartment.toLowerCase()) {
        case 'ocean':
          return t('common:oceanFreight')
        case 'air':
          return t('common:airFreight')
        default:
          return capitalize(keyDepartment)
      }
    })()

    return (
      <span key={`support-email-${i}`}>
        <span style={{ marginLeft: '10px' }}>
          {'- '}
          {department}
          {': '}
        </span>
        <span>
          <a href={`mailto:${supportEmailObjs[keyDepartment]}?subject=Nonstackable Goods Request`}>
            {supportEmailObjs[keyDepartment]}
          </a>
        </span>
        <br />
      </span>
    )
  }) : ''

  const modals = {
    nonStackable: {
      message: (
        <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
          <span>
            {t('common:hi')}
            {' '}
            {user.first_name}
            {' '}
            {user.last_name}
            {','}
            <br />
            {t('cargo:nonStackableFirst')}
            {' '}
            {t('cargo:nonStackableSecond')}
            <br />
          </span>
          <br />

          <span style={{ marginRight: '10px' }}>
            {' '}
            {t('dangerousGoods:contactPhone')}
            {':'}
          </span>
          <span>{tenant.phones.support}</span>
          <br />
          {supportEmailObjs ? (
            <span style={{ marginRight: '20px' }}>
              {' '}
              {t('dangerousGoods:contactEmail')}
              {':'}
            </span>
          ) : ''}
          <br />
          {supportEmailTexts}
        </p>
      ),
      maxWidth: '600px',
      show: false
    },
    noDangerousGoods: {
      message: (
        <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
          <span>
            {t('common:hi')}
            {' '}
            {user.first_name}
            {' '}
            {user.last_name}
            {','}
            <br />
            {t('dangerousGoods:noDangerousFirst')}
            {' '}
            {t('dangerousGoods:noDangerousSecond')}
            <br />
          </span>
          <br />

          <span style={{ marginRight: '10px' }}>
            {' '}
            {t('dangerousGoods:contactPhone')}
            {':'}
          </span>
          <span>{tenant.phones.support}</span>
          <br />
          {supportEmailObjs ? (
            <span style={{ marginRight: '20px' }}>
              {' '}
              {t('dangerousGoods:contactEmail')}
              {':'}
            </span>
          ) : ''}
          <br />
          {supportEmailTexts}
        </p>
      ),
      maxWidth: '600px',
      show: false
    },
    maxDimensions: {
      message: (
        <p style={{ textAlign: 'justify', lineHeight: '1.5' }}>
          <span>
            {t('common:hi')}
            {' '}
            {user.first_name}
            {' '}
            {user.last_name}
            {','}
            <br />
            {t('cargo:maxDimensionsAlertFirst')}
            {' '}
            {t('cargo:pleaseContact')}
            <br />
          </span>
          <br />

          <span style={{ marginRight: '10px' }}>
            {' '}
            {t('dangerousGoods:contactPhone')}
            {':'}
          </span>
          <span>{tenant.phones.support}</span>
          <br />
          {supportEmailObjs ? (
            <span style={{ marginRight: '20px' }}>
              {' '}
              {t('dangerousGoods:contactEmail')}
              {':'}
            </span>
          ) : ''}
          <br />
          {supportEmailTexts}
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
            {'\''}
            {t('dangerousGoods:dangerousGoods')}
            {'\''}
            {' '}
            {t('dangerousGoods:dangerousGoodsOne')}
            {t('dangerousGoods:dangerousGoodsTwo')}
            <br />
            <br />
            {t('dangerousGoods:dangerousGoodsThree')}
            {' '}
            {t('dangerousGoods:dangerousGoodsFour')}
            {t('dangerousGoods:dangerousGoodsFive')}
            {' '}
            {t('dangerousGoods:dangerousGoodsSix')}
            {t('dangerousGoods:dangerousGoodsSeven')}
            <br />
            <br />
            {t('dangerousGoods:dangerousGoodsEight')}
            {' '}
            {t('dangerousGoods:dangerousGoodsNine')}
            <br />
            <br />
            {t('dangerousGoods:dangerousGoodsTen')}
            {t('dangerousGoods:dangerousGoodsEleven')}
            {t('dangerousGoods:dangerousGoodsTwelve')}
            <br />
            <br />
            {t('dangerousGoods:dangerousGoodsThirteen')}
            {t('dangerousGoods:dangerousGoodsFourteen')}
            {t('dangerousGoods:dangerousGoodsFifteen')}
            <br />
            <br />
          </p>
          <ol>
            { dangerousGoodsClasses.map((dangerousGoodsClass, i) => (
              <li key={`dangerous-goods-${i}`}>
                {' '}
                { dangerousGoodsClass}
                {' '}
              </li>
            )) }
          </ol>
        </div>
      ),
      maxWidth: '800px',
      show: false
    }
  }

  Object.keys(modals).forEach((modalName) => {
    modals[modalName].jsx =
      modalJSX(modalName, modals[modalName], tenant.theme, toggleFunc)
  })

  return modals
}
