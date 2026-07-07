const { Client } = require('pg');
const client = new Client({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });
client.connect().then(async () => {
  await client.query(`UPDATE lms_resources SET file_url = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf' WHERE type IN ('legal_doc', 'checklist', 'template', 'guide')`);
  await client.query(`UPDATE lms_resources SET file_url = 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4' WHERE type = 'video'`);
  await client.query(`UPDATE lms_resources SET file_url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3' WHERE type = 'audio'`);
  console.log('Update complete');
}).catch(console.error).finally(() => client.end());
