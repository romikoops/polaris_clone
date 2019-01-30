import React from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { bookingProcessActions } from '../../../actions'
import RoundButton from '../../RoundButton/RoundButton'
import Checkboxes from './Checkboxes'
import ButtonWrapper from './ButtonWrapper'
import { isQuote } from '../../../helpers'
import styles from './index.scss'
import ErrorMessage from './ErrorMessage';

class GetOffersSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.initialShakeClass = {
      noDangerousGoodsConfirmed: '',
      stackableGoodsConfirmed: ''
    }

    this.state = {
      noDangerousGoodsConfirmed: false,
      stackableGoodsConfirmed: false,
      shakeClass: this.initialShakeClass
    }

    this.noDangerousGoodsCondition = this.noDangerousGoodsCondition.bind(this)
    this.stackableGoodsCondition = this.stackableGoodsCondition.bind(this)
    this.resetShakeClass = this.resetShakeClass.bind(this)
    this.getOffersBtnIsActive = this.getOffersBtnIsActive.bind(this)
    this.toggleStateProperty = this.toggleStateProperty.bind(this)
    this.toggleNoDangerousGoodsConfirmed = this.toggleNoDangerousGoodsConfirmed.bind(this)
    this.toggleStackableGoodsConfirmed = this.toggleStackableGoodsConfirmed.bind(this)
    this.cargoContainsDangerousGoods = this.cargoContainsDangerousGoods.bind(this)
    this.handleClickDangerousGoodsInfo = this.handleClickDangerousGoodsInfo.bind(this)
  }

  getOffersBtnIsActive () {
    const { getOffersDisabled } = this.props

    return !getOffersDisabled && this.noDangerousGoodsCondition() && this.stackableGoodsCondition()
  }

  cargoContainsDangerousGoods () {
    const { shipment } = this.props
    const { cargoUnits } = shipment

    return cargoUnits.some(cargoUnit => cargoUnit.dangerous_goods)
  }

  noDangerousGoodsCondition () {
    const { noDangerousGoodsConfirmed } = this.state

    return noDangerousGoodsConfirmed || this.cargoContainsDangerousGoods()
  }

  stackableGoodsCondition () {
    const { stackableGoodsConfirmed } = this.state
    const { shipment } = this.props
    const { aggregatedCargo } = shipment

    return stackableGoodsConfirmed || !aggregatedCargo
  }

  resetShakeClass () {
    this.setState({ shakeClass: this.initialShakeClass })
  }

  handleGetOffersDisabled () {
    this.setState(prevState => ({
      shakeClass: {
        noDangerousGoodsConfirmed: this.noDangerousGoodsCondition() ? '' : 'apply_shake',
        stackableGoodsConfirmed: this.stackableGoodsCondition() ? '' : 'apply_shake'
      }
    }))
    setTimeout(this.resetShakeClass, 1000)
  }

  toggleStateProperty (property) {
    this.setState(prevState => ({ [property]: !prevState[property] }))
  }

  toggleNoDangerousGoodsConfirmed () {
    this.toggleStateProperty('noDangerousGoodsConfirmed')
  }

  toggleStackableGoodsConfirmed () {
    this.toggleStateProperty('stackableGoodsConfirmed')
  }

  handleClickDangerousGoodsInfo () {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateModals('dangerousGoodsInfo')
  }

  render () {
    const {
      user, tenant, theme, shipment, totalShipmentErrors, t
    } = this.props

    const { aggregatedCargo, loadType } = shipment

    const { shakeClass, noDangerousGoodsConfirmed, stackableGoodsConfirmed } = this.state

    const active = this.getOffersBtnIsActive()
    const disabled = !active

    const subTexts = []

    if (loadType === 'cargo_item') {
      Object.entries(totalShipmentErrors).forEach(([name, obj]) => {
        if (!obj.errors) return
  
        obj.errors.forEach((error) => {
          subTexts.push(
            <ErrorMessage
              error={error}
              type={obj.type}
              name={name}
              tenant={tenant}
            />
          )
        })
      })
    }

    return (
      <div
        className={`
          get_offers_section layout-row flex-100 layout-wrap
          layout-align-center-center margin_top ${styles.get_offers_section}
        `}
      >
        <div className={`
          ${styles.border_divider} border_divider
          layout-row flex-100 layout-wrap layout-align-center-center
        `}
        >
          <div
            className={
              `${styles.btn_sec} content_width_booking ` +
              'layout-row flex-none layout-wrap layout-align-start-start'
            }
          >
            <Checkboxes
              theme={theme}
              noDangerousGoodsConfirmed={noDangerousGoodsConfirmed}
              stackableGoodsConfirmed={stackableGoodsConfirmed}
              onChangeNoDangerousGoodsConfirmation={this.toggleNoDangerousGoodsConfirmed}
              onChangeStackableGoodsConfirmation={this.toggleStackableGoodsConfirmed}
              onClickDangerousGoodsInfo={this.handleClickDangerousGoodsInfo}
              shakeClass={shakeClass}
              show={{
                noDangerousGoodsConfirmed: !this.cargoContainsDangerousGoods(),
                stackableGoodsConfirmed: aggregatedCargo
              }}
            />

            <div className="flex-100 layout-row layout-wrap layout-align-end">
              <ButtonWrapper
                show={user && !user.guest}
                text={t('common:back')}
                onClick={this.returnToDashboard}
                theme={theme}
                iconClass="fa-angle-left"
                type="button"
                back
              />
              <ButtonWrapper
                text={isQuote(tenant) ? t('common:getQuotes') : t('common:getOffers')}
                onClickDisabled={this.handleGetOffersDisabled}
                active={active}
                disabled={disabled}
                theme={theme}
                subTexts={subTexts}
              />
            </div>
          </div>
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, app, authentication } = state
  const { user } = authentication
  const { shipment } = bookingProcess
  const { tenant } = app
  const { theme, scope } = tenant

  return {
    shipment, theme, scope, tenant, user
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default withNamespaces('common')(connect(mapStateToProps, mapDispatchToProps)(GetOffersSection))
