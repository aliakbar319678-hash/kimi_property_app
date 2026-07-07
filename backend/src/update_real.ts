import { query } from './db';
import * as fs from 'fs';
import * as http from 'http';
import * as https from 'https';

function download(url: string, dest: string): Promise<void> {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(dest);
        const protocol = url.startsWith('https') ? https : http;
        protocol.get(url, (response) => {
            response.pipe(file);
            file.on('finish', () => {
                file.close();
                resolve();
            });
        }).on('error', (err) => {
            fs.unlink(dest, () => {});
            reject(err);
        });
    });
}

async function main() {
    console.log("Downloading real files...");
    await download('https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_1MB_MP3.mp3', './public/uploads/real_audio.mp3').catch(e => console.log('Audio download failed', e));
    await download('https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_100KB_PDF.pdf', './public/uploads/real_doc.pdf').catch(e => console.log('PDF download failed', e));
    
    const updates = [
        { type: 'legal_doc', url: 'http://localhost:5000/uploads/real_doc.pdf' },
        { type: 'checklist', url: 'http://localhost:5000/uploads/real_doc.pdf' },
        { type: 'template', url: 'http://localhost:5000/uploads/real_doc.pdf' },
        { type: 'guide', url: 'http://localhost:5000/uploads/real_doc.pdf' },
        { type: 'audio', url: 'http://localhost:5000/uploads/real_audio.mp3' }
    ];

    for (const item of updates) {
        await query('UPDATE lms_resources SET file_url = $1 WHERE type = $2', [item.url, item.type]);
    }

    console.log("Downloaded real files and updated DB");
    process.exit(0);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
