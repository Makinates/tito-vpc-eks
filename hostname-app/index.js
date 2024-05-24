const express = require('express');
const os = require('os');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

app.get('/hostname', (req, res) => {
  res.json({ hostname: os.hostname() });
});

app.use(express.static(path.join(__dirname, 'public')));

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
