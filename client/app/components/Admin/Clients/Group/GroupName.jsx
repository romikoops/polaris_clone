import React, { useState } from 'react'

function GroupName ({ name, onEdit }) {
  const [editing, setEditing] = useState(false)
  const [newName, setNewName] = useState(name)

  const toggleEditing = () => {
    setEditing(!editing)
  }
  const onNameChange = (e) => {
    setNewName(e.target.value)
  }
  const saveChanges = () => {
    onEdit(newName)
    toggleEditing()
  }
  const iconStyle = { padding: '5px' }

  const editingView = (
    <div className="flex-80 layout-row">
      <div className="flex-none input_box">
        <input type="text" value={newName} onChange={(e) => onNameChange(e)} />
      </div>
      <div className="flex-20 layout-row">
        <div
          className="flex-20 layout-row layout-align-center-center"
          style={iconStyle}
          onClick={() => saveChanges()}
        >
          <i className="flex-none fa fa-save green" />
        </div>
        <div
          className="flex-20 layout-row layout-align-center-center"
          style={iconStyle}
          onClick={() => toggleEditing()}
        >
          <i className="flex-none fa fa-close red" />
        </div>
      </div>
    </div>
  )

  const displayView = (
    <div className="flex-80 layout-row">
      <div className="flex-none input_box">
        <h1 className="flex-none">
          {' '}
          {name}
          {' '}
        </h1>
      </div>
      <div className="flex-20 layout-row">
        <div
          className="flex-20 layout-row layout-align-center-center"
          style={iconStyle}
          onClick={() => toggleEditing()}
        >
          <i className="flex-none fa fa-pencil" />
        </div>
      </div>
    </div>
  )

  return editing ? editingView : displayView
}

export default GroupName
