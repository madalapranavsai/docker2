const express = require('express');
const app = express();
app.get('/health', (req, res) => res.status(200).send('OK'));
app.get('/', (req, res) => res.send('Full Stack Online: NGINX -> Node -> DB/Redis Isolated.\n'));
app.listen(process.env.APP_PORT || 8080, () => console.log('App running'));
