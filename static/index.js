/* globals QRCode */

// pull in desired CSS/SASS files
require('./css/index.scss')
require('script!qrcodejs')

// inject bundled Elm app into div#main

const Elm = require('../src/Main')
const app = Elm.Main.embed(document.getElementById('main'))
app.ports.portQr.subscribe(displayQR)

function displayQR (rec) {
  console.log('DEBUG100')
  new QRCode(document.getElementById(rec.id), rec.content)  // eslint-disable-line no-new
}
