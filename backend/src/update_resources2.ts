import { query } from './db';

async function main() {
    console.log("Updating resources to point to real files...");
    
    // Map of types to real filenames in public/uploads/
    const updates = [
        { type: 'legal_doc', url: 'http://localhost:5000/uploads/w9_form.pdf' },
        { type: 'audio', url: 'http://localhost:5000/uploads/dummy_audio.mp3' }
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
