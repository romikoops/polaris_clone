import React, {Component} from 'react';
import PropTypes from 'prop-types';
// import { Link } from 'react'
import './Button.scss';
// import SignIn from '../SignIn/SignIn';
// export function Button(props) {
//     return <button className="btn_style"> {props.text} </button>;
// };
class Button extends Component {
    constructor(props) {
        super(props);

        // Toggle the state every second
    }
    render() {
        let display = this.props.text;
        return (
          <button className="btn_style"> {display} </button>
        );
    }
}

Button.propTypes = {
    text: PropTypes.string
};

export default Button;
