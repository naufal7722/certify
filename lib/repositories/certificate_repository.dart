import '../models/certificate.dart';
import '../services/storage_service.dart';

class CertificateRepository {
  Future<List<Certificate>> getCertificates() async {
    return await StorageService.loadCertificates();
  }

  Future<void> saveCertificates(List<Certificate> certificates) async {
    await StorageService.saveCertificates(certificates);
  }
}
