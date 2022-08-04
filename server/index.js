const express = require('express');
const router = require('./router');
require('dotenv').config();

const app = express();

app.use(express.json());

app.use('/', router);

app.get('/loaderio-3de1b3c04d31e9982aca7972e40f1698', (req, res) => {
  res.send('loaderio-3de1b3c04d31e9982aca7972e40f1698');
})

const PORT = process.env.port || 3000;

app.listen(PORT);
