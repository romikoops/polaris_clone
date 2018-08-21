import React, { PureComponent } from 'react'
import styles from './index.scss'
import { switchIcon, gradientTextGenerator, numberSpacing, capitalize } from '../../../helpers'
import { ChargeIcons } from './ChargeIcons'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'

function filteredKeys (key) {
  Object.entries(key)
    .map(array => array.filter((value, index, arr) =>
      value !== 'total' && value !== 'edited_total'))
    .filter((value, index, arr) => value.length !== 1)
}

class QuoteCard extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  render () {
    const {
      theme,
      tenant,
      schedule,
      cargo
    } = this.props
    const {
      quote
    } = schedule
    const originHub = schedule.origin_hub
    const destinationHub = schedule.destination_hub
    const gradientStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    const calcPayload = cargo.reduce((a, b) => ({ total: a.payload_in_kg + b.payload_in_kg }))
    // const filteredKeys = Object.entries(quote.export)
    //   .map(array => array.filter((value, index, arr) =>
    //     value !== 'total' && value !== 'edited_total'))
    //   .filter((value, index, arr) => value.length !== 1)
    const pricesArr = Object.keys(quote).splice(2).length !== 0 ? (
      Object.keys(quote).splice(2).map(key => (<CollapsingBar
        showArrow
        collapsed={!this.state.expander[`${key}`]}
        theme={theme}
        contentStyle={styles.sub_price_row_wrapper}
        headerWrapClasses="flex-100 layout-row layout-wrap layout-align-start-center puppa"
        handleCollapser={() => this.toggleExpander(`${key}`)}
        mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
        contentHeader={(
          <div className={`flex-100 layout-row layout-align-start-center ${styles.price_row}`}>
            <div className="flex-none layout-row layout-align-start-center" />
            <div className="flex-45 layout-row layout-align-start-center">
              <span>{capitalize(key)}</span>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <p>{numberSpacing(quote[`${key}`].total.value, 1)}&nbsp;{quote.total.currency}</p>
            </div>
          </div>
        )}
        content={Object.entries(quote[`${key}`])
          .map(array => array.filter((value, index, arr) =>
            value !== 'total' && value !== 'edited_total'))
          .filter((value, index, arr) => value.length !== 1).map((price) => {
            const pop = (<div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
              <div className="flex-45 layout-row layout-align-start-center">
                <span>{price[0]}</span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                <p>{numberSpacing(price[1].value || price[1].total.value, 1)}&nbsp;{quote.total.currency}</p>
              </div>
            </div>)

            return pop
          })}
      />))
    ) : ''

    return (
      <div className={`flex-100 layout-row layout-wrap ${styles.wrapper}`}>
        <div className={`flex-100 layout-row layout-align-start-center ${styles.container}`}>
          <div className={`flex-10 layout-row layout-align-center-center ${styles.mot_icon}`}>
            {switchIcon(schedule.mode_of_transport, gradientStyle)}
          </div>
          <div className={`flex-60 layout-row layout-align-start-center ${styles.origin_destination}`}>
            <div className="layout-column layout-align-center-start">
              <p>From: <span>{originHub.name}</span></p>
              <p>To: <span>{destinationHub.name}</span></p>
            </div>
          </div>
          <div className="flex layout-row layout-wrap layout-align-end-center">
            <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.charge_icons}`}>
              <ChargeIcons
                theme={theme}
                tenant={tenant}
                onCarriage={quote.trucking_on}
                preCarriage={quote.trucking_pre}
                originFees={quote.export}
                destinationFees={quote.import}
              />
            </div>
            <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.unit_info}`}>
              <p className="flex-50 layout-row layout-align-center-center">
                {/* {`${numberSpacing(cargos.volume, 3)} m`} <sup>3</sup> */}
              </p>
              <p className="flex-50 layout-row layout-align-center-center">
                Kg:&nbsp; <span>{`${numberSpacing(calcPayload.payload_in_kg, 1)} kg`}</span>
              </p>
            </div>
          </div>
        </div>
        {pricesArr}
        <div className="flex-100 layout-wrap layout-align-start-start">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.total_row}`}>
            <div className="flex-50 layout-row layout-align-start-center">
              <span>Total</span>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <p>{numberSpacing(quote.total.value, 1)}&nbsp;{quote.total.currency}</p>
              <p>select checkbox</p>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default QuoteCard
