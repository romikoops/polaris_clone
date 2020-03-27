import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import styles from './Loading.scss'
import { gradientTextGenerator } from '../../helpers'
import { appActions } from '../../actions'

class Loading extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showClose: false
    }
    this.timer = setTimeout(() => {
      this.showClose()
    }, 2000)
  }

  componentWillUnmount () {
    clearTimeout(this.timer)
  }

  showClose () {
    this.setState({ showClose: true })
  }

  closeLoading () {
    const { appDispatch } = this.props
    appDispatch.clearLoading()
  }

  render () {
    const { tenant } = this.props
    const { showClose } = this.state

    if (!tenant || !tenant.theme) {
      return null
    }

    const { theme } = tenant

    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }

    if (tenant && tenant.scope && tenant.scope.loading_image) {
      return (
        <div className={`layout-row layout-align-center-center ccb_loading ${styles.loader_box}`}>
          <img src={tenant.scope.loading_image} className="loading-image" />
        </div>
      )
    }

    return (
      <div className={`layout-row layout-align-center-center ccb_loading ${styles.loader_box}`}>
        { showClose ? (
          <div
            className={`flex-none ${styles.close}`}
            onClick={() => this.closeLoading()}
          >
            <i className="fa fa-times" />
          </div>
        ) : '' }
        <div className={`${styles.cube} ${styles.preload}`}>
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

Loading.defaultProps = {
  tenant: null
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
