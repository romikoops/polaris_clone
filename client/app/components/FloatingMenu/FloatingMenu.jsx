import React, { Component } from 'react'
import styled, { keyframes } from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './FloatingMenu.scss'
import { gradientTextGenerator } from '../../helpers'

export class FloatingMenu extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expand: false
    }
    this.toggleMenu = this.toggleMenu.bind(this)
  }
  toggleMenu () {
    this.setState({ expand: !this.state.expand })
  }
  render () {
    const {
      Comp, theme, title, icon
    } = this.props

    const rotateIcon = keyframes` 
    /* 0%, 100% {
         font-size: 20px;

     }*/
     0% {
         *{
             font-size: 30px;
             background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.secondary + ',' + theme.colors.brightSecondary + ')' : 'black'
         }
     }
    /* 0% {
         transform: rotateZ(360deg);
         transform-origin: 50% 50%;
         transform-style: preserve-3D;

     }*/
    `
    const textStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : { color: 'black' }
    const Title = styled.div` letter-spacing: 3px;`
    const AnimIcon = styled.div` :hover {animation: ${rotateIcon} 1.5s linear;}
      ${Title}:hover & {animation: ${rotateIcon} 1.5s linear;}
    `
    const currentStyle = this.state.expand ? styles.open : styles.closed
    const wrapperStyle = this.state.expand ? styles.wrapper_max : styles.wrapper_min

    return (
      <div className={`flex-none layout-row layout-wrap layout-align-center-start ${styles.wrapper} ${wrapperStyle}`}>
        <Title
          className="flex-100 layout-row layout-align-start-center pointy"
          onClick={this.toggleMenu}
        >
          <AnimIcon className={`flex-none layout-row layout-align-center-center ${styles.icon_circle}`}>
            <i className={`fa ${icon} flex-none clip`} style={textStyle} />
          </AnimIcon>
          <div className="flex layout-row layout-align-start-center">
            <h4 className="flex-none no_m">{title}</h4>
          </div>
        </Title>
        <div className={`flex-100 layout-row ${styles.menu_content} ${currentStyle}`}>
          {Comp}
        </div>

      </div>
    )
  }
}

FloatingMenu.propTypes = {
  Comp: PropTypes.node,
  theme: PropTypes.theme,
  title: PropTypes.string,
  icon: PropTypes.string
}

FloatingMenu.defaultProps = {
  theme: null,
  Comp: null,
  title: '',
  icon: ''
}

export default FloatingMenu
