import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_map/model/latLong.dart';
import 'package:yandex_map/service/app_location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();

/*
Метод _initPermission() проверяет, предоставил ли пользователь разрешения на
определение геопозиции. Если не предоставил, то делаем запрос на разрешение
доступа к геопозиции. После этого вызываем метод _fetchCurrentLocation() для
установки координат.
 */
  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  /*
  _initPermission().ignore() для запроса разрешений и установления координат в initState() MapScreen, и реализация готова.
.ignore() нужен здесь для безопасной обработки и игнорирования Future метода _initPermission()
   */

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YandexMap(
        onMapCreated: (controller) {
          mapControllerCompleter.complete(controller);
        },
      ),
    );
  }

/*
Метод _fetchCurrentLocation()  получает необходимые координаты для метода
_moveToCurrentPosition(). В случае ошибки, или если он не сможет определить
текущее местоположение, вернет координаты Tashkenta.
 */
  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = TashkentLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    _moveToCurrentLocation(location);
  }

/*
Напишем метод _moveToCurrentPosition(). Это основной метод, который и будет
показывать местоположение пользователя на карте:
 */

  Future<void> _moveToCurrentLocation(AppLatLong appLatLong) async {
    (await mapControllerCompleter.future).moveCamera(
        animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
        CameraUpdate.newCameraPosition(CameraPosition(
          target: Point(latitude: appLatLong.lat, longitude: appLatLong.long),
          zoom: 12,
        )));
  }
/*
  Метод принимает координаты высоты и широты, которые мы получили выше.
Ждем получения mapControllerCompleter и далее, используя методы
.moveCamera()  и .newCameraPosition(), по полученным координатам
анимированно переносим фокус на текущее местоположение.
Параметр zoom: 12 задает отдаление ближе/дальше, так можно отобразить
более точные координаты местоположения.
   */
}
