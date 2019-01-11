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
    this.handleGetOffersDisabled = this.handleGetOffersDisabled.bind(this)
    this.getOffersBtnIsActive = this.getOffersBtnIsActive.bind(this)
    this.toggleStateProperty = this.toggleStateProperty.bind(this)
    this.toggleNoDangerousGoodsConfirmed = this.toggleNoDangerousGoodsConfirmed.bind(this)
    this.toggleStackableGoodsConfirmed = this.toggleStackableGoodsConfirmed.bind(this)
    this.cargoContainsDangerousGoods = this.cargoContainsDangerousGoods.bind(this)
  }

  getOffersBtnIsActive () {
    // TODO: implement excessWeightText
    const excessWeightText = ''

    return this.noDangerousGoodsCondition() && this.stackableGoodsCondition() && !excessWeightText
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

    // TODO: implement agregated
    const aggregated = false

    return stackableGoodsConfirmed || !aggregated
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
    // TODO: implement toggleModal
    // toggleModal('dangerousGoodsInfo')
    console.log(this.props)
  }

  render () {
    const {
      user, tenant, theme, t
    } = this.props

    const { shakeClass, noDangerousGoodsConfirmed, stackableGoodsConfirmed } = this.state

    const active = this.getOffersBtnIsActive()
    const disabled = !active

    // TODO: implement excessChargeableWeightText
    const excessChargeableWeightText = ''
    // TODO: implement excessWeightText
    const excessWeightText = ''
    // TODO: implement agregated
    const aggregated = false

    return (
      <div className="get_offers_section">
        <div className="border_divider layout-row flex-100 layout-wrap layout-align-center-center">
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
              shakeClass={shakeClass}
              show={{
                noDangerousGoodsConfirmed: !this.cargoContainsDangerousGoods(),
                stackableGoodsConfirmed: aggregated
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
                subTexts={[excessChargeableWeightText, excessWeightText]}
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
    shipment, theme, scope, user
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default withNamespaces('common')(connect(mapStateToProps, mapDispatchToProps)(GetOffersSection))
