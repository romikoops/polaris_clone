import React, { PureComponent } from 'react'
import styles from './index.scss'
import { switchIcon, gradientTextGenerator } from '../../../helpers';
import { ChargeIcons } from './ChargeIcons';
class QuoteCard extends PureComponent {
  constructor(props) {
    super(props);
    this.state = {  }
  }
  render() {
    const {
      result,
      theme
    } = this.props
    const { itinerary, quote } = result
    const gradientStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    return ( 
      <div className={`flex-100 layout-row layout-wrap ${styles.container}`}>
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-10 layout-row layout-align-center-center">
            {switchIcon(itinerary.mode_of_transport, gradientStyle)}
          </div>
          <div className="flex-45 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <p className="flex-none">From: <b>{itinerary.stops[0].hub.name}</b></p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <p className="flex-none">To: <b>{itinerary.stops[1].hub.name}</b></p>
            </div>
          </div>
          <div className="flex layout-row layout-wrap layout-align-end-center">
            <ChargeIcons
              tenant={tenant}
              onCarriage={quote.trucking_on}
              preCarriage={quote.trucking_pre}
              originFees={quote.export}
              destinationFees={quote.import}
              />
          </div>
        </div>
      </div>
     );
  }
}
 
export default QuoteCard;