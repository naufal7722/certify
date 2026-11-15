import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls
import os

def create_report(output_path):
    doc = Document()

    # 1. Page Setup A4 & Margins (1 inch all around)
    for section in doc.sections:
        section.page_width = Inches(8.27)
        section.page_height = Inches(11.69)
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)

    # Helper styling functions
    def set_font(run, name='Times New Roman', size_pt=12, bold=False, italic=False, color_rgb=None):
        run.font.name = name
        if size_pt:
            run.font.size = Pt(size_pt)
        run.font.bold = bold
        run.font.italic = italic
        if color_rgb:
            run.font.color.rgb = color_rgb

    def add_p(text="", align=WD_ALIGN_PARAGRAPH.LEFT, space_before=0, space_after=6, line_spacing=1.15):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = line_spacing
        if text:
            r = p.add_run(text)
            set_font(r, 'Times New Roman', 12)
        return p

    def add_placeholder_box(label, description=""):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        cell.width = Inches(6.27)
        
        # Soft subtle background
        tcPr = cell._tc.get_or_add_tcPr()
        tcPr.append(parse_xml(f'<w:shd {nsdecls("w")} w:fill="F8FAFC"/>'))
        
        # Dashed border
        borders = parse_xml(f'''
            <w:tcBorders {nsdecls("w")}>
                <w:top w:val="dashed" w:sz="6" w:space="0" w:color="94A3B8"/>
                <w:left w:val="dashed" w:sz="6" w:space="0" w:color="94A3B8"/>
                <w:bottom w:val="dashed" w:sz="6" w:space="0" w:color="94A3B8"/>
                <w:right w:val="dashed" w:sz="6" w:space="0" w:color="94A3B8"/>
            </w:tcBorders>
        ''')
        tcPr.append(borders)
        
        cp = cell.paragraphs[0]
        cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cp.paragraph_format.space_before = Pt(18)
        cp.paragraph_format.space_after = Pt(18)
        cp.paragraph_format.line_spacing = 1.15
        
        r_title = cp.add_run(f"[Tempatkan Screenshot: {label}]\n")
        set_font(r_title, 'Times New Roman', 11, bold=True, italic=True, color_rgb=RGBColor(71, 85, 105))
        
        if description:
            r_desc = cp.add_run(f"({description})")
            set_font(r_desc, 'Times New Roman', 10, bold=False, italic=True, color_rgb=RGBColor(148, 163, 184))
        
        # Small spacing paragraph after table
        sp = doc.add_paragraph()
        sp.paragraph_format.space_before = Pt(0)
        sp.paragraph_format.space_after = Pt(4)
        sp.paragraph_format.line_spacing = 1.0

    # ==========================================
    # COVER PAGE
    # ==========================================
    p0 = add_p("LAPORAN ", align=WD_ALIGN_PARAGRAPH.CENTER, space_before=12, space_after=0)
    set_font(p0.runs[0], 'Times New Roman', 16, bold=True)

    p1 = add_p("ASESMEN TENGAH SEMESTER ", align=WD_ALIGN_PARAGRAPH.CENTER, space_before=0, space_after=0)
    set_font(p1.runs[0], 'Times New Roman', 20, bold=True)

    p2 = add_p("(PRAKTIKUM)", align=WD_ALIGN_PARAGRAPH.CENTER, space_before=0, space_after=0)
    set_font(p2.runs[0], 'Times New Roman', 20, bold=True)

    p3 = add_p("PEMROGRAMAN PERANGKAT BERGERAK", align=WD_ALIGN_PARAGRAPH.CENTER, space_before=2, space_after=18)
    set_font(p3.runs[0], 'Times New Roman', 14, bold=True)

    # Logo Polibatam
    logo_path = 'extracted_media/polibatam_logo.png'
    if os.path.exists(logo_path):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_before = Pt(12)
        p_logo.paragraph_format.space_after = Pt(28)
        run_logo = p_logo.add_run()
        run_logo.add_picture(logo_path, width=Inches(2.1))
    else:
        add_p("", space_after=24)

    # Identitas Mahasiswa (menggunakan format tabs persis seperti acuan)
    identitas = [
        ("NAMA\t\t\t\t: ", "Naufal Rafi Siregar"),
        ("NIM\t\t\t\t\t: ", "4342501034"),
        ("KELAS\t\t\t\t: ", "TRPL 3B - PAGI"),
        ("SEMESTER\t\t\t\t: ", "Ganjil 2026/2027"),
        ("JADWAL ATS PRAKTIKUM\t: ", "Kamis 12 November"),
    ]
    for lbl, val in identitas:
        pi = doc.add_paragraph()
        pi.paragraph_format.space_before = Pt(0)
        pi.paragraph_format.space_after = Pt(2)
        pi.paragraph_format.line_spacing = 1.15
        r_lbl = pi.add_run(lbl)
        set_font(r_lbl, 'Times New Roman', 12, bold=False)
        r_val = pi.add_run(val)
        set_font(r_val, 'Times New Roman', 12, bold=False)

    add_p("", space_after=6)

    # Dosen Info
    dosen = [
        ("KOORDINATOR MATA KULIAH\t: ", "Ahmadi Irmansyah Lubis"),
        ("PENGAMPU MATA KULIAH\t: ", "Iqbal Afif"),
    ]
    for lbl, val in dosen:
        pd = doc.add_paragraph()
        pd.paragraph_format.space_before = Pt(0)
        pd.paragraph_format.space_after = Pt(2)
        pd.paragraph_format.line_spacing = 1.15
        r_lbl = pd.add_run(lbl)
        set_font(r_lbl, 'Times New Roman', 12, bold=False)
        r_val = pd.add_run(val)
        set_font(r_val, 'Times New Roman', 12, bold=False)

    add_p("", space_after=28)

    # Lembaga Affiliation block
    institusi = [
        "PROGRAM STUDI TEKNOLOGI REKAYASA PERANGKAT LUNAK",
        "JURUSAN TEKNIK INFORMATIKA",
        "POLITEKNIK NEGERI BATAM",
        "2026"
    ]
    for line in institusi:
        p_inst = doc.add_paragraph()
        p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_inst.paragraph_format.space_before = Pt(0)
        p_inst.paragraph_format.space_after = Pt(2)
        r_inst = p_inst.add_run(line)
        set_font(r_inst, 'Times New Roman', 14, bold=True)

    # ==========================================
    # PAGE BREAK
    # ==========================================
    doc.add_page_break()

    # ==========================================
    # SECTION 1: LANGKAH-LANGKAH PENGERJAAN
    # ==========================================
    p_sec1 = doc.add_paragraph()
    p_sec1.paragraph_format.space_before = Pt(0)
    p_sec1.paragraph_format.space_after = Pt(12)
    r_sec1 = p_sec1.add_run("1. Langkah - Langkah Pengerjaan")
    set_font(r_sec1, 'Times New Roman', 14, bold=True)

    # Langkah 1
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 1. Membuka folder tempat menyimpan project")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Buka File Explorer, lalu masuk ke folder D:\\ATS Pemrograman Perangkat Bergerak. Folder ini digunakan sebagai lokasi direktori kerja utama untuk membuat dan menyimpan proyek aplikasi Certify.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("File Explorer di folder penyimpanan project", "Buka File Explorer pada D:\\ATS Pemrograman Perangkat Bergerak")

    # Langkah 2
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 2. Membuka Command Prompt di folder tersebut")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Pada address bar File Explorer, ketik cmd lalu tekan Enter. Command Prompt terbuka langsung mengarah ke lokasi direktori kerja D:\\ATS Pemrograman Perangkat Bergerak.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("Command Prompt terbuka di folder kerja", "Terminal aktif di direktori D:\\ATS Pemrograman Perangkat Bergerak")

    # Langkah 3
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 3. Menjalankan perintah flutter create")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Di Command Prompt, ketik perintah flutter create certify lalu tekan Enter. Perintah ini membuat struktur project Flutter baru bernama certify lengkap dengan file konfigurasi pubspec.yaml, folder lib, android, dan ios.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("Perintah flutter create certify", "Proses inisialisasi project Flutter baru di terminal")

    # Langkah 4
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 4. Project berhasil dibuat")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Flutter menampilkan pesan Wrote 131 files. dan All done!, yang menandakan project berhasil dibuat dengan sukses. Titik masuk kode aplikasi berada di certify\\lib\\main.dart.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("Pesan sukses 'All done!' di terminal", "Output pembuatan project Flutter berhasil di Command Prompt")

    # Langkah 5
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 5. Memastikan folder project terbentuk")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Kembali ke File Explorer. Folder certify sudah muncul di direktori D:\\ATS Pemrograman Perangkat Bergerak, sesuai dengan nama yang diberikan saat perintah flutter create.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("Folder certify terbentuk di File Explorer", "Tampilan folder certify hasil generate di direktori kerja")

    # Langkah 6
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 6. Masuk ke folder project dan membuka VS Code")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Di Command Prompt, ketik cd certify untuk masuk ke direktori folder project, lalu ketik code . untuk membuka folder tersebut ke dalam editor Visual Studio Code.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("Perintah cd certify dan code .", "Navigasi ke direktori project dan perintah membuka VS Code")

    # Langkah 7
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 7. Project terbuka di Visual Studio Code")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_desc = doc.add_paragraph()
    p_desc.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_desc.paragraph_format.space_before = Pt(0)
    p_desc.paragraph_format.space_after = Pt(6)
    p_desc.paragraph_format.line_spacing = 1.5
    r_desc = p_desc.add_run("Visual Studio Code terbuka dengan project certify. Panel Explorer menampilkan struktur project lengkap, termasuk folder lib yang berisi subfolder core, models, providers, repositories, screens, services, widgets, serta file utama main.dart.")
    set_font(r_desc, 'Times New Roman', 12)
    add_placeholder_box("VS Code terbuka menampilkan struktur project certify", "Tampilan panel Explorer VS Code dengan susunan folder proyek")

    # ==========================================
    # LANGKAH 8 DAN SETERUSNYA (SESUAI PROYEK CERTIFY)
    # ==========================================

    # Langkah 8: Folder models
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 8. Folder models")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/models. Folder ini mendefinisikan entitas data domain utama aplikasi:")
    set_font(r_sub, 'Times New Roman', 12)

    p_m1 = doc.add_paragraph()
    p_m1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_m1.paragraph_format.space_before = Pt(0)
    p_m1.paragraph_format.space_after = Pt(6)
    p_m1.paragraph_format.line_spacing = 1.5
    r_mf1 = p_m1.add_run("certificate.dart: ")
    set_font(r_mf1, 'Times New Roman', 12, bold=True)
    r_mt1 = p_m1.add_run("class Certificate merepresentasikan data sertifikat prestasi dengan atribut id, title (judul/nama kegiatan), category (kategori kegiatan seperti Workshop, Competition, Webinar, Certification, Academic, Organization, Lainnya), organizerId (relasi unik ke ID penyelenggara), issueDate (tanggal terbit bertipe DateTime), filePath (lokasi fisik dokumen di penyimpanan lokal perangkat), fileType ('pdf' atau 'image'), certificateNumber (nomor identitas/kredensial sertifikat, opsional), description (keterangan tambahan kegiatan, opsional), dan isFavorite (boolean penanda sertifikat favorit/unggulan). Class ini menyediakan method copyWith untuk memperbarui data secara immutable, toMap untuk serialisasi ke JSON, dan factory Certificate.fromMap untuk deserialisasi data dari penyimpanan lokal.")
    set_font(r_mt1, 'Times New Roman', 12)
    add_placeholder_box("lib/models/certificate.dart", "Class Certificate, copyWith, toMap, dan fromMap")

    p_m2 = doc.add_paragraph()
    p_m2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_m2.paragraph_format.space_before = Pt(0)
    p_m2.paragraph_format.space_after = Pt(6)
    p_m2.paragraph_format.line_spacing = 1.5
    r_mf2 = p_m2.add_run("organizer.dart: ")
    set_font(r_mf2, 'Times New Roman', 12, bold=True)
    r_mt2 = p_m2.add_run("class Organizer merepresentasikan lembaga atau organisasi penerbit sertifikat dengan atribut id, name (nama instansi atau lembaga penyelenggara), dan createdAt (waktu pendaftaran entitas bertipe DateTime). Class ini dilengkapi dengan method copyWith untuk mengubah nama instansi, toMap untuk konversi ke Map/JSON, serta factory Organizer.fromMap untuk mengonstruksi objek kembali dari penyimpanan lokal.")
    set_font(r_mt2, 'Times New Roman', 12)
    add_placeholder_box("lib/models/organizer.dart", "Class Organizer, copyWith, toMap, dan fromMap")

    # Langkah 9: Folder core
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 9. Folder core (constants, theme, dan utils)")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/core. Folder ini menyediakan pondasi konfigurasi global, tema visual, dan fungsi utilitas pendukung:")
    set_font(r_sub, 'Times New Roman', 12)

    p_c1 = doc.add_paragraph()
    p_c1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_c1.paragraph_format.space_before = Pt(0)
    p_c1.paragraph_format.space_after = Pt(6)
    p_c1.paragraph_format.line_spacing = 1.5
    r_cf1 = p_c1.add_run("constants/app_colors.dart: ")
    set_font(r_cf1, 'Times New Roman', 12, bold=True)
    r_ct1 = p_c1.add_run("class AppColors mendefinisikan palet warna terpusat yang presisi sesuai dokumen spesifikasi desain Certify: warna utama (Primary: #7663E8, PrimaryDark: #5B49D1, PrimaryLight: #EBE8FD, Secondary: #A99BFF), warna latar belakang (Background: #F4F3FA, Surface/Card: #FFFFFF), warna tipografi (TextPrimary: #22213A, TextSecondary: #7A7893, TextMuted: #A5A3B8), warna pembatas (Border: #E6E5F2, Divider: #EEEEF6), serta palet status (success, warning, danger, info, gold). Selain itu, terdapat method getCategoryColor(category) yang memetakan warna aksen unik secara otomatis untuk setiap kategori sertifikat.")
    set_font(r_ct1, 'Times New Roman', 12)
    add_placeholder_box("lib/core/constants/app_colors.dart", "Palet warna desain sistem dan getCategoryColor")

    p_c2 = doc.add_paragraph()
    p_c2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_c2.paragraph_format.space_before = Pt(0)
    p_c2.paragraph_format.space_after = Pt(6)
    p_c2.paragraph_format.line_spacing = 1.5
    r_cf2 = p_c2.add_run("constants/app_constants.dart: ")
    set_font(r_cf2, 'Times New Roman', 12, bold=True)
    r_ct2 = p_c2.add_run("class AppConstants menyimpan konstanta global aplikasi: nama aplikasi ('Certify'), tagline ('Personal Certificate & Achievement Manager'), versi aplikasi ('1.0.0'), daftar 7 kategori standar (Workshop, Competition, Webinar, Certification, Academic, Organization, Lainnya), kunci penyimpanan SharedPreferences, batas ukuran berkas maksimum 10 MB (10 * 1024 * 1024 byte), ekstensi berkas yang didukung (['jpg', 'jpeg', 'png', 'pdf']), serta profil pengguna default.")
    set_font(r_ct2, 'Times New Roman', 12)
    add_placeholder_box("lib/core/constants/app_constants.dart", "Daftar kategori standar, key storage, dan konfigurasi berkas")

    p_c3 = doc.add_paragraph()
    p_c3.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_c3.paragraph_format.space_before = Pt(0)
    p_c3.paragraph_format.space_after = Pt(6)
    p_c3.paragraph_format.line_spacing = 1.5
    r_cf3 = p_c3.add_run("theme/app_theme.dart: ")
    set_font(r_cf3, 'Times New Roman', 12, bold=True)
    r_ct3 = p_c3.add_run("class AppTheme mengonfigurasi tema global aplikasi (lightTheme) berbasis Material 3. Mengatur ColorScheme bernuansa warna primer ungu, scaffoldBackgroundColor bernuansa abu-abu sejuk (#F4F3FA), tipografi fontFamily 'Inter', AppBarTheme transparan dengan ikon gelap, CardTheme bersudut membulat 16px dengan garis tepi halus, gaya tombol ElevatedButton dan OutlinedButton bersudut 12px, serta InputDecorationTheme dengan radius 12px dan fokus border beraksen primary.")
    set_font(r_ct3, 'Times New Roman', 12)
    add_placeholder_box("lib/core/theme/app_theme.dart", "Konfigurasi ThemeData Material 3 global")

    p_c4 = doc.add_paragraph()
    p_c4.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_c4.paragraph_format.space_before = Pt(0)
    p_c4.paragraph_format.space_after = Pt(6)
    p_c4.paragraph_format.line_spacing = 1.5
    r_cf4 = p_c4.add_run("utils/ (date_formatter.dart, file_utils.dart, dialog_utils.dart): ")
    set_font(r_cf4, 'Times New Roman', 12, bold=True)
    r_ct4 = p_c4.add_run("DateFormatter memformat tanggal dengan pustaka intl untuk format lokal Indonesia resmi (formatFull: 'dd MMMM yyyy'), format pendek (formatShort), format tahun (formatYear), dan bulan-tahun (formatMonthYear). FileUtils menangani operasi berkas seperti deteksi ekstensi (getFileExtension), klasifikasi tipe 'pdf'/'image' (getFileType, isPdf, isImage), format ukuran berkas ke satuan B/KB/MB (formatBytes), dan verifikasi keberadaan fisik berkas (fileExists). DialogUtils mempermudah penanganan SnackBar feedback interaktif, dialog konfirmasi aksi destruktif (showConfirmDialog), dan dialog peringatan informasi.")
    set_font(r_ct4, 'Times New Roman', 12)
    add_placeholder_box("lib/core/utils/ (date_formatter, file_utils, dialog_utils)", "Fungsi utilitas pemformatan tanggal, berkas, dan dialog")

    # Langkah 10: Folder repositories & services
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 10. Folder repositories & services")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/repositories dan lib/services. Layer ini mengabstraksikan persistensi data lokal dan operasi I/O sistem berkas perangkat:")
    set_font(r_sub, 'Times New Roman', 12)

    p_rs1 = doc.add_paragraph()
    p_rs1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_rs1.paragraph_format.space_before = Pt(0)
    p_rs1.paragraph_format.space_after = Pt(6)
    p_rs1.paragraph_format.line_spacing = 1.5
    r_rf1 = p_rs1.add_run("repositories/ (certificate_repository.dart & organizer_repository.dart): ")
    set_font(r_rf1, 'Times New Roman', 12, bold=True)
    r_rt1 = p_rs1.add_run("Class CertificateRepository dan OrganizerRepository memisahkan domain logic dari implementasi penyimpanan. Class ini menyediakan method getCertificates() dan saveCertificates(), serta getOrganizers() dan saveOrganizers() yang memanggil StorageService.")
    set_font(r_rt1, 'Times New Roman', 12)
    add_placeholder_box("lib/repositories/", "certificate_repository.dart dan organizer_repository.dart")

    p_rs2 = doc.add_paragraph()
    p_rs2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_rs2.paragraph_format.space_before = Pt(0)
    p_rs2.paragraph_format.space_after = Pt(6)
    p_rs2.paragraph_format.line_spacing = 1.5
    r_rf2 = p_rs2.add_run("services/storage_service.dart: ")
    set_font(r_rf2, 'Times New Roman', 12, bold=True)
    r_rt2 = p_rs2.add_run("Class StorageService mengelola persistensi data luring ke SharedPreferences dalam format JSON terstruktur untuk sertifikat dan penyelenggara. Saat pertama kali aplikasi dipasang (first launch), StorageService secara otomatis menjalankan seedInitialData(), yaitu menyalin berkas-berkas sertifikat bawaan dari folder assets/dummy/ (3 PDF resmi dan 3 gambar JPG/PNG) ke direktori internal dokumen aplikasi (path_provider) agar dapat diakses secara nyata oleh sistem operasi, serta menginisialisasi sesi autentikasi pengguna.")
    set_font(r_rt2, 'Times New Roman', 12)
    add_placeholder_box("lib/services/storage_service.dart", "Persistensi JSON SharedPreferences dan auto-seed data bawaan")

    p_rs3 = doc.add_paragraph()
    p_rs3.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_rs3.paragraph_format.space_before = Pt(0)
    p_rs3.paragraph_format.space_after = Pt(6)
    p_rs3.paragraph_format.line_spacing = 1.5
    r_rf3 = p_rs3.add_run("services/ (file_picker_service.dart & share_service.dart): ")
    set_font(r_rf3, 'Times New Roman', 12, bold=True)
    r_rt3 = p_rs3.add_run("FilePickerService mengintegrasikan pustaka file_picker untuk memungkinkan pengguna mengunggah dokumen sertifikat dari penyimpanan perangkat, memvalidasi ekstensi yang diizinkan (PDF, JPG, PNG) dan batas ukuran berkas maksimum (10 MB), serta menyalin berkas tersebut ke folder dokumen aplikasi dengan penamaan nama berkas acak berbasis UUID v4 agar aman dan terhindar dari konflik nama. ShareService memanfaatkan pustaka share_plus (SharePlus.instance.share) untuk membagikan berkas fisik sertifikat beserta keterangan teks ke aplikasi lain seperti WhatsApp, Gmail, atau Google Drive.")
    set_font(r_rt3, 'Times New Roman', 12)
    add_placeholder_box("lib/services/ (file_picker_service & share_service)", "Integrasi pemilih berkas dokumen dan fitur share")

    # Langkah 11: Folder providers
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 11. Folder providers")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/providers. Folder ini merupakan pusat manajemen state aplikasi menggunakan ChangeNotifier yang memicu notifyListeners() agar antarmuka yang mengonsumsi state langsung diperbarui secara reaktif:")
    set_font(r_sub, 'Times New Roman', 12)

    p_pv1 = doc.add_paragraph()
    p_pv1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_pv1.paragraph_format.space_before = Pt(0)
    p_pv1.paragraph_format.space_after = Pt(6)
    p_pv1.paragraph_format.line_spacing = 1.5
    r_pf1 = p_pv1.add_run("auth_provider.dart: ")
    set_font(r_pf1, 'Times New Roman', 12, bold=True)
    r_pt1 = p_pv1.add_run("AuthProvider mengelola status login pengguna (isLoggedIn), nama lengkap (userName), email (userEmail), NIM (userNim), dan institusi (institution). Menyediakan method checkAuthStatus() untuk memuat sesi tersimpan dari SharedPreferences, login(email, password) dengan validasi format dan pemisahan nama secara otomatis, loginWithGoogle() untuk integrasi akun Google, register(...) untuk pendaftaran profil pengguna baru, dan logout() untuk menghapus sesi aktif.")
    set_font(r_pt1, 'Times New Roman', 12)
    add_placeholder_box("lib/providers/auth_provider.dart", "AuthProvider: sesi autentikasi, login, register, dan logout")

    p_pv2 = doc.add_paragraph()
    p_pv2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_pv2.paragraph_format.space_before = Pt(0)
    p_pv2.paragraph_format.space_after = Pt(6)
    p_pv2.paragraph_format.line_spacing = 1.5
    r_pf2 = p_pv2.add_run("organizer_provider.dart: ")
    set_font(r_pf2, 'Times New Roman', 12, bold=True)
    r_pt2 = p_pv2.add_run("OrganizerProvider mengelola daftar penyelenggara kegiatan yang diurutkan secara alfabetis. Fitur intinya mencakup validasi pencegahan duplikasi nama penyelenggara secara case-insensitive dan trimmed pada addOrganizer(rawName)—apabila nama yang dimasukkan sudah ada, provider mengembalikan instansi yang sudah ada sesuai spesifikasi perancangan dokumen Section 5 & 17. Selain itu, terdapat method updateOrganizer(id, newName) yang mencegah nama ganda, deleteOrganizer(id), getOrganizerById(id), dan getOrganizerName(id).")
    set_font(r_pt2, 'Times New Roman', 12)
    add_placeholder_box("lib/providers/organizer_provider.dart", "OrganizerProvider: pencegahan duplikasi dan CRUD penyelenggara")

    p_pv3 = doc.add_paragraph()
    p_pv3.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_pv3.paragraph_format.space_before = Pt(0)
    p_pv3.paragraph_format.space_after = Pt(6)
    p_pv3.paragraph_format.line_spacing = 1.5
    r_pf3 = p_pv3.add_run("certificate_provider.dart: ")
    set_font(r_pf3, 'Times New Roman', 12, bold=True)
    r_pt3 = p_pv3.add_run("CertificateProvider adalah jantung logika bisnis aplikasi Certify. Mengelola koleksi sertifikat, status loading, dan pesan error. Menyimpan parameter pencarian (searchQuery), filter kategori (selectedCategory), filter penyelenggara (selectedOrganizerId), filter tahun (selectedYear), dan pengurutan (sortBy: 'newest', 'oldest', 'a-z', 'z-a'). Method getFilteredCertificates() mengeksekusi multi-filtering dinamis secara instan. Provider ini juga menyediakan getter favoriteCertificates, recentCertificates (5 sertifikat teratas), timelineCertificates, availableYears, operasi CRUD (addCertificate, updateCertificate, deleteCertificate dengan pembersihan berkas fisik lokal, toggleFavorite), komputasi analitik getCategoryDistribution(), getYearDistribution(), getOrganizerDistribution(), serta resetToDummyData() untuk pemulihan katalog awal.")
    set_font(r_pt3, 'Times New Roman', 12)
    add_placeholder_box("lib/providers/certificate_provider.dart", "CertificateProvider: multi-filtering, sorting, CRUD, dan analitik")

    # Langkah 12: screens/splash & screens/onboarding
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 12. Folder screens/splash & screens/onboarding")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/screens/splash dan lib/screens/onboarding. Folder ini menangani tahap awal antarmuka pengguna:")
    set_font(r_sub, 'Times New Roman', 12)

    p_sc1 = doc.add_paragraph()
    p_sc1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_sc1.paragraph_format.space_before = Pt(0)
    p_sc1.paragraph_format.space_after = Pt(6)
    p_sc1.paragraph_format.line_spacing = 1.5
    r_sf1 = p_sc1.add_run("splash_screen.dart: ")
    set_font(r_sf1, 'Times New Roman', 12, bold=True)
    r_st1 = p_sc1.add_run("Halaman splash pembuka aplikasi yang menampilkan logo Certify dengan animasi fade dan scale menggunakan AnimationController. Sambil menampilkan logo, halaman ini secara asinkron memuat status autentikasi melalui AuthProvider.checkAuthStatus() dan menginisialisasi repository data melalui CertificateProvider.initializeData(). Setelah transisi sekitar 2,5 detik, pengguna secara otomatis diarahkan ke MainNavigationScreen (apabila sudah login) atau ke LoginScreen (apabila belum login).")
    set_font(r_st1, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/splash/splash_screen.dart", "Tampilan splash screen dengan animasi dan auto-route")

    p_sc2 = doc.add_paragraph()
    p_sc2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_sc2.paragraph_format.space_before = Pt(0)
    p_sc2.paragraph_format.space_after = Pt(6)
    p_sc2.paragraph_format.line_spacing = 1.5
    r_sf2 = p_sc2.add_run("login_screen.dart: ")
    set_font(r_sf2, 'Times New Roman', 12, bold=True)
    r_st2 = p_sc2.add_run("Halaman autentikasi modern yang bersih dan alami. Berisi formulir input email/username dan kata sandi dengan fitur show/hide password, checkbox 'Ingat saya', tautan pemulihan kata sandi 'Lupa sandi?' dengan dialog interaktif, opsi alternatif 'Lanjutkan dengan Google', serta tautan pendaftaran akun baru 'Daftar Sekarang' yang membuka modal bottom sheet pendaftaran lengkap (nama lengkap, email, NIM, institusi, dan kata sandi). Seluruh kolom dilengkapi validasi ketat untuk mencegah form kosong.")
    set_font(r_st2, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/onboarding/login_screen.dart", "Formulir autentikasi masuk, Google sign in, dan modal pendaftaran")

    # Langkah 13: main_navigation_screen & screens/home
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 13. File main_navigation_screen.dart & screens/home")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka file lib/screens/main_navigation_screen.dart dan folder lib/screens/home:")
    set_font(r_sub, 'Times New Roman', 12)

    p_mn1 = doc.add_paragraph()
    p_mn1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_mn1.paragraph_format.space_before = Pt(0)
    p_mn1.paragraph_format.space_after = Pt(6)
    p_mn1.paragraph_format.line_spacing = 1.5
    r_mf1 = p_mn1.add_run("main_navigation_screen.dart: ")
    set_font(r_mf1, 'Times New Roman', 12, bold=True)
    r_mt1 = p_mn1.add_run("Merupakan kerangka navigasi utama aplikasi yang membungkus 4 halaman inti (Beranda: HomeScreen, Sertifikat: CertificatesScreen, Favorit: FavoritesScreen, dan Profil: ProfileScreen). Menggunakan widget IndexedStack untuk menjaga keadaan (state preservation) setiap halaman agar posisi scroll dan form tidak hilang saat berpindah menu. Di bagian tengah BottomNavigationBar terdapat FloatingActionButton berikon tambah (+) yang membuka form penambahan sertifikat baru (AddEditCertificateScreen).")
    set_font(r_mt1, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/main_navigation_screen.dart", "IndexedStack dan BottomNavigationBar navigasi utama")

    p_mn2 = doc.add_paragraph()
    p_mn2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_mn2.paragraph_format.space_before = Pt(0)
    p_mn2.paragraph_format.space_after = Pt(6)
    p_mn2.paragraph_format.line_spacing = 1.5
    r_mf2 = p_mn2.add_run("home_screen.dart: ")
    set_font(r_mf2, 'Times New Roman', 12, bold=True)
    r_mt2 = p_mn2.add_run("Halaman dashboard utama yang menyapa pengguna dengan avatar dan nama profil. Menampilkan 4 kartu ringkasan portofolio interaktif (Total Sertifikat, Favorit, Kategori Aktif, Penyelenggara), banner jalan pintas ke menu 'Statistik & Timeline' dan 'Kelola Penyelenggara', serta seksi 'Sertifikat Terbaru' yang menampilkan 5 sertifikat terakhir menggunakan CertificateCard. Jika belum ada data, ditampilkan pesan kosong EmptyState dengan tombol pemicu tambah sertifikat.")
    set_font(r_mt2, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/home/home_screen.dart", "Dashboard ringkasan statistik dan sertifikat terbaru")

    # Langkah 14: screens/certificates
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 14. Folder screens/certificates")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/screens/certificates. Folder ini mengelola siklus hidup portofolio sertifikat, mulai dari katalog pencarian, pembuatan/pengeditan, hingga detail dokumen:")
    set_font(r_sub, 'Times New Roman', 12)

    p_cr1 = doc.add_paragraph()
    p_cr1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_cr1.paragraph_format.space_before = Pt(0)
    p_cr1.paragraph_format.space_after = Pt(6)
    p_cr1.paragraph_format.line_spacing = 1.5
    r_cf1 = p_cr1.add_run("certificates_screen.dart: ")
    set_font(r_cf1, 'Times New Roman', 12, bold=True)
    r_ct1 = p_cr1.add_run("Halaman katalog portofolio sertifikat lengkap. Dilengkapi bilah pencarian real-time pada judul, deskripsi, nomor sertifikat, dan nama penyelenggara. Memiliki toggle pengubah mode tampilan antara List View dan Grid View 2 kolom, tombol filter modal bawah (Filter Bottom Sheet) untuk memfilter berdasarkan kategori kegiatan, lembaga penyelenggara, dan tahun terbit, serta modal pengurutan (Terkini, Terlama, A-Z, Z-A). Jumlah filter aktif ditandai dengan badge merah interaktif.")
    set_font(r_ct1, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/certificates/certificates_screen.dart", "Katalog sertifikat, bilah pencarian, filter modal, dan toggle Grid/List")

    p_cr2 = doc.add_paragraph()
    p_cr2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_cr2.paragraph_format.space_before = Pt(0)
    p_cr2.paragraph_format.space_after = Pt(6)
    p_cr2.paragraph_format.line_spacing = 1.5
    r_cf2 = p_cr2.add_run("certificate_detail_screen.dart: ")
    set_font(r_cf2, 'Times New Roman', 12, bold=True)
    r_ct2 = p_cr2.add_run("Halaman rincian lengkap suatu sertifikat. Menampilkan pratinjau dokumen interaktif menggunakan DocumentPreviewWidget, chip kategori berkode warna, judul kegiatan, nama penyelenggara terafiliasi, tanggal terbit, nomor kredensial sertifikat, deskripsi kegiatan, serta informasi format dan ukuran berkas. Dari halaman ini, pengguna dapat membagikan berkas via ShareService, menandai/membatalkan status favorit, membuka form pengeditan (AddEditCertificateScreen), atau menghapus sertifikat yang diverifikasi melalui dialog konfirmasi DialogUtils.showConfirmDialog.")
    set_font(r_ct2, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/certificates/certificate_detail_screen.dart", "Detail sertifikat, penampil dokumen, aksi share, edit, dan hapus")

    p_cr3 = doc.add_paragraph()
    p_cr3.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_cr3.paragraph_format.space_before = Pt(0)
    p_cr3.paragraph_format.space_after = Pt(6)
    p_cr3.paragraph_format.line_spacing = 1.5
    r_cf3 = p_cr3.add_run("add_edit_certificate_screen.dart: ")
    set_font(r_cf3, 'Times New Roman', 12, bold=True)
    r_ct3 = p_cr3.add_run("Formulir dinamis terpadu untuk fungsi 'Tambah Sertifikat Baru' dan 'Edit Sertifikat'. Menyediakan area dropzone unggah dokumen modern berkontur awan untuk memilih berkas fisik dari memori perangkat atau template sertifikat digital (PDF/JPG/PNG). Kolom input mencakup judul sertifikat (wajib), kategori (dropdown 7 kategori), penyelenggara dengan dukungan pembuatan penyelenggara baru secara langsung (inline creation) tanpa keluar form, tanggal kegiatan (showDatePicker), nomor sertifikat (opsional), dan deskripsi kegiatan (opsional). Seluruh input divalidasi secara komprehensif.")
    set_font(r_ct3, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/certificates/add_edit_certificate_screen.dart", "Formulir input sertifikat, dropzone unggah berkas, dan validasi")

    # Langkah 15: screens/favorites & screens/organizers
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 15. Folder screens/favorites & screens/organizers")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/screens/favorites dan lib/screens/organizers. Folder ini menangani kurasi dokumen unggulan dan manajemen entitas penyelenggara:")
    set_font(r_sub, 'Times New Roman', 12)

    p_fo1 = doc.add_paragraph()
    p_fo1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_fo1.paragraph_format.space_before = Pt(0)
    p_fo1.paragraph_format.space_after = Pt(6)
    p_fo1.paragraph_format.line_spacing = 1.5
    r_ff1 = p_fo1.add_run("favorites_screen.dart: ")
    set_font(r_ff1, 'Times New Roman', 12, bold=True)
    r_ft1 = p_fo1.add_run("Halaman kurasi khusus untuk seluruh sertifikat yang telah ditandai sebagai favorit (isFavorite = true). Menyediakan kolom pencarian internal, tombol pengubah mode tampilan List/Grid, dan kartu sertifikat interaktif. Jika pengguna belum menandai sertifikat favorit atau hasil pencarian tidak cocok, halaman menampilkan tampilan kosong EmptyState bertema bintang dengan tombol 'Jelajahi Sertifikat' yang langsung mengarahkan ke katalog utama.")
    set_font(r_ft1, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/favorites/favorites_screen.dart", "Koleksi sertifikat favorit dan status kosong (empty state)")

    p_fo2 = doc.add_paragraph()
    p_fo2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_fo2.paragraph_format.space_before = Pt(0)
    p_fo2.paragraph_format.space_after = Pt(6)
    p_fo2.paragraph_format.line_spacing = 1.5
    r_ff2 = p_fo2.add_run("organizers_screen.dart: ")
    set_font(r_ff2, 'Times New Roman', 12, bold=True)
    r_ft2 = p_fo2.add_run("Halaman manajemen lembaga/organisasi penyelenggara sertifikat. Menampilkan daftar instansi beserta badge jumlah sertifikat yang berafiliasi dengan lembaga tersebut. Dilengkapi fitur pencarian nama institusi, tombol tambah penyelenggara baru, opsi ubah nama penyelenggara (rename), serta perlindungan integritas relasional (relational deletion safeguard)—apabila penyelenggara masih terhubung dengan minimal 1 sertifikat, sistem menolak penghapusan dan menampilkan pesan peringatan agar konsistensi data tetap terjaga.")
    set_font(r_ft2, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/organizers/organizers_screen.dart", "Daftar penyelenggara, rename, dan perlindungan relasi hapus")

    # Langkah 16: screens/statistics & screens/profile
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 16. Folder screens/statistics & screens/profile")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/screens/statistics dan lib/screens/profile. Folder ini menangani analitik visual portofolio dan profil pengguna:")
    set_font(r_sub, 'Times New Roman', 12)

    p_sp1 = doc.add_paragraph()
    p_sp1.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_sp1.paragraph_format.space_before = Pt(0)
    p_sp1.paragraph_format.space_after = Pt(6)
    p_sp1.paragraph_format.line_spacing = 1.5
    r_sf1 = p_sp1.add_run("statistics_timeline_screen.dart: ")
    set_font(r_sf1, 'Times New Roman', 12, bold=True)
    r_st1 = p_sp1.add_run("Halaman analitik portofolio yang disajikan dalam dua tab: Tab 'Statistik' menampilkan visualisasi grafik batang (bar chart kustom) perolehan sertifikat per tahun, distribusi persentase per kategori lengkap dengan progress bar warna-warni, dan daftar lembaga penerbit terbanyak. Tab 'Timeline' menyajikan linimasa pencapaian kronologis dari tahun ke tahun yang dihubungkan dengan garis vertikal dan node ikon elegan, memudahkan peninjauan jejak prestasi secara berurutan.")
    set_font(r_st1, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/statistics/statistics_timeline_screen.dart", "Visualisasi grafik batang analitik dan linimasa kronologis")

    p_sp2 = doc.add_paragraph()
    p_sp2.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_sp2.paragraph_format.space_before = Pt(0)
    p_sp2.paragraph_format.space_after = Pt(6)
    p_sp2.paragraph_format.line_spacing = 1.5
    r_sf2 = p_sp2.add_run("profile_screen.dart: ")
    set_font(r_sf2, 'Times New Roman', 12, bold=True)
    r_st2 = p_sp2.add_run("Halaman profil pengguna yang menyajikan kartu identitas mahasiswa (nama, email, NIM, institusi, dan foto avatar), jalan pintas ke kelola penyelenggara dan statistik, menu opsi sistem 'Pulihkan Katalog Standar' untuk memulihkan seluruh sertifikat dan penyelenggara bawaan dengan konfirmasi aman, dialog 'Tentang Aplikasi' yang menampilkan informasi versi rilis 1.0.0 resmi dan format dokumen yang didukung, serta tombol 'Keluar dari Akun' dengan dialog konfirmasi keamanan.")
    set_font(r_st2, 'Times New Roman', 12)
    add_placeholder_box("lib/screens/profile/profile_screen.dart", "Halaman profil pengguna, pulihkan katalog, dan informasi aplikasi")

    # Langkah 17: Folder widgets
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 17. Folder widgets")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(4)
    r_sub = p_sub.add_run("Buka folder lib/widgets. Folder ini berisi komponen-komponen UI modular yang dapat digunakan kembali (reusable components) di berbagai halaman aplikasi:")
    set_font(r_sub, 'Times New Roman', 12)

    widgets_desc = [
        ("certificate_card.dart: ", "Komponen kartu sertifikat serbaguna yang mendukung dua mode rendering: List View (thumbnail persegi horizontal dengan judul, chip kategori, nama penyelenggara, tanggal, dan tombol favorit) serta Grid View 2 kolom (gambar sampul vertikal rasio 4:3, overlay badge kategori, judul terpotong elegan, dan footer tanggal). Kartu ini memiliki interaksi sentuh halus yang langsung membuka halaman detail sertifikat.", "lib/widgets/certificate_card.dart"),
        ("category_chip.dart: ", "Komponen chip kategori interaktif (tappable) dengan warna dinamis sesuai kategori yang dipilih. Mendukung status aktif (latar warna aksen pekat dan teks putih) dan non-aktif (latar abu-abu muda transparan).", "lib/widgets/category_chip.dart"),
        ("stat_card.dart: ", "Komponen kartu metrik statistik beranda yang menampilkan ikon bertema dalam wadah lingkaran, angka nilai metrik (misal: jumlah sertifikat), label judul, dan border rounded 16px yang bersih.", "lib/widgets/stat_card.dart"),
        ("empty_state.dart: ", "Komponen status kosong yang seragam, menampilkan ilustrasi ikon membulat lembut, judul pesan utama, deskripsi informatif, serta tombol aksi opsional untuk memicu tindakan pengguna (misal: reset filter atau tambah sertifikat).", "lib/widgets/empty_state.dart"),
        ("document_preview_widget.dart: ", "Komponen pratinjau dokumen berkemampuan ganda yang cerdas: mampu merender dokumen gambar (JPG, PNG) dengan InteractiveViewer untuk zoom/pinch, serta merender dokumen PDF dengan kartu dokumen resmi bertema merah, tombol bagikan berkas (share), dan tombol buka dokumen di aplikasi eksternal (open_filex).", "lib/widgets/document_preview_widget.dart")
    ]
    for w_name, w_txt, w_label in widgets_desc:
        pw = doc.add_paragraph()
        pw.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        pw.paragraph_format.space_before = Pt(0)
        pw.paragraph_format.space_after = Pt(6)
        pw.paragraph_format.line_spacing = 1.5
        r_wn = pw.add_run(w_name)
        set_font(r_wn, 'Times New Roman', 12, bold=True)
        r_wt = pw.add_run(w_txt)
        set_font(r_wt, 'Times New Roman', 12)
        add_placeholder_box(w_label, f"Komponen widget {w_label.split('/')[-1]}")

    # Langkah 18: File main.dart
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 18. File main.dart")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_m = doc.add_paragraph()
    p_m.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_m.paragraph_format.space_before = Pt(0)
    p_m.paragraph_format.space_after = Pt(6)
    p_m.paragraph_format.line_spacing = 1.5
    r_mt = p_m.add_run("Terakhir, buka lib/main.dart, berkas titik masuk (entry point) eksekusi aplikasi Certify. Fungsi main() menginisialisasi WidgetsFlutterBinding.ensureInitialized(), mengatur SystemChrome.setSystemUIOverlayStyle agar bilah status (status bar) transparan dengan ikon gelap yang bersih, lalu menjalankan CertifyApp. CertifyApp membungkus MaterialApp dengan MultiProvider di puncak pohon widget untuk mendaftarkan AuthProvider, OrganizerProvider, dan CertificateProvider secara global. Proyek dikonfigurasi dengan tema AppTheme.lightTheme, menonaktifkan banner debug (debugShowCheckedModeBanner: false), dan menetapkan SplashScreen sebagai halaman rute awal (initial route).")
    set_font(r_mt, 'Times New Roman', 12)
    add_placeholder_box("lib/main.dart", "Titik masuk aplikasi, konfigurasi MultiProvider, dan MaterialApp")

    # Langkah 19: Validasi flutter test
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run("Langkah 19. Pengujian Unit & Validasi Aplikasi (flutter test)")
    set_font(r, 'Times New Roman', 12, bold=True)

    p_t = doc.add_paragraph()
    p_t.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_t.paragraph_format.space_before = Pt(0)
    p_t.paragraph_format.space_after = Pt(6)
    p_t.paragraph_format.line_spacing = 1.5
    r_tt = p_t.add_run("Untuk memastikan integritas logika data dan mencegah adanya regresi, pengujian otomatis dijalankan melalui perintah flutter test --no-pub. Seluruh pengujian unit pada test/widget_test.dart yang mencakup serialisasi model Organizer dan Certificate, fungsionalitas penanda favorit, pemformatan tanggal bahasa Indonesia pada DateFormatter, deteksi ekstensi berkas dan konversi ukuran byte pada FileUtils, serta verifikasi pemenuhan 7 kategori standar pada AppConstants berhasil lulus 100% tanpa ada kesalahan (All tests passed!).")
    set_font(r_tt, 'Times New Roman', 12)
    add_placeholder_box("Hasil Pengujian Unit di Terminal (flutter test --no-pub)", "Terminal menampilkan pesan 'All tests passed!' dengan seluruh skenario sukses")

    # ==========================================
    # SECTION 2 & 3: LINK VIDEO & GITHUB
    # ==========================================
    add_p("", space_after=12)

    p_v = doc.add_paragraph()
    p_v.paragraph_format.space_before = Pt(12)
    p_v.paragraph_format.space_after = Pt(4)
    r_v = p_v.add_run("2. Link Video")
    set_font(r_v, 'Times New Roman', 14, bold=True)

    p_vdesc = doc.add_paragraph()
    p_vdesc.paragraph_format.space_before = Pt(0)
    p_vdesc.paragraph_format.space_after = Pt(6)
    p_vdesc.paragraph_format.line_spacing = 1.5
    r_vdesc = p_vdesc.add_run("Tautan video demonstrasi aplikasi Certify (YouTube / Google Drive):\nhttps://...")
    set_font(r_vdesc, 'Times New Roman', 12)

    p_g = doc.add_paragraph()
    p_g.paragraph_format.space_before = Pt(12)
    p_g.paragraph_format.space_after = Pt(4)
    r_g = p_g.add_run("3. Link Github")
    set_font(r_g, 'Times New Roman', 14, bold=True)

    p_gdesc = doc.add_paragraph()
    p_gdesc.paragraph_format.space_before = Pt(0)
    p_gdesc.paragraph_format.space_after = Pt(6)
    p_gdesc.paragraph_format.line_spacing = 1.5
    r_gdesc = p_gdesc.add_run("Tautan repositori kode sumber proyek aplikasi Certify di GitHub:\nhttps://github.com/...")
    set_font(r_gdesc, 'Times New Roman', 12)

    doc.save(output_path)
    print(f"Report successfully saved to {output_path}")

if __name__ == '__main__':
    dest1 = r'c:\Users\rafis\Downloads\ATS_PRAKTIKUM_PPB_4342501034_Naufal Rafi Siregar.docx'
    dest2 = r'ATS_PRAKTIKUM_PPB_4342501034_Naufal Rafi Siregar.docx'
    create_report(dest1)
    create_report(dest2)
