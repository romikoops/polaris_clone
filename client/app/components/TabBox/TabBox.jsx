import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './TabBox.scss'

export class TabBox extends Component {
  constructor (props) {
    super(props)
    this.changeTab = this.changeTab.bind(this)
    this.state = {
      tab: 0,
      tabs: props.tabs,
      components: props.components
    }
  }

  changeTab (tab) {
    this.setState({
      tab
    })
  }

  showTab () {
    return this.state.components[this.state.tab]
  }

  render () {
    return (
      <div className={`layout-column flex-100 layout-wrap layout-align-start-stretch ${styles.widecomp}`}>
        <div className={`${styles.tabdiv}`}>
          {this.state.tabs.map((t, i) => <div onClick={() => this.changeTab(i)} className={`${this.state.tab === i ? styles.selected : ''} ${styles.tab}`}>{t}</div>)}
        </div>
        <div className={`layout-row flex-90 layout-wrap layout-align-start-stretch ${styles.greyboxborder} ${styles.tabcontent}`}>
          {this.showTab()}
        </div>
      </div>
    )
  }
}

TabBox.propTypes = {
  tabs: PropTypes.arrayOf(PropTypes.string),
  components: PropTypes.arrayOf(PropTypes.element)
}

TabBox.defaultProps = {
  tabs: [''],
  components: [React.createElement('div')]
}

export default TabBox
