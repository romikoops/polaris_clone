import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './Price.scss';
export class Price extends Component {
  constructor(props) {
	  super(props);
  }
  format2Digit(n) {
    return ('0' + n).slice(-2);
  }
  render() {
    const { value, scale } = this.props;
    const scaleTransformation = scale ? {transform: `scale(${scale})`} : {};
    const priceUnits = Math.floor(value);
    const priceCents = this.format2Digit(Math.floor((value * 100) % 100));
    return (
      <p className={`flex-none ${styles.price}`} style={scaleTransformation}>
        {priceUnits}<sup>.{priceCents}</sup>  <span className={styles.price_currency}>EUR</span>
      </p>
    );
  }
}
Price.PropTypes = {
	value: PropTypes.string,
  scale: PropTypes.string
};
