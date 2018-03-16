export default function getShipmentData (response, stage) {
  return (response && stage && response[`stage${stage - 1}`]) || {}
}
