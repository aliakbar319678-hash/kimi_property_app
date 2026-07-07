const { Client } = require('pg');

const dbUrl = 'postgresql://postgres:1122@localhost:5432/mydatabase';
const client = new Client({ connectionString: dbUrl });

async function seed() {
    await client.connect();
    try {
        console.log('Clearing old resources...');
        await client.query('DELETE FROM lms_resources');

        console.log('Inserting real data records...');
        
        await client.query(`
            INSERT INTO lms_resources (id, title, type, description, file_url, file_size) VALUES 
            (gen_random_uuid(), 'Contractor Tax Form (W-9)', 'legal_doc', 'Official IRS Form W-9 for contractor tax identification and compliance.', 'https://www.irs.gov/pub/irs-pdf/fw9.pdf', '135 KB'),
            (gen_random_uuid(), 'Employee Withholding Allowance (W-4)', 'checklist', 'Official IRS Form W-4 for employee tax withholding.', 'https://www.irs.gov/pub/irs-pdf/fw4.pdf', '115 KB'),
            (gen_random_uuid(), 'Employment Eligibility Verification (I-9)', 'template', 'Standard form for verifying the identity and employment authorization of individuals.', 'https://www.uscis.gov/sites/default/files/document/forms/i-9.pdf', '480 KB'),
            (gen_random_uuid(), 'HUD Fair Housing Guide', 'guide', 'Comprehensive guide for federal fair housing compliance.', 'https://www.hud.gov/sites/dfiles/FPM/documents/FPM_Brochure.pdf', '1.2 MB'),
            (gen_random_uuid(), 'Property Maintenance Tutorial', 'video', 'Video tutorial on routine property maintenance tasks.', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', '1.0 MB'),
            (gen_random_uuid(), 'Weekly Operations Briefing', 'audio', 'Audio recording of the weekly property management briefing.', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', '5.4 MB')
        `);

        console.log('Seeding completed successfully!');
    } catch (err) {
        console.error('Error during seeding:', err);
    } finally {
        await client.end();
    }
}

seed();
