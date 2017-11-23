import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './BookingConfirmation.scss';

export class BookingConfirmation extends Component {
    constructor(props) {
      }
}
BookingConfirmation.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    setData: PropTypes.func
};