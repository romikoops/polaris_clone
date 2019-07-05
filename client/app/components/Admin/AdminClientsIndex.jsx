import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import FileUploader from '../FileUploader/FileUploader'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import AdminClientGroups from './Clients/Groups'
import AdminClientList from './Clients/List'
import AdminClientCompanies from './Clients/Companies'

class AdminClientsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchFilters: {},
      searchResults: [],
      numPerPage: 9,
      page: 1
    }
  }

  componentDidMount () {
    window.scrollTo(0, 0)
  }

  toggleExpander (target) {
    this.setState(prevState => ({ expander: { ...prevState.expander, [target]: !prevState.expander[target] } }))
  }

  render () {
    const {
      t, theme, adminDispatch, tabReset, scope, user
    } = this.props
    const { expander } = this.state
    const legacyTab = (
      <Tab
        tabTitle={t('admin:clients')}
        theme={theme}
      >
        <div className="flex-100 layout-row layout-align-start-start layout-wrap margin_top tab_size padd_10">
          <AdminClientList />
        </div>
      </Tab>
    )
    const marginTabs = [legacyTab, (<Tab
      tabTitle={t('admin:companies')}
      theme={theme}
    >
      <div className="flex-100 layout-row layout-align-start-start layout-wrap margin_top tab_size padd_10">
        <AdminClientCompanies />
      </div>
    </Tab>),
    (<Tab
      tabTitle={t('admin:groups')}
      theme={theme}
    >
      <div className="flex-100 layout-row layout-align-start-start layout-wrap margin_top tab_size padd_10">
        <AdminClientGroups />
      </div>
    </Tab>)]

    return (
      <div
        className="flex-100 layout-row layout-wrap layout-align-space-between-start
        extra_padding_left"
      >
        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.header_with_text}`}>
          <h2 className="flex-none">{t('admin:clientsCenter')}</h2>
          <p className="flex-40">{t('admin:clientsCenterText')}</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-start ">
          <div className={`${styles.component_view} flex layout-row layout-align-start-start`}>
            <Tabs
              wrapperTabs="layout-row flex-50 flex-sm-40 flex-xs-80"
              paddingFixes
              tabReset={tabReset}
            >

              { scope.base_pricing ? marginTabs : [legacyTab] }

            </Tabs>
          </div>
          <div className="flex-20 layout-wrap layout-row layout-align-end-end">
            <SideOptionsBox
              header={t('admin:dataManager')}
              flexOptions="flex-100"
              content={[
                ((user.internal || scope.feature_uploaders) ? (
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.upload}
                    theme={theme}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    handleCollapser={() => this.toggleExpander('upload')}
                    text={t('admin:uploadData')}
                    faClass="fa fa-cloud-upload"
                    content={(
                      <div
                        className="flex-100 layout-row layout-wrap layout-align-center-center"
                      >
                        <p className="flex-100 center">{t('admin:uploadCompanies')}</p>
                        <FileUploader
                          theme={theme}
                          dispatchFn={file => adminDispatch.uploadAgents(file)}
                          type="xlsx"
                          size="full"
                          text={t('admin:companiesEmployees')}
                        />
                      </div>
                    )}
                  />
                ) : ''),
                (<div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.new}
                    theme={theme}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    handleCollapser={() => this.toggleExpander('new')}
                    text={t('admin:createNew')}
                    faClass="fa fa-plus-circle"
                    content={(
                      <div
                        className={`${
                          styles.action_section
                        } flex-100 layout-row layout-align-center-center layout-wrap`}
                      >
                        <div className="flex-none layout-row five_m">
                          <RoundButton
                            theme={theme}
                            size="small"
                            text={t('admin:newClient')}
                            active
                            handleNext={this.props.toggleNewClient}
                            iconClass="fa-plus"
                          />
                        </div>
                        <div className="flex-none layout-row five_m">
                          <RoundButton
                            theme={theme}
                            size="small"
                            text={t('admin:newGroup')}
                            active
                            handleNext={() => adminDispatch.goTo('/admin/clients/groupcreator')}
                            iconClass="fa-plus"
                          />
                        </div>
                        <div className="flex-none layout-row five_m">
                          <RoundButton
                            theme={theme}
                            size="small"
                            text={t('admin:newMargin')}
                            active
                            handleNext={() => adminDispatch.goTo('/admin/clients/margincreator')}
                            iconClass="fa-plus"
                          />
                        </div>
                        <div className="flex-none layout-row five_m">
                          <RoundButton
                            theme={theme}
                            size="small"
                            text={t('admin:newCompany')}
                            active
                            handleNext={() => adminDispatch.goTo('/admin/clients/companycreator')}
                            iconClass="fa-plus"
                          />
                        </div>
                      </div>
                    )}
                  />
                </div>)
              ]}
            />
          </div>
        </div>
      </div>
    )
  }
}

AdminClientsIndex.defaultProps = {
  theme: null,
  clients: []
}

export default withNamespaces(['admin', 'user', 'common'])(AdminClientsIndex)
