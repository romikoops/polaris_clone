import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styled from 'styled-components'
import styles from './DetailMenu.scss'

class DetailMenu extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expand: true
    }
    this.toggleMenu = this.toggleMenu.bind(this)
  }
  toggleMenu () {
    this.setState({ expand: !this.state.expand })
  }

  render () {
    const {
      Comp, t
    } = this.props
    const Title = styled.div`
            letter-spacing: 3px;
        `
    const currentStyle = this.state.expand ? styles.open : styles.closed

    return (
      <div className={`flex-none layout-row layout-wrap layout-align-center-start ${styles.wrapper}`}>
        <Title
          className="flex-100 layout-row layout-align-start-center pointy"
          onClick={this.toggleMenu}
        >
          <div className="flex layout-row layout-align-start-center">
            <h4 className="flex-none no_m">{t('common:menu').toUpperCase()}</h4>
          </div>
        </Title>
        <div className={`flex-100 layout-row ${styles.menu_content} ${currentStyle}`}>
          {Comp}
        </div>

      </div>
    )
  }
}

DetailMenu.propTypes = {
  Comp: PropTypes.node.isRequired,
  t: PropTypes.func.isRequired
}

export default withNamespaces('common')(DetailMenu)
