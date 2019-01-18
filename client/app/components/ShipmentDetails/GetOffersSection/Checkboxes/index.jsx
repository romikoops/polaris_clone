import React from 'react'
import { withNamespaces } from 'react-i18next'
import CheckboxWrapper from './CheckboxWrapper'

function Checkboxes ({
  theme,
  noDangerousGoodsConfirmed, stackableGoodsConfirmed,
  onChangeNoDangerousGoodsConfirmation, onChangeStackableGoodsConfirmation,
  onClickDangerousGoodsInfo,
  shakeClass, show,
  t
}) {
  return (
    <div className="flex-60 layout-row layout-wrap layout-align-start-center">
      <CheckboxWrapper
        id="no_dangerous_goods_confirmation"
        name="no_dangerous_goods_confirmation"
        className={shakeClass.noDangerousGoodsConfirmed}
        theme={theme}
        checked={noDangerousGoodsConfirmed}
        onChange={onChangeNoDangerousGoodsConfirmation}
        show={show.noDangerousGoodsConfirmed}
        style={{ marginBottom: '28px' }}
        size="30px"
        labelContent={(
          <p style={{ margin: 0, fontSize: '14px' }}>
            {t('cargo:confirmSafe')}
            {' '}
            <span className="emulate_link blue_link" onClick={onClickDangerousGoodsInfo}>
              {t('common:dangerousGoods')}
            </span>
              .
          </p>
        )}
      />
      <CheckboxWrapper
        id="stackable_goods_confirmation"
        name="stackable_goods_confirmation"
        className={shakeClass.stackableGoodsConfirmed}
        theme={theme}
        checked={stackableGoodsConfirmed}
        onChange={onChangeStackableGoodsConfirmation}
        show={show.stackableGoodsConfirmed}
        style={{ marginBottom: '15px' }}
        size="30px"
        labelContent={(
          <p style={{ margin: 0, fontSize: '14px', width: '100%' }}>
            {t('cargo:confirmStackable')}
            <br />
            <span style={{ fontSize: '11px', width: '100%' }}>
              (
              {t('cargo:nonStackable')}
              {' '}
              {t('cargo:cargoUnits')}
              )
            </span>
          </p>
        )}
      />
    </div>
  )
}

export default withNamespaces(['cargo', 'common'])(Checkboxes)
