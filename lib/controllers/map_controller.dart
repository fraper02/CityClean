import 'dart:io';
import 'package:cityclean/models/partner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_report_model.dart';
import '../models/eco_point_model.dart';
import '../services/report_service.dart';
import '../services/recycling_service.dart';
import '../services/storage_service.dart';

class MapController extends ChangeNotifier {
  // --- SERVIZI ---
  final ReportService _reportService = ReportService();
  final RecyclingService _recyclingService = RecyclingService();

  // --- STATO ---
  LatLng _currentCenter = const LatLng(40.6795, 14.7645);
  bool _isLocationLoaded = false;
  bool _isLoading = false;

  List<MapReportModel> _reports = [];
  List<Ecopoint> _ecoPoints = [];
  List<Partner> _partners = [];

  // --- GETTERS ---
  LatLng get currentCenter => _currentCenter;
  bool get isLocationLoaded => _isLocationLoaded;
  bool get isLoading => _isLoading;
  List<MapReportModel> get reports => _reports;
  List<Ecopoint> get ecoPoints => _ecoPoints;
  List<Partner> get partners => _partners;

  // --- INIZIALIZZAZIONE ---
  Future<void> initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { await loadData(); return; }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) { await loadData(); return; }
    }
    if (permission == LocationPermission.deniedForever) { await loadData(); return; }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).timeout(const Duration(seconds: 10));
      _currentCenter = LatLng(position.latitude, position.longitude);
      _isLocationLoaded = true;
      notifyListeners();
      await loadData();
    } catch (e) {
      debugPrint("Errore GPS: $e");
      await loadData();
    }
  }

  // --- CARICAMENTO DATI ---
  Future<void> loadData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint("Controller: Caricamento dati completi...");

      // Tipizziamo Future.wait per evitare cast inutili dopo
      final results = await Future.wait<List<Map<String, dynamic>>>([
        _reportService.getReports(),      // index 0
        _recyclingService.getEcoPoints(), // index 1
        _recyclingService.getPartners(),  // index 2
      ]);

      // 1. REPORT (results[0] è già List<Map<String, dynamic>>)
      _reports = results[0]
          .map((data) => MapReportModel.fromMap(data))
          .where((report) => report.isAccepted == true)
          .toList();

      // 2. ECOPOINTS
      _ecoPoints = results[1]
          .map((data) => Ecopoint.fromJson(data))
          .toList();

      // 3. PARTNERS
      _partners = results[2]
          .map((data) => Partner.fromMap(data))
          .where((p) => p.latitudine != null && p.longitudine != null)
          .toList();

      debugPrint("Dati caricati: ${_reports.length} report, ${_ecoPoints.length} eco points, ${_partners.length} partner.");

    } catch (e) {
      debugPrint("Controller Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReports() => loadData();

  // --- INVIO REPORT ---
  Future<bool> submitReport({required String description, required String pollutionLevel, required LatLng location, File? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) throw Exception("Utente non loggato");

      String? imageId;
      if (imageFile != null) imageId = await _reportService.uploadImageAndGetId(imageFile);

      await _reportService.createReport(
        description: description, wasteType: "Rapida", pollutionLevel: pollutionLevel,
        latitude: location.latitude, longitude: location.longitude, userId: userId, imageId: imageId,
      );

      await loadData();
      return true;
    } catch (e) {
      debugPrint("Errore invio: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}