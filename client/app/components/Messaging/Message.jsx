import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styled from 'styled-components'
import styles from './Messaging.scss'
import { moment } from '../../constants'
import PropTypes from '../../prop-types'

class Message extends Component {
  constructor (props) {
    super(props)
    this.checkAdmin = this.checkAdmin.bind(this)
  }
  checkAdmin (User, Admin) {
    const { message, user, client } = this.props
    if (client && message.sender_id === client.id) {
      return User
    }
    if (client && message.sender_id !== client.id) {
      return Admin
    }
    if (!client && message.sender_id === user.id) {
      return User
    }
    if (!client && message.sender_id !== user.id) {
      return Admin
    }

    return ''
  }

  render () {
    const {
      message, theme, tenant, user, client, t
    } = this.props
    const isAdmin = user.role && user.role.name === 'admin'
    const messageStyle =
      message.sender_id === message.user_id ? styles.user_style : styles.tenant_style
    const UserMessage = styled.div`
      background: #fff;
      border: 2px solid ${theme.colors.secondary};
      :after {
        content: '';
        position: absolute;
        right: 0;
        top: 75%;
        width: 0;
        height: 0;
        border: 20px solid transparent;
        border-left-color: ${theme.colors.secondary};
        border-right: 0;
        border-bottom: 0;
        margin-top: -10px;
        margin-right: -20px;
      }
    `
    const AdminMessage = styled.div`
      background-color: #fff;
      border: 2px solid ${theme.colors.brightPrimary};
      :after {
        content: '';
        position: absolute;
        left: 0;
        top: 75%;
        width: 0;
        height: 0;
        border: 20px solid transparent;
        border-right-color: ${theme.colors.brightPrimary};
        border-left: 0;
        border-bottom: 0;
        margin-top: -10px;
        margin-left: -20px;
      }
    `

    const adminMeta =
      client && message.sender_id !== user.id ? (
        <p className={`flex-none ${styles.timestamp}`}>
          {client.first_name} {client.last_name} @ {moment(message.updated_at).format('lll')}
        </p>
      ) : (
        <p className={`flex-none ${styles.timestamp}`}>
          {t('common:you')} @ {moment(message.updated_at).format('lll')}
        </p>
      )
    const userMeta =
      message.sender_id === user.id ? (
        <p className={`flex-none ${styles.timestamp}`}>
          {t('common:you')} @ {moment(message.updated_at).format('lll')}
        </p>
      ) : (
        <p className={`flex-none ${styles.timestamp}`}>
          {tenant.data.name} {t('account:admin')} @ {moment(message.updated_at).format('lll')}
        </p>
      )
    const meta = isAdmin ? adminMeta : userMeta
    const Comp = this.checkAdmin(UserMessage, AdminMessage)

    return (
      <div className={`flex-100 layout-row ${styles.message_wrapper}`}>
        {message.sender_id === message.user_id ? (
          <div className="flex-25" />
        ) : (
          <div className="flex-5" />
        )}
        <Comp
          className={`flex-none layout-row layout-align-start-center layout-wrap ${messageStyle} ${
            styles.message_inner
          }`}
        >
          <div className="flex-100 layout-row layout-align-space-between-center">
            <h3 className={`flex-none ${styles.message_title}`}>{message.title}</h3>
            {meta}
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <p className={`flex-none ${styles.message_text}`}>{message.message}</p>
          </div>
        </Comp>
      </div>
    )
  }
}

Message.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  user: PropTypes.user.isRequired,
  tenant: PropTypes.tenant.isRequired,
  client: PropTypes.client,
  message: PropTypes.shape({
    sender_id: PropTypes.number,
    user_id: PropTypes.number,
    title: PropTypes.string,
    message: PropTypes.string
  }).isRequired
}

Message.defaultProps = {
  theme: null,
  client: null
}

export default withNamespaces(['common', 'account'])(Message)
