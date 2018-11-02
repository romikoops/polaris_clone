import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './HsCodeViewer.scss'
import PropTypes from '../../prop-types'

class HsCodeViewer extends Component {
  constructor (props) {
    super(props)
    this.state = {
      viewer: {}
    }
    this.toggleHsDetail = this.toggleHsDetail.bind(this)
  }
  toggleHsDetail (id) {
    this.setState({
      viewer: {
        ...this.state.viewer,
        [id]: !this.state.viewer[id]
      }
    })
  }
  render () {
    const {
      item,
      hsCodes,
      theme,
      t
    } = this.props
    const { viewer } = this.state
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const hsCodesArr = item.hs_codes.map((hs) => {
      const viewClass = viewer[hs] ? styles.open : styles.closed
      const iconBtn = viewer[hs] ? (
        <i className="fa fa-chevron-up clip" style={textStyle} />
      ) : (
        <i className="fa fa-chevron-down clip" style={textStyle} />
      )

      return (
        <div key={hs} className={`flex-100 layout-row layout-wrap ${styles.hs_cell}`}>
          <div
            className="flex-100 layout-row layout-align-space-between-center"
            onClick={() => this.toggleHsDetail(hs)}
          >
            <p className="flex-none"> {hs}</p>
            <div className="flex-10 layout-row layout-align-center-center">{iconBtn}</div>
          </div>
          <div className={`flex-100 layout-row ${styles.cell_data_toggle} ${viewClass}`}>
            <p className="flex-100">{hsCodes[hs].text}</p>
          </div>
        </div>
      )
    })

    return (
      <div
        className={`${styles.backdrop} layout-row flex-none layout-wrap layout-align-center-center`}
      >
        <div
          className={`${styles.content} layout-row flex-none layout-wrap layout-align-center-start`}
        >
          <div className="flex-100 layout-row layout-align-space-between-center">
            <h2 className="flex-none clip" style={textStyle}>
              {t('common:hsCodes')}
            </h2>
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={this.props.close}
            >
              <i className="fa fa-times clip" style={textStyle} />
            </div>
          </div>
          <hr />
          <div className="flex-100 layout-row layout-wrap">{hsCodesArr}</div>
        </div>
      </div>
    )
  }
}
HsCodeViewer.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  close: PropTypes.func.isRequired,
  item: PropTypes.shape({
    hs_codes: PropTypes.array
  }).isRequired,
  hsCodes: PropTypes.arrayOf(PropTypes.string)
}

HsCodeViewer.defaultProps = {
  hsCodes: [],
  theme: null
}

export default withNamespaces('common')(HsCodeViewer)
