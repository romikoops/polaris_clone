import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './BookingConfirmation.scss';

export class BookingConfirmation extends Component {
    constructor(props) {
      }
      render() {
        return (
            <div className="flex-100 layout-row layout-wrap">
              
            </div>
          )
      }
}
BookingConfirmation.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    setData: PropTypes.func
};