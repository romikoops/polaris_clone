import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'

export const TruckingDistanceSetter = ({
  newCell, theme, addNewCell, t
}) => (
  <div className="flex-100 layout-row layout-align-start-center">
    <Formsy
      onValidSubmit={addNewCell}
      className="flex-100 layout-row layout-align-start-center"
    >
      <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none sup_l">
            {t('admin:lowerLimitDistance')}
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center input_box">
          <FormsyInput
            type="number"
            name="lower_distance"
            value={newCell.lower_distance}
            placeholder={t('admin:lowerDistance')}
          />
        </div>
      </div>
      <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none sup_l">
            {t('admin:upperLimitDistance')}
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center input_box">
          <FormsyInput
            type="number"
            name="upper_distance"
            value={newCell.upper_distance}
            placeholder={t('admin:upperDistance')}
          />
        </div>
      </div>
      <div className="flex-33 layout-row layout-align-center-center" >
        <RoundButton
          theme={theme}
          size="small"
          text={t('admin:addAnother')}
          iconClass="fa-plus-square-o"
        />
      </div>
    </Formsy>
  </div>
)
TruckingDistanceSetter.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  newCell: PropTypes.objectOf(PropTypes.any).isRequired,
  addNewCell: PropTypes.func.isRequired
}
TruckingDistanceSetter.defaultProps = {
  theme: {}
}
export default withNamespaces('admin')(TruckingDistanceSetter)
