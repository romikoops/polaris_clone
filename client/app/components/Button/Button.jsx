import React from 'react'
import PropTypes from 'prop-types'
// import { Link } from 'react'
import './Button.scss'
// import SignIn from '../SignIn/SignIn';
// export function Button(props) {
//     return <button className="btn_style"> {props.text} </button>;
// };
function Button ({ text }) {
  return <button className="btn_style"> {text} </button>
}

Button.propTypes = {
  text: PropTypes.string.isRequired
}

export default Button
