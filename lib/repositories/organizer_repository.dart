import '../models/organizer.dart';
import '../services/storage_service.dart';

class OrganizerRepository {
  Future<List<Organizer>> getOrganizers() async {
    return await StorageService.loadOrganizers();
  }

  Future<void> saveOrganizers(List<Organizer> organizers) async {
    await StorageService.saveOrganizers(organizers);
  }
}
