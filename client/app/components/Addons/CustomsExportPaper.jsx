import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import styles from '../CargoDetails/CargoDetails.scss'
import TextHeading from '../TextHeading/TextHeading'
import Checkbox from '../Checkbox/Checkbox'
import DocumentsMultiForm from '../Documents/MultiForm'

class CustomsExportPaper extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      addonView: get(props, ['isSet'], false)
    }
  }

  toggleAddon (bool) {
    this.setState({ addonView: bool }, () => this.props.toggleCustomAddon('customs_export_paper'))
  }

  render () {
    const {
      tenant, t, documents, fileFn, deleteDoc
    } = this.props

    const { theme } = tenant

    return (
      <div className="flex-100 layout-row layout-align-center padd_top">
        <div
          className="flex-none content_width layout-row layout-wrap section_padding"
        >
          <div className={`flex-100 layout-row layout-align-space-between-start layout-wrap ${styles.export_customs_title}`}>
            <div className="flex-none layout-row layout-align-space-around-center">
              <TextHeading theme={theme} size={2} text={t('shipment:adb')} />
            </div>
            <p className="flex-100">
              <strong>
                {' '}
                {t('shipment:customsExportPaper')}
              </strong>
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-start layout-wrap">
            <div className={`flex-100 layout-row layout-align-end-center ${styles.checkbox_row}`}>
              <div className="flex-10 layout-row layout-align-start-center">
                <Checkbox
                  id="addon_toggle_true"
                  onChange={() => this.toggleAddon(true)}
                  checked={this.state.addonView}
                  theme={theme}
                />
              </div>
              <div className="flex-90 layout-row layout-align-start-center">
                <label htmlFor="addon_toggle_true">
                  <p className="flex-none" style={{ marginRight: '5px' }}>
                    {t('shipment:exportCustomsPaperAccept', { tenant: tenant.name })}
                  </p>
                </label>
              </div>

            </div>
            <div className={`flex-100 layout-row layout-align-end-center ${styles.checkbox_row}`}>
              <div className="flex-10 layout-row layout-align-start-center">
                <Checkbox
                  id="addon_toggle_false"
                  onChange={() => this.toggleAddon(false)}
                  checked={
                    this.state.addonView === null ? null : !this.state.addonView
                  }
                  theme={theme}
                />
              </div>
              <div className="flex-90 layout-row layout-align-start-center">
                <label htmlFor="addon_toggle_false">
                  <p className="flex-none" style={{ marginRight: '5px' }}>
                    {t('shipment:exportCustomsPaperDecline', { tenant: tenant.name })}
                  </p>
                </label>
              </div>

            </div>
            <div className={`flex-100 layout-row layout-wrap ${styles.export_upload}`} name="export_customs_paper">
              <div className="flex-100 flex-gt-sm-50 layout-row">
                <DocumentsMultiForm
                  theme={theme}
                  type="export_customs_paper"
                  text={t('shipment:adb')}
                  dispatchFn={fileFn}
                  documents={documents.export_customs_paper}
                  deleteFn={deleteDoc}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default withNamespaces(['cargo', 'shipment'])(CustomsExportPaper)
