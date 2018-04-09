import React from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
// import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'
import FormsyInput from '../../FormsyInput/FormsyInput'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import { PlaceSearch } from '../../Maps/PlaceSearch'
import { RoundButton } from '../../RoundButton/RoundButton'

export const TruckingCitySetter = ({
  newCell, theme, addNewCell, handlePlaceChange, tmpCity
}) => (
  <div className="flex-100 layout-row layout-align-start-center">
    <Formsy onValidSubmit={addNewCell} className="flex-100 layout-row layout-align-start-center">
      <div className="flex-66 layout-row layout-wrap">
        <h3 className="flex-40">Find Cities</h3>
        {tmpCity.city ? (
          <div className="flex-55 layout-row layout-align-start-center input_box">
            <FormsyInput
              type="text"
              name="city"
              value={tmpCity.city}
              placeholder="City"
            />
            <FormsyInput
              type="text"
              name="country"
              value={tmpCity.country}
              placeholder="country"
            />
          </div>
        ) : (
          <div className="offset-5 flex-55">
            <GmapsWrapper
              theme={theme}
              component={PlaceSearch}
              inputStyles={{
                width: '96%',
                marginTop: '9px',
                background: 'white'
              }}
              options={{ types: ['(cities)'] }}
              handlePlaceChange={handlePlaceChange}
              hideMap
            />
          </div>
        )}
      </div>
      <div className="flex-33 layout-row layout-align-center-center">
        <RoundButton theme={theme} size="small" text="Add another" iconClass="fa-plus-square-o" />
      </div>
    </Formsy>
  </div>
)
TruckingCitySetter.propTypes = {
  theme: PropTypes.theme,
  newCell: PropTypes.objectOf(PropTypes.any).isRequired,
  tmpCity: PropTypes.objectOf(PropTypes.any),
  addNewCell: PropTypes.func.isRequired,
  handlePlaceChange: PropTypes.func.isRequired
}
TruckingCitySetter.defaultProps = {
  theme: {},
  tmpCity: {}
}
export default TruckingCitySetter
