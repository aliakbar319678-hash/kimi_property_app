import { query } from './db';

async function main() {
    console.log("Updating resources to point to real files...");
    
    // Map of types to real filenames in public/uploads/
    const updates = [
        { type: 'legaldoc', url: 'http://localhost:5000/uploads/w9_form.pdf' },
        { type: 'checklist', url: 'http://localhost:5000/uploads/checklist.pdf' },
        { type: 'template', url: 'http://localhost:5000/uploads/template.pdf' },
        { type: 'guide', url: 'http://localhost:5000/uploads/guide.pdf' },
        { type: 'video', url: 'http://localhost:5000/uploads/1782250011445-551107992-Boy.mp4' },
        { type: 'audio', url: 'http://localhost:5000/uploads/dummy_audio.mp3' } // assuming dummy for now
    ];

    for (const item of updates) {
        await query('UPDATE lms_resources SET file_url = $1 WHERE type = $2', [item.url, item.type]);
    }

    console.log("Updated resources.");
    process.exit(0);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
