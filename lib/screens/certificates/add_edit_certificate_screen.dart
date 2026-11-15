import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/dialog_utils.dart';
import '../../core/utils/file_utils.dart';
import '../../models/certificate.dart';
import '../../models/organizer.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/organizer_provider.dart';
import '../../services/file_picker_service.dart';

class AddEditCertificateScreen extends StatefulWidget {
  final Certificate? existingCertificate;

  const AddEditCertificateScreen({super.key, this.existingCertificate});

  @override
  State<AddEditCertificateScreen> createState() => _AddEditCertificateScreenState();
}

class _AddEditCertificateScreenState extends State<AddEditCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _titleController;
  late TextEditingController _certNumberController;
  late TextEditingController _descController;

  String? _selectedCategory;
  String? _selectedOrganizerId;
  DateTime _selectedDate = DateTime.now();

  String? _pickedFilePath;
  String? _pickedFileName;
  String _pickedFileType = 'image';
  int _pickedFileSize = 0;

  bool _isSaving = false;
  bool get _isEditing => widget.existingCertificate != null;

  @override
  void initState() {
    super.initState();
    final cert = widget.existingCertificate;
    _titleController = TextEditingController(text: cert?.title ?? '');
    _certNumberController = TextEditingController(text: cert?.certificateNumber ?? '');
    _descController = TextEditingController(text: cert?.description ?? '');

    if (cert != null) {
      _selectedCategory = cert.category;
      _selectedOrganizerId = cert.organizerId;
      _selectedDate = cert.issueDate;
      _pickedFilePath = cert.filePath;
      _pickedFileType = cert.fileType;
      _pickedFileName = cert.filePath.split('/').last.split('\\').last;
    } else {
      _selectedCategory = AppConstants.categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _certNumberController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // File picker with natural source options
  Future<void> _pickFileOption() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Pilih Sumber Dokumen',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_open_rounded, color: AppColors.primary, size: 22),
                ),
                title: const Text('Penyimpanan Perangkat'),
                subtitle: const Text('Pilih berkas PDF atau gambar dari memori internal'),
                onTap: () => Navigator.pop(ctx, 'device'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.collections_bookmark_outlined, color: Color(0xFF3182CE), size: 22),
                ),
                title: const Text('Koleksi Template Sertifikat'),
                subtitle: const Text('Gunakan berkas template sertifikat digital'),
                onTap: () => Navigator.pop(ctx, 'template'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == 'device') {
      await _pickFileFromDevice();
    } else if (choice == 'template') {
      await _pickSamplePreset();
    }
  }

  // Pick file from device
  Future<void> _pickFileFromDevice() async {
    try {
      final result = await FilePickerService.pickDocument();
      if (result != null) {
        setState(() {
          _pickedFilePath = result.filePath;
          _pickedFileName = result.fileName;
          _pickedFileType = result.fileType;
          _pickedFileSize = result.fileSizeBytes;
        });
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showSnackBar(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  // Template certificate picker
  Future<void> _pickSamplePreset() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Pilih Template Sertifikat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Dokumen Sertifikat Kursus / Workshop'),
                subtitle: const Text('Format: PDF Resmi'),
                onTap: () => Navigator.pop(ctx, 'pdf_flutter'),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Dokumen Sertifikat Prestasi Kompetisi'),
                subtitle: const Text('Format: JPG Resolusi Tinggi'),
                onTap: () => Navigator.pop(ctx, 'jpg_competition'),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.orange),
                title: const Text('Dokumen Sertifikat Partisipasi Webinar'),
                subtitle: const Text('Format: PNG'),
                onTap: () => Navigator.pop(ctx, 'png_uiux'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null) return;

    try {
      PickedDocumentResult result;
      if (choice == 'pdf_flutter') {
        result = await FilePickerService.pickSamplePreset('flutter_workshop', 'pdf');
      } else if (choice == 'jpg_competition') {
        result = await FilePickerService.pickSamplePreset('national_programming_competition', 'jpg');
      } else {
        result = await FilePickerService.pickSamplePreset('uiux_design_webinar', 'png');
      }

      setState(() {
        _pickedFilePath = result.filePath;
        _pickedFileName = result.fileName;
        _pickedFileType = result.fileType;
        _pickedFileSize = result.fileSizeBytes;
      });
    } catch (e) {
      if (mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Gagal memuat template: $e',
          isError: true,
        );
      }
    }
  }

  // Date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Inline Add New Organizer Dialog
  Future<void> _showAddNewOrganizerDialog() async {
    final textCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<Organizer?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Penyelenggara Baru'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama Penyelenggara / Institusi',
              hintText: 'Contoh: Google Cloud, Polibatam, dll.',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Nama penyelenggara tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final orgProvider = context.read<OrganizerProvider>();
                final newOrg = await orgProvider.addOrganizer(textCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx, newOrg);
              } catch (e) {
                if (ctx.mounted) {
                  DialogUtils.showSnackBar(
                    ctx,
                    message: e.toString().replaceAll('Exception: ', ''),
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (created != null) {
      setState(() {
        _selectedOrganizerId = created.id;
      });
      if (mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Penyelenggara "${created.name}" berhasil dipilih!',
          isSuccess: true,
        );
      }
    }
  }

  // Save certificate
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrganizerId == null || _selectedOrganizerId!.isEmpty) {
      DialogUtils.showSnackBar(
        context,
        message: 'Harap pilih penyelenggara sertifikat',
        isError: true,
      );
      return;
    }

    if (_pickedFilePath == null || _pickedFilePath!.isEmpty) {
      DialogUtils.showSnackBar(
        context,
        message: 'Harap pilih file sertifikat (JPG, PNG, atau PDF)',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final certProvider = context.read<CertificateProvider>();

      if (_isEditing) {
        final existing = widget.existingCertificate!;
        final updated = existing.copyWith(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          organizerId: _selectedOrganizerId,
          issueDate: _selectedDate,
          filePath: _pickedFilePath,
          fileType: _pickedFileType,
          certificateNumber: _certNumberController.text.trim().isEmpty ? null : _certNumberController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        );
        await certProvider.updateCertificate(updated);

        if (!mounted) return;
        DialogUtils.showSnackBar(
          context,
          message: 'Sertifikat berhasil diperbarui!',
          isSuccess: true,
        );
        Navigator.pop(context, updated);
      } else {
        final newCert = Certificate(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          category: _selectedCategory ?? AppConstants.categories.first,
          organizerId: _selectedOrganizerId!,
          issueDate: _selectedDate,
          filePath: _pickedFilePath!,
          fileType: _pickedFileType,
          certificateNumber: _certNumberController.text.trim().isEmpty ? null : _certNumberController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          isFavorite: false,
        );
        await certProvider.addCertificate(newCert);

        if (!mounted) return;
        DialogUtils.showSnackBar(
          context,
          message: 'Sertifikat berhasil ditambahkan ke portofolio!',
          isSuccess: true,
        );
        Navigator.pop(context, newCert);
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showSnackBar(
          context,
          message: 'Gagal menyimpan sertifikat: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = context.watch<OrganizerProvider>();
    final organizers = orgProvider.organizers;

    // Check if current selected organizer is still in list
    final hasValidSelectedOrg = organizers.any((o) => o.id == _selectedOrganizerId);
    if (!hasValidSelectedOrg && organizers.isNotEmpty && _selectedOrganizerId == null) {
      _selectedOrganizerId = organizers.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Ubah Sertifikat' : 'Tambah Sertifikat Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. File Upload Card (Section 5)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.attachment_rounded, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Berkas Dokumen Sertifikat *',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Format yang didukung: JPG, PNG, atau PDF (Maks. 10 MB)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),

                      // Preview if file chosen
                      if (_pickedFilePath == null)
                        InkWell(
                          onTap: _pickFileOption,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 30,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Ketuk untuk Memilih Berkas Dokumen',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Mendukung PDF, PNG, atau JPG (Maksimal 10 MB)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _pickedFileType == 'pdf'
                                      ? const Color(0xFFFFECEC)
                                      : const Color(0xFFECEFFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _pickedFileType == 'pdf'
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.image_rounded,
                                  color: _pickedFileType == 'pdf'
                                      ? AppColors.danger
                                      : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _pickedFileName ?? 'Dokumen Terpilih',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_pickedFileType.toUpperCase()} • ${_pickedFileSize > 0 ? FileUtils.formatBytes(_pickedFileSize) : "Tersimpan"}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                color: AppColors.danger,
                                onPressed: () {
                                  setState(() {
                                    _pickedFilePath = null;
                                    _pickedFileName = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickFileOption,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Ganti Berkas Dokumen'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Main Metadata Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Certificate Title
                      const Text(
                        'Nama / Judul Sertifikat *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Flutter Development Workshop',
                          prefixIcon: Icon(Icons.title_rounded, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Judul sertifikat wajib diisi';
                          }
                          if (val.trim().length < 3) {
                            return 'Judul sertifikat minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      const Text(
                        'Kategori *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                        ),
                        items: AppConstants.categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Organizer Dropdown + Inline Add Button (PDF Section 5 & 6)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Penyelenggara (Organizer) *',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: _showAddNewOrganizerDialog,
                            child: Row(
                              children: const [
                                Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Tambah Baru',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedOrganizerId,
                        decoration: const InputDecoration(
                          hintText: 'Pilih penyelenggara',
                          prefixIcon: Icon(Icons.apartment_rounded, size: 20),
                        ),
                        items: organizers.map((org) {
                          return DropdownMenuItem(value: org.id, child: Text(org.name));
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedOrganizerId = val);
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Harap pilih penyelenggara';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Issue Date Picker
                      const Text(
                        'Tanggal Penerbitan *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                            suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                          ),
                          child: Text(
                            DateFormatter.formatFull(_selectedDate),
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Certificate Number (Optional)
                      const Text(
                        'Nomor / Kredensial Sertifikat (Opsional)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _certNumberController,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: CERT-2026-XYZ-019',
                          prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description (Optional)
                      const Text(
                        'Deskripsi / Catatan (Opsional)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Catatan tambahan terkait pelatihan atau kompetisi...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Sertifikat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
