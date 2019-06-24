import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../Admin.scss'
import DocumentsSelector from '../../Documents/Selector'
import DocumentsDownloader from '../../Documents/Downloader'

function GroupFileHandlers ({
  handleUpload, hub, t, theme, groupOptions
}) {
  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <div
        className={`${
          styles.action_section
        } flex-100 flex-gt-sm-33 layout-row layout-align-center-center layout-wrap`}
      >
        <p className="flex-90 flex-gt-sm-50  center">{t('admin:uploadTruckingZonesSheet')}</p>
        <DocumentsSelector
          theme={theme}
          options={groupOptions}
          placeholder="Group"
          dispatchFn={(file, dir) => handleUpload(file, dir)}
          type="xlsx"
          text={t('admin:routesExcel')}
        />
      </div>
      <div
        className={`${
          styles.action_section
        } flex-100 flex-gt-sm-33 layout-row layout-wrap layout-align-center-center`}
      >
        <p className="flex-100 flex-gt-sm-50 center">{t('admin:downloadCargoItemSheet')}</p>
        <DocumentsDownloader
          theme={theme}
          target="trucking"
          targetOptions={groupOptions}
          options={{ hub_id: hub.id, load_type: 'cargo_item' }}
        />
      </div>
      <div
        className={`${
          styles.action_section
        } flex-100 flex-gt-sm-33 layout-row layout-wrap layout-align-center-center`}
      >
        <p className="flex-100 flex-gt-sm-50 center">{t('admin:downloadContainerSheet')}</p>
        <DocumentsDownloader
          theme={theme}
          target="trucking"
          targetOptions={groupOptions}
          options={{ hub_id: hub.id, load_type: 'container' }}
        />
      </div>
    </div>
  )
}

GroupFileHandlers.defaultProps = {
  heading: '',
  text: ''
}

export default withNamespaces('admin')(GroupFileHandlers)
