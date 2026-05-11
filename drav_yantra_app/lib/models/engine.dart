import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Organization {
  final String name;
  final String gstin;
  final String pan;
  final String city;
  final String state;
  final String contact;

  Organization({required this.name, required this.gstin, required this.pan, required this.city, required this.state, required this.contact});
}

class UserAccount {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String timezone;

  UserAccount({required this.name, required this.email, required this.phone, required this.role, required this.timezone});
}

class AlertSettings {
  final int speedThreshold;
  final int idleLimit;
  final double fuelDropThreshold;
  final int fastagThreshold;
  final bool whatsappEnabled;
  final bool smsEnabled;
  final bool pushEnabled;

  AlertSettings({
    required this.speedThreshold, required this.idleLimit, required this.fuelDropThreshold, 
    required this.fastagThreshold, required this.whatsappEnabled, required this.smsEnabled, required this.pushEnabled
  });
}

class FuelLog {
  final String id;
  final String vehicle;
  final String driver;
  final String station;
  final double liters;
  final double rate;
  final double cost;
  final int odometer;
  final String date;
  final bool isSuspect;
  final String? suspectReason;

  FuelLog({
    required this.id, required this.vehicle, required this.driver, required this.station, 
    required this.liters, required this.rate, required this.cost, required this.odometer, 
    required this.date, this.isSuspect = false, this.suspectReason
  });
}

// Trip model is defined below with more comprehensive fields.

class ServiceRecord {
  final String date;
  final String type;
  final String notes;
  ServiceRecord({required this.date, required this.type, required this.notes});
}

enum AlertStatus { pending, acknowledged, dismissed }
enum AlertCategory { safety, fuel, compliance, connectivity }

class Trip {
  final String id;
  final String vehicle;
  final String driver;
  final String from;
  final String to;
  final String load;
  final String client;
  final String status; // pending, running, completed, cancelled
  final String ewayBill;
  final String date;
  final double progress; // 0.0 to 1.0
  final double distance;
  final double fuelUsed;
  final double score;

  Trip({
    required this.id, 
    required this.vehicle, 
    required this.driver, 
    required this.from, 
    required this.to, 
    required this.load, 
    required this.client, 
    required this.status, 
    required this.ewayBill, 
    required this.date, 
    required this.progress,
    this.distance = 0.0,
    this.fuelUsed = 0.0,
    this.score = 0.0,
  });

  Trip copyWith({String? status, double? progress, double? distance, double? fuelUsed, double? score}) {
    return Trip(
      id: id, vehicle: vehicle, driver: driver, from: from, to: to, 
      load: load, client: client, status: status ?? this.status, 
      ewayBill: ewayBill, date: date, progress: progress ?? this.progress,
      distance: distance ?? this.distance,
      fuelUsed: fuelUsed ?? this.fuelUsed,
      score: score ?? this.score,
    );
  }
}

class Alert {
  final String id;
  final String truck;
  final String msg;
  final String time;
  final String sev;
  final AlertCategory category;
  final AlertStatus status;

  Alert({
    required this.id, required this.truck, required this.msg, required this.time, 
    required this.sev, required this.category, this.status = AlertStatus.pending
  });

  Alert copyWith({AlertStatus? status}) {
    return Alert(
      id: id, truck: truck, msg: msg, time: time, sev: sev, 
      category: category, status: status ?? this.status
    );
  }
}

class Vehicle {
  final String plate;
  final String model;
  final int year;
  final String type;
  final String status;
  final String driver;
  final String loc;
  final int speed;
  final double fuel;
  final double mil;
  final double idle;
  final int fastag;
  final int health;
  final int odo;
  final String nextService;
  final String insurance;
  final String permit;
  final String puc;
  final String lastFill;
  final List<String> alerts;
  final double lat;
  final double lng;
  final List<List<double>> route; // List of [lat, lng] pairs
  final bool isActive;
  final List<ServiceRecord> serviceHistory;

  Vehicle({
    required this.plate, required this.model, required this.year, required this.type, required this.status, required this.driver,
    required this.loc, required this.speed, required this.fuel, required this.mil, required this.idle, required this.fastag,
    required this.health, required this.odo, required this.nextService, required this.insurance, required this.permit,
    required this.puc, required this.lastFill, required this.alerts,
    required this.lat, required this.lng, this.route = const [],
    this.isActive = true,
    this.serviceHistory = const [],
  });

  Vehicle copyWith({int? speed, double? fuel, double? idle, int? fastag, double? lat, double? lng, List<List<double>>? route, bool? isActive, List<ServiceRecord>? serviceHistory}) {
    return Vehicle(
      plate: plate, model: model, year: year, type: type, status: status, driver: driver,
      loc: loc, speed: speed ?? this.speed, fuel: fuel ?? this.fuel, mil: mil,
      idle: idle ?? this.idle, fastag: fastag ?? this.fastag, health: health, odo: odo,
      nextService: nextService, insurance: insurance, permit: permit, puc: puc, lastFill: lastFill, alerts: alerts,
      lat: lat ?? this.lat, lng: lng ?? this.lng, route: route ?? this.route,
      isActive: isActive ?? this.isActive,
      serviceHistory: serviceHistory ?? this.serviceHistory,
    );
  }
}

class Driver {
  final String id;
  final String name;
  final String phone;
  final int age;
  final int exp;
  final String lic;
  final String licExp;
  final String blood;
  final String vehicle;
  final String status;
  final int score;
  final double mil;
  final double idle;
  final int trips;
  final int harsh;
  final int overSpeed;
  final int deviation;
  final int fuelEff;
  final double rating;
  final String home;
  final bool onLeave;
  final bool isActive;
  final List<Trip> tripHistory;

  Driver({
    required this.id, required this.name, required this.phone, required this.age, required this.exp, required this.lic,
    required this.licExp, required this.blood, required this.vehicle, required this.status, required this.score,
    required this.mil, required this.idle, required this.trips, required this.harsh, required this.overSpeed,
    required this.deviation, required this.fuelEff, required this.rating, required this.home, required this.onLeave,
    this.isActive = true,
    this.tripHistory = const [],
  });

  Driver copyWith({int? score, double? idle, double? mil, bool? isActive, List<Trip>? tripHistory}) {
    return Driver(
      id: id, name: name, phone: phone, age: age, exp: exp, lic: lic, licExp: licExp, blood: blood,
      vehicle: vehicle, status: status, score: score ?? this.score, mil: mil ?? this.mil, idle: idle ?? this.idle,
      trips: trips, harsh: harsh, overSpeed: overSpeed, deviation: deviation, fuelEff: fuelEff, rating: rating,
      home: home, onLeave: onLeave,
      isActive: isActive ?? this.isActive,
      tripHistory: tripHistory ?? this.tripHistory,
    );
  }
}

class FuelTrend {
  final String d;
  final double used;
  final double loss;

  FuelTrend({required this.d, required this.used, required this.loss});
}

class DataEngine extends ChangeNotifier {
  int spend = 2468420;
  int loss = 172000;
  int savings = 114000;
  double avgMil = 4.81;
  double idle = 18.2;
  int health = 72;
  int active = 28;
  int tripsToday = 14;

  Vehicle? _selectedVehicle;
  Vehicle? get selectedVehicle => _selectedVehicle;

  void selectVehicle(Vehicle? v) {
    _selectedVehicle = v;
    notifyListeners();
  }

  void addVehicle(Vehicle v) {
    vehicles = [...vehicles, v];
    notifyListeners();
  }

  void updateVehicle(Vehicle v) {
    vehicles = vehicles.map((existing) => existing.plate == v.plate ? v : existing).toList();
    if (_selectedVehicle?.plate == v.plate) _selectedVehicle = v;
    notifyListeners();
  }

  void deactivateVehicle(String plate) {
    vehicles = vehicles.map((v) => v.plate == plate ? v.copyWith(isActive: false) : v).toList();
    notifyListeners();
  }

  void addDriver(Driver d) {
    drivers = [...drivers, d];
    notifyListeners();
  }

  void updateDriver(Driver d) {
    drivers = drivers.map((existing) => existing.id == d.id ? d : existing).toList();
    notifyListeners();
  }

  void deactivateDriver(String id) {
    drivers = drivers.map((d) => d.id == id ? d.copyWith(isActive: false) : d).toList();
    notifyListeners();
  }

  void assignVehicle(String driverId, String vehiclePlate) {
    drivers = drivers.map((d) => d.id == driverId ? d : (d.vehicle == vehiclePlate ? d.copyWith() : d)).toList(); // Simplified unassign
    // In a real app we'd update both Driver and Vehicle
    notifyListeners();
  }

  List<FuelLog> fuelLogs = [
    FuelLog(id: 'FL-101', vehicle: 'MH 14 CX 5543', driver: 'Ramesh Kumar', station: 'HPCL, Pune', liters: 120, rate: 94.2, cost: 11304, odometer: 48200, date: '2026-04-09', isSuspect: false),
    FuelLog(id: 'FL-102', vehicle: 'DL 1G BC 8891', driver: 'Gurpreet Singh', station: 'BPCL, Gurgaon', liters: 85, rate: 91.5, cost: 7777.5, odometer: 93000, date: '2026-04-09', isSuspect: false),
    FuelLog(id: 'FL-103', vehicle: 'GJ 12 EZ 9012', driver: 'Abdul Ansari', station: 'Reliance, Gandhidham', liters: 450, rate: 89.8, cost: 40410, odometer: 29300, date: '2026-04-08', isSuspect: true, suspectReason: 'Liters exceed tank capacity (400L)'),
  ];

  Map<String, double> cityRates = {
    'Mumbai': 94.27, 'Delhi': 87.62, 'Bangalore': 87.89, 'Chennai': 92.76, 'Hyderabad': 97.82, 'Pune': 92.51,
  };

  List<Alert> alerts = [
    Alert(id: 'ALT-101', truck: 'MH 43 BP 2114', msg: 'Over-speed: 91 km/h', time: '10 mins ago', sev: 'danger', category: AlertCategory.safety),
    Alert(id: 'ALT-102', truck: 'GJ 12 EZ 9012', msg: 'Low FASTag balance: ₹340', time: '1 hour ago', sev: 'warning', category: AlertCategory.compliance),
    Alert(id: 'ALT-103', truck: 'MH 14 CX 5543', msg: 'Fuel drop detected (3L)', time: '2 hours ago', sev: 'danger', category: AlertCategory.fuel),
  ];

  void addFuelLog(FuelLog log) {
    fuelLogs = [log, ...fuelLogs];
    notifyListeners();
  }

  void acknowledgeAlert(String id) {
    alerts = alerts.map((a) => a.id == id ? a.copyWith(status: AlertStatus.acknowledged) : a).toList();
    notifyListeners();
  }

  void dismissAllAlerts() {
    alerts = alerts.map((a) => a.copyWith(status: AlertStatus.dismissed)).toList();
    notifyListeners();
  }

  void _checkAlerts(Vehicle v) {
    if (v.speed > 80) {
      _triggerAlert(v.plate, 'Over-speed detected: ${v.speed.toInt()} km/h', 'danger', AlertCategory.safety);
    }
    if (v.speed == 0 && Random().nextDouble() < 0.01) {
      _triggerAlert(v.plate, 'Excessive idling (over 15 mins)', 'warning', AlertCategory.fuel);
    }
  }

  void _triggerAlert(String truck, String msg, String sev, AlertCategory category) {
    final id = 'ALT-${Random().nextInt(10000)}';
    if (!alerts.any((a) => a.truck == truck && a.msg == msg && a.status == AlertStatus.pending)) {
      alerts = [Alert(id: id, truck: truck, msg: msg, time: 'Now', sev: sev, category: category), ...alerts];
    }
  }

  List<FuelTrend> fuelTrend = [
    FuelTrend(d: '01 Apr', used: 42000, loss: 3100), FuelTrend(d: '03 Apr', used: 38000, loss: 2800),
    FuelTrend(d: '05 Apr', used: 51000, loss: 3600), FuelTrend(d: '07 Apr', used: 44000, loss: 3200),
    FuelTrend(d: '09 Apr', used: 49000, loss: 3500), FuelTrend(d: '11 Apr', used: 37000, loss: 2700),
    FuelTrend(d: '13 Apr', used: 53000, loss: 3800), FuelTrend(d: '15 Apr', used: 46000, loss: 3300),
  ];

  List<Trip> trips = [
    Trip(id: 'TRP-4402', vehicle: 'MH 14 CX 5543', driver: 'Ramesh Kumar', from: 'Pune, MH', to: 'Bangalore, KA', load: 'Industrial Gears (22T)', client: 'Tata Steel', status: 'running', ewayBill: '271288349012', date: '12 Apr 2026', progress: 0.65),
    Trip(id: 'TRP-4401', vehicle: 'DL 1G BC 8891', driver: 'Gurpreet Singh', from: 'Delhi, DL', to: 'Jaipur, RJ', load: 'Textiles (15T)', client: 'Reliance Retail', status: 'completed', ewayBill: '110299384756', date: '11 Apr 2026', progress: 1.0),
    Trip(id: 'TRP-4400', vehicle: 'GJ 12 EZ 9012', driver: 'Abdul Ansari', from: 'Mundra, GJ', to: 'Indore, MP', load: 'Solar Panels (18T)', client: 'Adani Renewables', status: 'pending', ewayBill: '241099283745', date: '13 Apr 2026', progress: 0.0),
  ];

  void addTrip(Trip trip) {
    trips = [trip, ...trips];
    notifyListeners();
  }

  void updateTripStatus(String id, String status, {double? progress}) {
    trips = trips.map((t) => t.id == id ? t.copyWith(status: status, progress: progress) : t).toList();
    notifyListeners();
  }

  Organization org = Organization(
    name: 'DravYantra Logistics Pvt Ltd',
    gstin: '27AAAAA0000A1Z5',
    pan: 'AAAAA0000A',
    city: 'Pune',
    state: 'Maharashtra',
    contact: '+91 20 2740 1234'
  );
  UserAccount user = UserAccount(name: 'Admin User', email: 'admin@drav_yantra.in', phone: '+91 98765 43210', role: 'Fleet Manager', timezone: 'IST (UTC+5:30)');
  AlertSettings alertSettings = AlertSettings(speedThreshold: 80, idleLimit: 15, fuelDropThreshold: 5.0, fastagThreshold: 500, whatsappEnabled: true, smsEnabled: false, pushEnabled: true);

  bool isLoggedIn = true;

  void updateOrg(Organization newOrg) {
    org = newOrg;
    notifyListeners();
  }

  void updateAccount(UserAccount newAccount) {
    user = newAccount;
    notifyListeners();
  }

  void updateAlertSettings(AlertSettings newSettings) {
    alertSettings = newSettings;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }

  List<Vehicle> vehicles = [
    Vehicle(plate: 'MH 14 CX 5543', model: 'Tata Prima 5530', year: 2022, type: 'HCV', status: 'running', driver: 'Ramesh Kumar', loc: 'NH-48, Khopoli', speed: 64, fuel: 68, mil: 4.1, idle: 25, fastag: 1450, health: 58, odo: 48320, nextService: '2026-04-18', insurance: '2026-08-12', permit: '2026-12-31', puc: '2026-07-01', lastFill: '09 Apr', alerts: ['Fuel Drop (3L)', 'FASTag Low'], lat: 18.7893, lng: 73.3417, route: [[18.5204, 73.8567], [18.7893, 73.3417], [19.0760, 72.8777]]),
    Vehicle(plate: 'DL 1G BC 8891', model: 'BharatBenz 2823', year: 2021, type: 'HCV', status: 'running', driver: 'Gurpreet Singh', loc: 'Delhi–Jaipur NH-48', speed: 78, fuel: 72, mil: 5.6, idle: 12, fastag: 8200, health: 82, odo: 93120, nextService: '2026-05-10', insurance: '2026-09-30', permit: '2026-12-31', puc: '2026-06-15', lastFill: '09 Apr', alerts: ['Harsh Braking'], lat: 27.5652, lng: 76.6231, route: [[28.6139, 77.2090], [27.5652, 76.6231], [26.9124, 75.7873]]),
    Vehicle(plate: 'GJ 12 EZ 9012', model: 'Ashok Leyland 2820', year: 2020, type: 'HCV', status: 'idle', driver: 'Abdul Ansari', loc: 'Gandhidham Port Gate', speed: 0, fuel: 54, mil: 4.3, idle: 47, fastag: 340, health: 62, odo: 29400, nextService: '2026-04-20', insurance: '2026-10-28', permit: '2026-06-30', puc: '2026-05-20', lastFill: '08 Apr', alerts: ['e-Way Bill Expiring', 'FASTag Low'], lat: 23.0333, lng: 70.1333),
    Vehicle(plate: 'KA 01 MR 7732', model: 'Tata Ultra 1918', year: 2023, type: 'MCV', status: 'running', driver: 'Suresh Patil', loc: 'Bangalore Hub, Whitefield', speed: 55, fuel: 81, mil: 5.1, idle: 14, fastag: 4500, health: 75, odo: 55400, nextService: '2026-06-01', insurance: '2026-11-15', permit: '2026-12-31', puc: '2026-08-10', lastFill: '07 Apr', alerts: [], lat: 12.9698, lng: 77.7499, route: [[12.9716, 77.5946], [12.9698, 77.7499], [13.0827, 80.2707]]),
    Vehicle(plate: 'MH 43 BP 2114', model: 'Eicher Pro 2114', year: 2019, type: 'MCV', status: 'running', driver: 'Rajendra Prasad', loc: 'Mumbai–Pune Expressway', speed: 91, fuel: 35, mil: 3.9, idle: 27, fastag: -150, health: 52, odo: 61200, nextService: '2026-04-11', insurance: '2026-05-30', permit: '2026-09-30', puc: '2026-04-30', lastFill: '08 Apr', alerts: ['Over-speed', 'FASTag Blacklisted', 'Service Overdue'], lat: 18.9200, lng: 73.1500, route: [[19.0760, 72.8777], [18.9200, 73.1500], [18.5204, 73.8567]]),
  ];

  List<Driver> drivers = [
    Driver(id: 'DRV-1001', name: 'Muthu Swami', phone: '+91 94430 12345', age: 38, exp: 12, lic: 'TN0620140012345', licExp: '2028-06-30', blood: 'B+', vehicle: 'TN 04 TT 6612', status: 'on_duty', score: 88, mil: 5.7, idle: 10, trips: 142, harsh: 2, overSpeed: 1, deviation: 0, fuelEff: 94, rating: 4.8, home: 'Chennai', onLeave: false),
    Driver(id: 'DRV-1002', name: 'Ramesh Kumar', phone: '+91 98765 43210', age: 42, exp: 16, lic: 'MH0520100067890', licExp: '2027-05-15', blood: 'O+', vehicle: 'MH 14 CX 5543', status: 'on_duty', score: 85, mil: 5.6, idle: 12, trips: 198, harsh: 5, overSpeed: 3, deviation: 1, fuelEff: 89, rating: 4.6, home: 'Pune', onLeave: false),
    Driver(id: 'DRV-1003', name: 'Suresh Patil', phone: '+91 99834 56789', age: 35, exp: 9, lic: 'KA0920150045678', licExp: '2026-09-22', blood: 'A+', vehicle: 'KA 01 MR 7732', status: 'on_duty', score: 78, mil: 5.1, idle: 14, trips: 87, harsh: 7, overSpeed: 5, deviation: 2, fuelEff: 82, rating: 4.2, home: 'Bangalore', onLeave: false),
  ];

  DataEngine() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      vehicles = vehicles.map((v) {
        if (!v.isActive) return v;
        double newLat = v.lat + (Random().nextDouble() - 0.5) * 0.001;
        double newLng = v.lng + (Random().nextDouble() - 0.5) * 0.001;
        double newSpeed = max(0, v.speed + (Random().nextDouble() - 0.5) * 10);
        
        final updatedV = v.copyWith(
          lat: newLat, 
          lng: newLng, 
          speed: newSpeed.toInt(),
          route: [...v.route, [newLat, newLng]]
        );
        _checkAlerts(updatedV);
        return updatedV;
      }).toList();

      drivers = drivers.map((d) {
        int newScore = d.onLeave ? d.score : max(0, min(100, (d.score + (Random().nextDouble() * 2 - 1)).round()));
        double newIdle = d.status == 'on_duty' ? max(0, double.parse((d.idle + (Random().nextDouble() * 1 - 0.5)).toStringAsFixed(1))) : d.idle;
        double newMil = d.status == 'on_duty' ? max(2, double.parse((d.mil + (Random().nextDouble() * 0.1 - 0.05)).toStringAsFixed(2))) : d.mil;
        return d.copyWith(score: newScore, idle: newIdle, mil: newMil);
      }).toList();

      notifyListeners();
    });
  }
}
