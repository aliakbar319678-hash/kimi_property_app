import PDFDocument from "pdfkit";

export async function generatePDF(template: string, data: any): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50, size: "A4" });
    const chunks: Buffer[] = [];
    doc.on("data", (chunk: Buffer) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);
    if (template === "invoice") buildInvoicePDF(doc, data);
    else if (template === "certificate") buildCertificatePDF(doc, data);
    else { doc.fontSize(20).text("Report"); doc.fontSize(12).text(JSON.stringify(data, null, 2)); }
    doc.end();
  });
}

function buildInvoicePDF(doc: PDFKit.PDFDocument, data: any) {
  const PRIMARY = "#1a3a5c";
  const GRAY    = "#666666";
  const LIGHT   = "#f8f9fa";
  const pageW   = doc.page.width - 100;

  // Header block
  doc.rect(50, 45, pageW, 70).fill(PRIMARY);
  doc.fillColor("white").fontSize(28).font("Helvetica-Bold").text("INVOICE", 65, 60);
  doc.fontSize(11).font("Helvetica").text("#" + (data.invoiceNumber || data.invoice_number || (data.id || "").slice(0,8).toUpperCase() || "N/A"), 65, 93);
  const status = (data.paymentStatus || data.payment_status || "unpaid").toUpperCase();
  doc.fontSize(10).font("Helvetica-Bold").text(status, 0, 78, { align: "right", width: doc.page.width - 65 });
  doc.fillColor("#333333");

  // From / Bill To
  const infoTop = 140;
  doc.fontSize(9).fillColor(GRAY).font("Helvetica-Bold").text("FROM", 50, infoTop);
  doc.fontSize(11).fillColor("#333").font("Helvetica-Bold").text(data.vendorName || "Vendor", 50, infoTop + 14);
  doc.fontSize(10).font("Helvetica").fillColor(GRAY).text(data.vendorEmail || "", 50, infoTop + 28);
  doc.fontSize(9).fillColor(GRAY).font("Helvetica-Bold").text("BILL TO", 300, infoTop);
  doc.fontSize(11).fillColor("#333").font("Helvetica-Bold").text(data.clientName || "Client", 300, infoTop + 14);
  const dueDate = (data.dueDate || data.due_date) ? new Date(data.dueDate || data.due_date).toLocaleDateString() : "Upon receipt";
  doc.fontSize(10).font("Helvetica").fillColor(GRAY).text("Due: " + dueDate, 300, infoTop + 28);

  // Table header
  const tableTop = 230;
  const colDesc = 50, colQty = 340, colRate = 400, colAmt = 470;
  doc.rect(50, tableTop, pageW, 24).fill(LIGHT);
  doc.fillColor(PRIMARY).fontSize(10).font("Helvetica-Bold");
  doc.text("Description", colDesc + 5, tableTop + 7);
  doc.text("Qty",    colQty,  tableTop + 7, { width: 50, align: "right" });
  doc.text("Rate",   colRate, tableTop + 7, { width: 60, align: "right" });
  doc.text("Amount", colAmt,  tableTop + 7, { width: 75, align: "right" });

  // Table rows
  let items: any[] = [];
  try { items = Array.isArray(data.items) ? data.items : JSON.parse(data.items || "[]"); } catch {}
  let y = tableTop + 24;
  doc.font("Helvetica").fontSize(10).fillColor("#333");
  items.forEach((item: any, i: number) => {
    doc.rect(50, y, pageW, 22).fill(i % 2 === 0 ? "#ffffff" : LIGHT);
    const rate = Number(item.rate ?? item.price ?? 0);
    const qty  = Number(item.quantity ?? 1);
    doc.fillColor("#333")
       .text(item.description || "", colDesc + 5, y + 6, { width: 270 })
       .text(String(qty),  colQty,  y + 6, { width: 50, align: "right" })
       .text("$" + rate.toFixed(2),    colRate, y + 6, { width: 60, align: "right" })
       .text("$" + (qty * rate).toFixed(2), colAmt, y + 6, { width: 75, align: "right" });
    y += 22;
  });
  doc.moveTo(50, y + 8).lineTo(50 + pageW, y + 8).strokeColor("#dddddd").stroke();

  // Totals
  const totalsX = 370;
  let ty = y + 20;
  const subtotal = Number(data.amount || 0);
  const tax      = Number(data.taxAmount || data.tax_amount || 0);
  const total    = Number(data.totalAmount || data.total_amount || subtotal + tax);
  const currency = data.currency || "USD";
  doc.fontSize(10).font("Helvetica").fillColor(GRAY).text("Subtotal:", totalsX, ty, { width: 80 });
  doc.fillColor("#333").text("$" + subtotal.toFixed(2), totalsX + 90, ty, { width: 80, align: "right" });
  ty += 18;
  doc.fillColor(GRAY).text("Tax:", totalsX, ty, { width: 80 });
  doc.fillColor("#333").text("$" + tax.toFixed(2), totalsX + 90, ty, { width: 80, align: "right" });
  ty += 20;
  doc.moveTo(totalsX, ty).lineTo(totalsX + 170, ty).strokeColor("#333").stroke();
  ty += 8;
  doc.fontSize(13).font("Helvetica-Bold").fillColor(PRIMARY);
  doc.text("Total (" + currency + "):", totalsX, ty, { width: 100 });
  doc.text("$" + total.toFixed(2), totalsX + 90, ty, { width: 80, align: "right" });

  // Notes
  if (data.notes) {
    const notesTop = ty + 50;
    doc.rect(50, notesTop, pageW, 14).fill(LIGHT);
    doc.fontSize(9).font("Helvetica-Bold").fillColor(GRAY).text("NOTES", 55, notesTop + 3);
    doc.fontSize(10).font("Helvetica").fillColor("#333").text(data.notes, 55, notesTop + 18, { width: pageW - 10 });
  }

  // Footer
  doc.fontSize(8).fillColor(GRAY).font("Helvetica").text("Thank you for your business.", 50, doc.page.height - 50, { align: "center", width: pageW });
}

function buildCertificatePDF(doc: PDFKit.PDFDocument, data: any) {
  const PRIMARY = "#1a3a5c";
  const pageW = doc.page.width - 100;
  doc.rect(30, 30, doc.page.width - 60, doc.page.height - 60).strokeColor(PRIMARY).lineWidth(8).stroke();
  doc.fontSize(28).font("Helvetica-Bold").fillColor(PRIMARY).text("CERTIFICATE OF COMPLETION", 50, 100, { align: "center", width: pageW });
  doc.fontSize(14).font("Helvetica").fillColor("#555").text("This is to certify that", { align: "center" });
  doc.moveDown(0.5);
  doc.fontSize(22).font("Helvetica-Bold").fillColor("#333").text(data.fullName || data.full_name || "Student", { align: "center" });
  doc.moveDown(0.5);
  doc.fontSize(14).font("Helvetica").fillColor("#555").text("has successfully completed the course", { align: "center" });
  doc.moveDown(0.5);
  doc.fontSize(20).font("Helvetica-Bold").fillColor(PRIMARY).text(data.courseName || data.course_name || "Course", { align: "center" });
  doc.moveDown(2);
  doc.fontSize(12).font("Helvetica").fillColor("#666").text("Certificate ID: " + (data.certificateNumber || data.certificate_number || "N/A"), { align: "center" });
  doc.text("Issued: " + (data.issuedDate || new Date().toISOString().split("T")[0]), { align: "center" });
}

// No-op — kept for backward compatibility (no browser to close)
export async function closeBrowser() {}
