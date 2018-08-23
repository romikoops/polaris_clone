import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './FloatingMenu.scss'
import { gradientTextGenerator } from '../../helpers'

class FloatingMenu extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expand: window.innerWidth > 1024,
      overflowOverwrite: {},
      collapsePromptHrWidthOverwrite: {},
      collapsePromptOverwriteP: {}
    }
    this.toggleMenu = this.toggleMenu.bind(this)
    this.updateWindowDimensions = this.updateWindowDimensions.bind(this)
  }
  componentDidMount () {
    this.updateWindowDimensions()
    window.addEventListener('resize', this.updateWindowDimensions)
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.updateWindowDimensions)
  }

  updateWindowDimensions () {
    this.setState({
      expand: window.innerWidth > 1024
    })
  }
  toggleMenu () {
    this.setState({ expand: !this.state.expand })
    if (this.state.expand) {
      setTimeout(() => {
        if (!this.state.expand) {
          this.setState({
            overflowOverwrite: { overflow: 'visible' },
            collapsePromptHrWidthOverwrite: { width: '55px' },
            collapsePromptOverwriteP: { opacity: '0' }
          })
        }
      }, 800)
    } else {
      this.setState({
        overflowOverwrite: {},
        collapsePromptHrWidthOverwrite: {},
        collapsePromptOverwriteP: {}
      })
    }
  }
  render () {
    const {
      Comp, theme, user, t
    } = this.props
    const textStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : { color: 'black' }
    const currentStyle = this.state.expand ? styles.open : styles.closed

    return (
      <div>
        <div className={`${styles.pusher} ${this.state.expand ? '' : styles.collapsed}`} />
        <div
          className={
            `${styles.floating_menu} ` +
            `${this.state.expand ? '' : styles.collapsed} ` +
            'flex-none layout-column layout-align-space-between'
          }
          style={this.state.overflowOverwrite}
        >
          <div className={`flex-none layout-row ${styles.menu_content} ${currentStyle}`}>
            {<Comp theme={theme} user={user} expand={this.state.expand} />}
          </div>
          <div>
            <hr style={this.state.collapsePromptHrWidthOverwrite} />
            <div
              className={`${styles.collapse_prompt} pointy`}
              onClick={this.toggleMenu}
            >
              <div className="flex-none layout-row layout-align-start-center">
                <i className="fa fa-angle-double-left clip" style={textStyle} />
                <p style={this.state.collapsePromptOverwriteP}>
                  {t('common:collapseSidebar')}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

FloatingMenu.propTypes = {
  Comp: PropTypes.node,
  theme: PropTypes.theme,
  user: PropTypes.user
}

FloatingMenu.defaultProps = {
  theme: null,
  Comp: null,
  user: null
}

export default translate('common')(FloatingMenu)
