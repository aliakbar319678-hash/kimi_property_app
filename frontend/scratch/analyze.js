const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

const emptyHandlerRegex = /(onPressed|onTap):\s*\(\)\s*\{\s*\}/g;
const results = [];

walkDir('lib/screens', (filePath) => {
  if (filePath.endsWith('.dart')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let match;
    while ((match = emptyHandlerRegex.exec(content)) !== null) {
      // Find line number
      const untilMatch = content.substring(0, match.index);
      const lineNum = untilMatch.split('\n').length;
      results.push(`{"File":"${filePath}","LineNumber":${lineNum}}`);
    }
  }
});

fs.writeFileSync('scratch/all_empty_handlers.json', `[${results.join(',')}]`);
console.log(`Found ${results.length} empty handlers.`);
