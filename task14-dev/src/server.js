const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Version 2: LIVE RELOAD WORKS\n'));
app.listen(8080, () => console.log('Server listening on port 8080'));
