import React from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
// import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'

export const TruckingDistanceSetter = ({ newCell, theme, addNewCell }) => (
  <div className="flex-100 layout-row layout-align-start-center">
    <Formsy
      onValidSubmit={addNewCell}
      className="flex-100 layout-row layout-align-start-center"
    >
      <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none sup_l">Lower limit distance</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center input_box">
          <FormsyInput
            type="number"
            name="lower_distance"
            value={newCell.lower_distance}
            placeholder="Lower Distance"
          />
        </div>
      </div>
      <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none sup_l">Upper limit distance</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center input_box">
          <FormsyInput
            type="number"
            name="upper_distance"
            value={newCell.upper_distance}
            placeholder="Upper Distance"
          />
        </div>
      </div>
      <div className="flex-33 layout-row layout-align-center-center" >
        <RoundButton
          theme={theme}
          size="small"
          text="Add another"
          iconClass="fa-plus-square-o"
        />
      </div>
    </Formsy>
  </div>
)
TruckingDistanceSetter.propTypes = {
  theme: PropTypes.theme,
  newCell: PropTypes.objectOf(PropTypes.any).isRequired,
  addNewCell: PropTypes.func.isRequired
}
TruckingDistanceSetter.defaultProps = {
  theme: {}
}
export default TruckingDistanceSetter
