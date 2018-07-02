import React, { Component } from 'react'
import { v4 } from 'uuid'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import styles from './AdminClientTile.scss'
import adminStyles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { gradientTextGenerator, gradientBorderGenerator } from '../../helpers'
import GradientBorder from '../GradientBorder'
import defaults from '../../styles/default_classes.scss'

export class AdminClientTile extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showDelete: false
    }
    this.handleLink = this.handleLink.bind(this)
    this.clickEv = this.clickEv.bind(this)
    this.toggleShowDelete = this.toggleShowDelete.bind(this)
    this.deleteThis = this.deleteThis.bind(this)
  }
  handleLink () {
    const { target, navFn } = this.props
    navFn(target)
  }
  toggleShowDelete () {
    this.setState({ showDelete: !this.state.showDelete })
  }
  deleteThis () {
    const { client, deleteFn } = this.props
    deleteFn(client)
  }
  clickEv () {
    const { handleClick, client } = this.props
    if (handleClick) {
      handleClick(client)
    }
  }
  render () {
    const {
      theme,
      client,
      deleteable,
      showTooltip,
      tooltip
    } = this.props
    const { showDelete } = this.state
    if (!client) {
      return ''
    }
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const content = (
      <div
        className={`${styles.margin} flex-80 layout-row layout-wrap layout-align-center-center`}
        onClick={this.clickEv}
      >
        <div
          className={`flex-100 layout-row layout-align-space-around-center-center ${
            styles.client_subheader
          }`}
        >
          <i className="flex-none fa fa-user clip" style={gradientStyle} />
          <h4 className="flex-90 flex-offset-10 no_m">
            {' '}
            {client.first_name} {client.last_name}{' '}
          </h4>
        </div>
        <div
          className={`flex-100 layout-row layout-align-space-around-center-center ${
            styles.client_subheader
          } ${defaults.border_divider}`}
        >
          <i className="flex-none fa fa-envelope clip" style={gradientStyle} />
          <p className="flex-90">Email</p>
        </div>
        <div className={`flex-100 layout-row layout-align-start-center ${styles.client_text}`}>
          <p className="flex-90 flex-offset-10">{client.email}</p>
        </div>
        <div
          className={`flex-100 layout-row layout-align-space-around-center-center ${
            styles.client_subheader
          }`}
        >
          <i className="flex-none fa fa-building clip" style={gradientStyle} />
          <p className="flex-90">Company</p>
        </div>
        <div
          className={`flex-100 layout-row layout-align-start-center-center ${styles.client_text}`}
        >
          <p className="flex-90 flex-offset-10">{client.company_name}</p>
        </div>
      </div>
    )
    const deleter = (
      <div className="flex-95 layout-row layout-wrap layout-align-start-start height_100">
        <div className="flex-100 layout-row layout-align-start-center">
          <h3 className="flex-none sec_header_text"> Delete Alias?</h3>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none sec_subheader_text"> Are you sure</p>
        </div>
        <div
          className="flex-100 layout-column layout-align-center-space-between"
          style={{ height: '65%' }}
        >
          <div className="flex-50 width_100 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              text="No"
              handleNext={this.toggleShowDelete}
              iconClass="fa-ban"
            />
          </div>
          <div className="flex-50 width_100 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              active
              text="Yes"
              handleNext={this.deleteThis}
              iconClass="fa-trash"
            />
          </div>
        </div>
      </div>
    )
    const gradientBorderStyle =
      theme && theme.colors
        ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }
    const switchView = showDelete ? deleter : content
    const contentView = deleteable ? switchView : content
    const tooltipId = v4()

    return (
      <GradientBorder
        wrapperClassName={`flex-none ${styles.client_card} ${adminStyles.margin_bottom} layout-row flex-30 flex-md-45 pointy`}
        gradient={gradientBorderStyle}
        className="layout-column flex-100"
        content={(
          <div className="layout-column flex-100">
            {deleteable && !showDelete ? (
              <div
                className={`flex-none layout-row layout-align-center-center ${styles.delete_x}`}
                onClick={this.toggleShowDelete}
              >
                <i className="fa fa-trash" />
              </div>
            ) : (
              ''
            )}
            <div className={`${styles.content} flex-100 layout-row layout-align-center-start`} data-for={tooltipId} data-tip={tooltip}>
              {contentView}
              {
                showTooltip
                  ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
                  : ''
              }
            </div>
            {/* <div className={`${userStyles.footer}`}>
              <div className="layout-row layout-align-center-center">
                <span
                  className="emulate_link"
                  onClick={this.toggleShowDelete}
                >
                  <i className="fa fa-trash" />
                </span>
              </div>
            </div> */}
          </div>
        )}
      />
    )
  }
}
AdminClientTile.propTypes = {
  theme: PropTypes.theme,
  client: PropTypes.client.isRequired,
  navFn: PropTypes.func,
  deleteFn: PropTypes.func,
  handleClick: PropTypes.func,
  target: PropTypes.string,
  deleteable: PropTypes.bool,
  tooltip: PropTypes.string,
  showTooltip: PropTypes.bool
}
AdminClientTile.defaultProps = {
  theme: null,
  deleteable: false,
  handleClick: null,
  tooltip: '',
  showTooltip: false,
  navFn: null,
  deleteFn: null,
  target: ''
}

export default AdminClientTile
