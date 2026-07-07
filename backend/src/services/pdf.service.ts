import puppeteer, { Browser } from 'puppeteer';

let browser: Browser | null = null;

async function getBrowser() {
  if (!browser) {
    browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  }
  return browser;
}

export async function generatePDF(template: string, data: any): Promise<Buffer> {
  const b = await getBrowser();
  const page = await b.newPage();

  let html = '';
  if (template === 'certificate') {
    html = `
    <html>
    <head><style>body{font-family:serif;text-align:center;padding:60px;border:10px solid #1a3a5c;} h1{font-size:36px;} .name{font-size:28px;margin:40px 0;} .details{margin-top:60px;}</style></head>
    <body>
      <h1>CERTIFICATE OF COMPLETION</h1>
      <p>This is to certify that</p>
      <div class="name"><strong>${data.fullName || data.full_name || 'Student'}</strong></div>
      <p>Has successfully completed the course</p>
      <div class="name"><strong>${data.courseName || data.course_name || 'Course'}</strong></div>
      <div class="details">
        <p>Certificate ID: ${data.certificateNumber || data.certificate_number || 'N/A'}</p>
        <p>Issued: ${data.issuedDate || new Date().toISOString().split('T')[0]}</p>
      </div>
    </body>
    </html>`;
  } else if (template === 'invoice') {
    html = `
    <html>
    <head><style>body{font-family:sans-serif;padding:40px;} table{width:100%;border-collapse:collapse;} th,td{border:1px solid #ddd;padding:8px;}</style></head>
    <body>
      <h1>Invoice #${data.invoiceNumber || 'N/A'}</h1>
      <p>Vendor: ${data.vendorName || 'Vendor'}</p>
      <p>Amount: ${data.amount || 0} ${data.currency || 'USD'}</p>
      <table><tr><th>Item</th><th>Qty</th><th>Rate</th><th>Total</th></tr>
      ${(data.items || []).map((i: any) => `<tr><td>${i.description}</td><td>${i.quantity}</td><td>${i.rate}</td><td>${i.quantity * i.rate}</td></tr>`).join('')}
      </table>
    </body>
    </html>`;
  } else {
    html = data.html || '<html><body><h1>Report</h1></body></html>';
  }

  await page.setContent(html, { waitUntil: 'networkidle0' });
  const pdfBuffer = await page.pdf({ format: 'A4', printBackground: true });
  await page.close();
  return Buffer.from(pdfBuffer);
}

export async function closeBrowser() {
  if (browser) { await browser.close(); browser = null; }
}
