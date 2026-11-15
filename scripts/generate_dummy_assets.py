import os
from PIL import Image, ImageDraw, ImageFont
from reportlab.lib.pagesizes import letter, landscape
from reportlab.pdfgen import canvas
from reportlab.lib import colors

os.makedirs('assets/images', exist_ok=True)
os.makedirs('assets/dummy', exist_ok=True)

# 1. Generate App Logo (512x512)
logo = Image.new('RGBA', (512, 512), color=(0, 0, 0, 0))
draw = ImageDraw.Draw(logo)
# Purple rounded background
draw.rounded_rectangle([16, 16, 496, 496], radius=96, fill='#7663E8')
# Inner decorative accent
draw.rounded_rectangle([48, 48, 464, 464], radius=72, outline='#A99BFF', width=6)
# Draw Certificate Icon (white badge and ribbon)
draw.rounded_rectangle([130, 110, 382, 330], radius=24, fill='white')
draw.rounded_rectangle([160, 150, 352, 170], radius=8, fill='#7663E8')
draw.rounded_rectangle([160, 190, 320, 205], radius=6, fill='#A99BFF')
draw.rounded_rectangle([160, 225, 290, 240], radius=6, fill='#E2DDFE')
# Gold Seal at bottom right of certificate
draw.ellipse([300, 260, 370, 330], fill='#F6AD55', outline='#DD6B20', width=4)
# Ribbon tails
draw.polygon([(320, 325), (310, 370), (335, 355)], fill='#DD6B20')
draw.polygon([(350, 325), (360, 370), (335, 355)], fill='#DD6B20')
# Star in seal
draw.text((326, 280), "★", fill='white')
logo.save('assets/images/app_logo.png')
print("Saved assets/images/app_logo.png")

# 2. Generate Default Avatar (256x256)
avatar = Image.new('RGBA', (256, 256), color=(0, 0, 0, 0))
a_draw = ImageDraw.Draw(avatar)
a_draw.ellipse([8, 8, 248, 248], fill='#E8E5FD')
a_draw.ellipse([80, 50, 176, 146], fill='#7663E8')
a_draw.chord([40, 140, 216, 280], start=0, end=180, fill='#7663E8')
avatar.save('assets/images/default_avatar.png')
print("Saved assets/images/default_avatar.png")

# 3. Helper to generate Image Certificates
def generate_cert_image(filename, title, recipient, organizer, date_str, cert_no, bg_color, border_color):
    img = Image.new('RGB', (1200, 850), color=bg_color)
    d = ImageDraw.Draw(img)
    
    # Outer decorative borders
    d.rectangle([30, 30, 1170, 820], outline=border_color, width=8)
    d.rectangle([45, 45, 1155, 805], outline='#E2E8F0', width=2)
    
    # Header banner
    d.rectangle([200, 70, 1000, 140], fill=border_color)
    d.text((450, 90), "CERTIFICATE OF ACHIEVEMENT", fill='white')
    
    # Body text
    d.text((480, 190), "THIS IS PROUDLY PRESENTED TO", fill='#718096')
    d.text((450, 240), recipient, fill='#2D3748')
    d.line([(350, 285), (850, 285)], fill=border_color, width=3)
    
    d.text((430, 320), "FOR OUTSTANDING PERFORMANCE IN", fill='#718096')
    d.text((380, 370), title, fill='#1A202C')
    
    d.text((440, 450), f"Organized by: {organizer}", fill='#4A5568')
    d.text((470, 490), f"Date of Issue: {date_str}", fill='#718096')
    d.text((450, 530), f"Credential ID: {cert_no}", fill='#718096')
    
    # Signatures and Seals
    d.line([(220, 680), (450, 680)], fill='#A0AEC0', width=2)
    d.text((270, 695), "Authorized Signatory", fill='#718096')
    d.text((280, 720), organizer, fill='#2D3748')
    
    # Seal
    d.ellipse([540, 620, 660, 740], fill='#ECC94B', outline='#D69E2E', width=4)
    d.text((580, 670), "VERIFIED", fill='#744210')
    
    d.line([(750, 680), (980, 680)], fill='#A0AEC0', width=2)
    d.text((810, 695), "Head of Committee", fill='#718096')
    d.text((830, 720), "Certify Board", fill='#2D3748')
    
    img.save(filename, quality=95)
    print(f"Saved {filename}")

# Generate sample image certificates
generate_cert_image(
    'assets/dummy/national_programming_competition.jpg',
    'National Programming Competition',
    'Rafi Pratama',
    'Politeknik Negeri Batam',
    '20 November 2025',
    'POLIBATAM-NPC-2025-042',
    '#FFFFFF',
    '#3182CE'
)

generate_cert_image(
    'assets/dummy/uiux_design_webinar.png',
    'UI/UX Design Masterclass Webinar',
    'Rafi Pratama',
    'Binar Academy',
    '05 Februari 2026',
    'BINAR-UIUX-2026-7819',
    '#FFFDF9',
    '#DD6B20'
)

generate_cert_image(
    'assets/dummy/student_leadership.jpg',
    'Student Leadership Training (LKMM)',
    'Rafi Pratama',
    'Himpunan Mahasiswa',
    '18 September 2025',
    'HIMA-LKMM-2025-103',
    '#F7FAFC',
    '#38A169'
)

# 4. Helper to generate PDF Certificates using ReportLab
def generate_cert_pdf(filename, title, recipient, organizer, date_str, cert_no, primary_col):
    c = canvas.Canvas(filename, pagesize=landscape(letter))
    w, h = landscape(letter)
    
    # Background border
    c.setStrokeColor(primary_col)
    c.setLineWidth(5)
    c.rect(30, 30, w - 60, h - 60)
    
    c.setStrokeColor(colors.HexColor('#CBD5E1'))
    c.setLineWidth(1)
    c.rect(40, 40, w - 80, h - 80)
    
    # Header
    c.setFont("Helvetica-Bold", 26)
    c.setFillColor(primary_col)
    c.drawCentredString(w / 2, h - 110, "CERTIFICATE OF COMPLETION")
    
    c.setFont("Helvetica", 14)
    c.setFillColor(colors.HexColor('#64748B'))
    c.drawCentredString(w / 2, h - 145, "PROUDLY AWARDED TO")
    
    # Recipient
    c.setFont("Helvetica-Bold", 24)
    c.setFillColor(colors.HexColor('#0F172A'))
    c.drawCentredString(w / 2, h - 190, recipient)
    
    c.setStrokeColor(primary_col)
    c.setLineWidth(2)
    c.line(w / 2 - 180, h - 205, w / 2 + 180, h - 205)
    
    # Description & Event
    c.setFont("Helvetica", 13)
    c.setFillColor(colors.HexColor('#475569'))
    c.drawCentredString(w / 2, h - 240, "for successfully completing with distinction the curriculum of")
    
    c.setFont("Helvetica-Bold", 20)
    c.setFillColor(colors.HexColor('#1E293B'))
    c.drawCentredString(w / 2, h - 280, title)
    
    c.setFont("Helvetica", 12)
    c.setFillColor(colors.HexColor('#64748B'))
    c.drawCentredString(w / 2, h - 320, f"Organized and Certified by {organizer}")
    c.drawCentredString(w / 2, h - 345, f"Date: {date_str}  |  Certificate ID: {cert_no}")
    
    # Verification Badge
    c.setFillColor(colors.HexColor('#FEF3C7'))
    c.setStrokeColor(colors.HexColor('#F59E0B'))
    c.circle(w / 2, 160, 40, fill=1)
    c.setFillColor(colors.HexColor('#92400E'))
    c.setFont("Helvetica-Bold", 10)
    c.drawCentredString(w / 2, 165, "OFFICIAL")
    c.drawCentredString(w / 2, 150, "VERIFIED")
    
    # Signatures
    c.setStrokeColor(colors.HexColor('#94A3B8'))
    c.setLineWidth(1)
    c.line(120, 130, 280, 130)
    c.setFont("Helvetica", 10)
    c.setFillColor(colors.HexColor('#64748B'))
    c.drawCentredString(200, 115, "Lead Instructor")
    c.setFont("Helvetica-Bold", 11)
    c.drawCentredString(200, 100, organizer)
    
    c.line(w - 280, 130, w - 120, 130)
    c.setFont("Helvetica", 10)
    c.drawCentredString(w - 200, 115, "Program Director")
    c.setFont("Helvetica-Bold", 11)
    c.drawCentredString(w - 200, 100, "Certify Academic Board")
    
    c.save()
    print(f"Saved {filename}")

generate_cert_pdf(
    'assets/dummy/flutter_workshop.pdf',
    'Flutter & Dart Mobile Development Workshop',
    'Rafi Pratama',
    'Dicoding Indonesia',
    '15 Januari 2026',
    'DICODING-2026-FLT-8921',
    colors.HexColor('#7663E8')
)

generate_cert_pdf(
    'assets/dummy/basic_python.pdf',
    'Basic Python for Data Science & AI Certification',
    'Rafi Pratama',
    'Dicoding Indonesia',
    '12 Agustus 2025',
    'DICODING-PY-2025-3312',
    colors.HexColor('#2563EB')
)

generate_cert_pdf(
    'assets/dummy/national_seminar.pdf',
    'National Seminar on AI and Cloud Computing',
    'Rafi Pratama',
    'Politeknik Negeri Batam',
    '10 Januari 2026',
    'POLIBATAM-SEM-2026-550',
    colors.HexColor('#059669')
)

print("All dummy certificate assets generated successfully!")
