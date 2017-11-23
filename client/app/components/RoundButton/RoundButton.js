import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './RoundButton.scss';

export class RoundButton extends Component {

    render() {
        const { text, theme } =  this.props;
        const activeBtnStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(95.41deg, ' + theme.colors.primary + ' 0%,' + theme.colors.secondary + ' 100%)' : 'black',
            color: 'floralwhite'
        };
        const btnStyle = this.props.active ? activeBtnStyle : {};
        return (
          <button className={`${styles.round_btn} flex-100`}   onClick={this.props.handleNext} style={btnStyle} > {text} </button>
        );
    }
}

RoundButton.propTypes = {
    text: PropTypes.string,
    handleNext: PropTypes.func,
    active: PropTypes.bool,
    theme: PropTypes.object
};

