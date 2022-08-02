const express = require('express');
const router = require('./router');
require('dotenv').config();

const app = express();

app.use(express.json());

app.use('/', router);

const PORT = process.env.port || 3000;

app.listen(PORT);
