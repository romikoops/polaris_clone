const SENDER_LOADED = 'i.fa-pencil'
const RECEIVER_LOADED = { selector: SENDER_LOADED, count: 2 }
const CHOOSE_SENDER = { selector: 'h3', index: 5 }
const CHOOSE_RECEIVER = { selector: 'h3', index: 6 }

const SELECT_RECEIVER_SENDER = {
  selector: 'div[style="padding: 15px;"] > div',
  index: 1
}

export default async function chooseSenderReceiver (puppeteer) {
  const {
    click,
    saveStep,
    waitFor,
    waitAndClick
  } = puppeteer
  await saveStep('chooseSenderReceiver.0')

  /**
   * Click on 'Choose a sender' and select first sender
   */
  expect(await click(CHOOSE_SENDER)).toBeTruthy()
  expect(await waitAndClick(SELECT_RECEIVER_SENDER)).toBeTruthy()
  expect(await waitFor(SENDER_LOADED)).toBeTruthy()

  /**
   * Click on 'Choose a receiver' and select first receiver
   */
  expect(await click(CHOOSE_RECEIVER)).toBeTruthy()
  expect(await waitAndClick(SELECT_RECEIVER_SENDER)).toBeTruthy()
  expect(await waitFor(RECEIVER_LOADED)).toBeTruthy()
  await saveStep('chooseSenderReceiver.1')
}
