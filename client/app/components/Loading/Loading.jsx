import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { v4 } from 'uuid'
import styled, { keyframes } from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './Loading.scss'
import { gradientTextGenerator } from '../../helpers'
import { appActions } from '../../actions'

class Loading extends Component {
  constructor (props) {
    super(props)
    this.timer = setTimeout(() => {
      this.props.appDispatch.clearLoading()
    }, 20000)
  }

  componentWillUnmount () {
    clearTimeout(this.timer)
  }
  render () {
    const { theme } = this.props
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
    const kfDot = keyframes`
                0%, 100% {
                  height: 10px;
                  width: 10px;
                  background: ${theme && theme.colors ? theme.colors.primary : 'black'};
                }
                50% {
                  height: 20px;
                  width: 20px;
                  background: ${theme && theme.colors ? theme.colors.secondary : 'black'};
                }
        `
    const AnimDot = styled.div`
            animation: ${kfDot} 2s linear infinite;
            animation-delay: ${props => (props.delay ? `${props.delay}s` : 0)};
            background-color: theme && theme.colors ? theme.colors.primary : 'darkslategrey';
            border-radius: 50%;
            height: 15px;
            width: 15px;
            -webkit-box-flex: 0;
            -webkit-flex: 0 0 auto;
            flex: 0 0 auto;
            box-sizing: border-box;
        `
    const dots = []
    for (let i = 3; i >= 0; i--) {
      dots.push(<AnimDot key={v4()} delay={i} />)
    }

    return (
      <div className={`layout-row layout-align-center-center ccb_loading ${styles.loader_box}`}>
        <div className={`${styles.cube} ${styles.preload}`}>
          {/* <div
          className={`layout-row layout-align-center-center ${styles.loader_box}`}
        >
          <div
            className={`layout-column layout-align-center-center ${
              styles.loader
              }`}
          >
            <FlipLogo />
            <div className={`flex-none layout-row layout-align-space-between-center ${styles.dot_row}`}>
              {dots}
            </div>

          </div>
        </div> */}
          <div className={`${styles.cube_face} ${styles.cube_face_front}`}>
            <i className="fa fa-plane clip" style={textStyle} />
          </div>
          <div className={`${styles.cube_face} ${styles.cube_face_back}`}>
            <i className="fa fa-anchor clip" style={textStyle} />
          </div>
          <div className={`${styles.cube_face} ${styles.cube_face_left}`}>
            <i className="fa fa-truck clip" style={textStyle} />
          </div>
          <div className={`${styles.cube_face} ${styles.cube_face_right}`}>
            <i className="fa fa-truck clip" style={textStyle} />
          </div>
          <div className={`${styles.cube_face} ${styles.cube_face_bottom}`}>
            <i className="fa fa-anchor clip" style={textStyle} />

          </div>
          <div className={`${styles.cube_face} ${styles.cube_face_top}`}>
            <i className="fa fa-plane clip" style={textStyle} />
          </div>
        </div>
      </div>
    )
  }
}
Loading.propTypes = {
  theme: PropTypes.theme,
  appDispatch: PropTypes.shape({
    clearLoading: PropTypes.func
  }).isRequired
}

Loading.defaultProps = {
  theme: null
}

function mapStateToProps () {
  return {}
}

function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Loading))
