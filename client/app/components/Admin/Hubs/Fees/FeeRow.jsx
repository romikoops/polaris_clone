import React, { PureComponent } from 'react'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import styles from './index.scss'
import PropTypes from '../../../../prop-types'
import { gradientCSSGenerator } from '../../../../helpers'
import { NamedSelect } from '../../../NamedSelect/NamedSelect'
import {
  chargeGlossary,
  rateBasises,
  lclPricingSchema,
  fclPricingSchema,
  // cargoGlossary,
  rateBasisSchema,
  moment,
  currencyOptions
} from '../../../../constants'

class FeeRow extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      edit: false
    }
  }
  toggleEdit () {
    this.setState({ edit: !this.state.edit })
  }
  renderFeeBoxes (fee, selectOptions, direction, edit) {
    const dnrKeys = ['currency', 'rate_basis', 'key', 'name', 'range']
    const dateKeys = ['effective_date', 'expiration_date']
    let feeKeys = []
    switch (fee.rate_basis) {
      case 'PER_SHIPMENT' || 'PER_BILL' || 'PER_ITEM' || 'PER_CONTAINER' || 'PER_WM':
        feeKeys = ['value', 'min']
        break
      case 'PER_CBM':
        feeKeys = ['cbm', 'min']
        break
      case 'PER_KG':
        feeKeys = ['kg', 'min']
        break
      case 'PER_CBM_TON':
        feeKeys = ['cbm', 'ton', 'min']
        break
      case 'PER_TON':
        feeKeys = ['ton', 'min']
        break
      case /RANGE/:
        break
      default:
        feeKeys = ['value', 'min']
        break
    }
    const cells = []

    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days')
          .format())
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }
    const rbCell = edit ? (<div
      className={`flex layout-row layout-align-none-center layout-wrap ${
        styles.price_cell
      }`}
    >
      <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary.rate_basis}</p>
      <NamedSelect
        name={`${direction}-${fee.key}-${'rate_basis'}`}
        classes={`${styles.select}`}
        value={selectOptions ? selectOptions[direction][fee.key].rate_basis : ''}
        options={rateBasises}
        className="flex-100"
        onChange={this.handleSelect}
      />
    </div>) : (<div
      className={`flex-25 layout-row layout-align-none-center layout-wrap ${
        styles.price_cell
      }`}
    >
      <p className={`flex-90 ${styles.price_cell_data}`}>
        {chargeGlossary[fee.rate_basis]}
      </p>
      <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary.rate_basis}</p>
      <div className={`flex-none ${styles.price_cell_divider}`} />
    </div>)
    cells.push(rbCell)
    feeKeys.forEach((chargeKey, i) => {
      if (!dnrKeys.includes(chargeKey)) {
        const cell = edit ? (<div
          key={chargeKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${
            styles.price_cell
          }`}
        >
          <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[chargeKey]}</p>
          <div className="flex-95 layout-row input_box_full">
            <input
              type="number"
              value={fee[chargeKey]}
              onChange={this.handleChange}
              name={`${direction}-${fee.key}-${chargeKey}`}
            />
          </div>
          {i !== feeKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
        </div>) : (<div
          className={`flex-25 layout-row layout-align-none-center layout-wrap ${
            styles.price_cell
          }`}
        >
          <p className={`flex-90 ${styles.price_cell_data}`}>
            {fee[chargeKey]} {fee.currency}
          </p>
          <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[chargeKey]}</p>
          {i !== feeKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
        </div>)
        cells.push(cell)
      }
    })

    return cells
  }
  renderDateBoxes (fee, selectOptions, direction, edit) {
    const dateKeys = ['effective_date', 'expiration_date']
    const cells = []

    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days')
          .format())
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }
    dateKeys.forEach((dk, i) => {
      const dateCell = edit ? (<div
        className={`flex layout-row layout-align-none-center layout-wrap ${
          styles.price_cell
        } ${styles.dpb}`}
      >
        <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[dk]}</p>
        <DayPickerInput
          name="dayPicker"
          placeholder="DD/MM/YYYY"
          format="DD/MM/YYYY"
          value={fee[dk]}
          onDayChange={e => this.handleDayChange(e, direction, fee.key, dk)}
          dayPickerProps={dayPickerProps}
        />
        {i !== dateKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
      </div>) : (<div
        className={`flex layout-row layout-align-none-center layout-wrap ${
          styles.price_cell
        }`}
      >
        <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[dk]}</p>
        <p className={`flex-90 ${styles.price_cell_data}`}>{moment(fee[dk]).format('ll')}</p>
        {i !== dateKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
      </div>)
      cells.push(dateCell)
    })
    return cells
  }
  render () {
    const { edit } = this.state
    const {
      fee, toggleEdit, theme, handleDateEdit, handleFeeEdit, handleRateBasisEdit, selectOptions, direction
    } = this.props
    // debugger // eslint-disable-line

    const colorTheme =
      theme && theme.colors
        ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary)
        : 'black'

    return (
      <div
        className={`${styles.fee_row} flex-100 layout-row layout-align-center-center`}
      >
        <div className="flex-25 layout-row layout-align-start-center">
          <p className="flex-none offset-5">{ `${fee.key} - ${fee.name}`}</p>
        </div>
        <div className="flex-50 layout-row ">
          {this.renderFeeBoxes(fee, selectOptions, direction, edit)}
        </div>
        <div className="flex-25 layout-row ">
          <div className="flex-75 layout-row">
            {this.renderDateBoxes(fee, selectOptions, direction, edit)}
          </div>
          <div className="flex-25 layout-row layout-align-center-center" onClick={() => this.toggleEdit()}>
            <i className="fa fa-edit" />
          </div>
        </div>
      </div>
    )
  }
}

FeeRow.propTypes = {
  titles: PropTypes.string.isRequired,
  faIcon: PropTypes.string.isRequired,
  theme: PropTypes.theme.isRequired
}
FeeRow.defaultProps = {}
export default FeeRow
