import 'package:car_app/apis/api.dart';
import 'package:car_app/models/geoapify_models/geoplace.dart';
import 'package:car_app/models/location.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/screens/google_map/google_map_screen.dart';
import 'package:car_app/screens/root/root.dart';
import 'package:car_app/screens/utils/consts.dart';
import 'package:car_app/screens/utils/order_detail_bottom.dart';
import 'package:car_app/services/geoapify_service.dart';
import 'package:car_app/services/place_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddOrderScreen extends StatefulWidget {
  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  late GeoPlace _startPlace;
  GeoPlace? _endPlace;

  TextEditingController _startPlaceController = TextEditingController();
  TextEditingController _endPlaceController = TextEditingController();

  String _currentController = '';
  late Position _position;
  late LatLng _latlng;
  late GeoPlace _address;
  List<String> _cabTypes = [...Consts.CAB_TYPES, 'Every types'];
  List<Widget> _cabTypeIcons = [
    ...Consts.CAB_TYPE_ICONS,
    Icon(Icons.directions_transit)
  ];
  int _selected = 0;
  String _selectedCabType = '';
  Trip? _trip;
  // Timer? _throttle;
  // _onSearchChange() {
  //   PlaceService _placeService =
  //       Provider.of<PlaceService>(context, listen: false);
  //   if (_throttle?.isActive ?? false) _throttle!.cancel();
  //   _throttle = Timer(
  //     const Duration(milliseconds: 500),
  //     () {
  //       if (_currentController == 'start')
  //         _placeService.setSearchResults(_startPlaceController.text);
  //       else if (_currentController == 'end')
  //         _placeService.setSearchResults(_endPlaceController.text);
  //     },
  //   );
  // }

  _getCurrentLocation() async {
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    _latlng = LatLng(_position.latitude, _position.longitude);
    _address = await GeoapifyService.geoReverseGeocoding(
            _latlng.latitude, _latlng.longitude) ??
        GeoPlace(lat: _position.latitude, lon: _position.longitude);
    _startPlace = _address;
    PlaceService _placeService =
        Provider.of<PlaceService>(context, listen: false);
    _placeService.addMarker(_latlng, 'start');
  }

  _selectPlaceSearch(GeoPlace search) async {
    PlaceService _placeService =
        Provider.of<PlaceService>(context, listen: false);
    // GeoPlace? place =
    //     await GeoapifyService.geoReverseGeocoding(search.lat, search.lon);
    _placeService.setSelectedGeoPlace(search);
    if (_currentController == 'start') {
      _startPlaceController.text = search.address ?? '';
      _startPlace = search;
    } else if (_currentController == 'end') {
      _endPlaceController.text = search.address ?? '';
      _endPlace = search;
    }
    LatLng pos = LatLng(
      search.lat,
      search.lon,
    );
    _placeService.addMarker(pos, _currentController);
  }

  _createAnOrder() {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    Trip trip = new Trip(
      user: currentUser.getCurrentUser.id,
      start_location: Location(lat: _startPlace.lat, lng: _startPlace.lon),
      end_location: Location(lat: _endPlace!.lat, lng: _endPlace!.lon),
      status: 'Waitting',
      cab_type: _selectedCabType,
    );
    return trip;
  }

  _selectGeoPlaceDetail(GeoPlace detail) {
    PlaceService _placeService =
        Provider.of<PlaceService>(context, listen: false);
    _placeService.setSelectedGeoPlace(detail);
  }

  @override
  void initState() {
    super.initState();
    _selectedCabType = _cabTypes[_selected];
    _getCurrentLocation();
    PlaceService _placeService =
        Provider.of<PlaceService>(context, listen: false);
    _placeService.geoSearchResult.clear();
    // _startPlaceController.addListener(_onSearchChange);
    // _endPlaceController.addListener(_onSearchChange);
    //
  }

  @override
  void dispose() {
    // _startPlaceController.removeListener(_onSearchChange);
    // _endPlaceController.removeListener(_onSearchChange);
    _startPlaceController.dispose();
    _endPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlaceService _placeService = Provider.of<PlaceService>(context);
    CurrentTrip currentTrip = Provider.of<CurrentTrip>(context);

    _makeAnOrder() async {
      setState(() => _trip = _createAnOrder());
      var data = await Api.addOrder(_trip!);
      if (data != null) {
        currentTrip.addTrip(data);
        return 'success';
      }
    }

    var _startButton = IconButton(
      splashRadius: 8,
      icon: Icon(
        Icons.keyboard_arrow_right_rounded,
      ),
      onPressed: () {
        _selectGeoPlaceDetail(_startPlace);
      },
    );
    var _endButton = IconButton(
      onPressed: _endPlace != null
          ? () => _selectGeoPlaceDetail(_endPlace!)
          : () => setState(() {
                _endPlace = GeoPlace(
                    lat: 20.68391160198584,
                    lon: 105.73819398932747,
                    address: 'Te Tieu, My Duc, Ha Noi');
                var pos = LatLng(20.68391160198584, 105.73819398932747);
                _placeService.addMarker(pos, 'end');
              }),
      icon: Icon(Icons.keyboard_arrow_right_outlined),
    );
    var _header = Container(
      // color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _placeService.origin = null;
                  _placeService.destination = null;
                  _placeService.direction = null;
                },
                icon: Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onTap: () => _currentController = 'start',
                            controller: _startPlaceController,
                            onChanged: (value) =>
                                // _placeService.setSearchResults(value),
                                _placeService.setGeoSearchResult(value),
                            decoration: InputDecoration(
                              hintText: 'My location',
                              icon: Icon(
                                Icons.my_location,
                              ),
                              // hintText: 'Start location',
                            ),
                          ),
                        ),
                        _startButton,
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onTap: () => _currentController = 'end',
                            controller: _endPlaceController,
                            decoration: InputDecoration(
                              icon: Icon(Icons.location_on),
                              hintText: 'Search location',
                            ),
                            onChanged: (value) =>
                                _placeService.setGeoSearchResult(value),
                          ),
                        ),
                        _endButton,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _cabTypes.length,
              (i) => ChoiceChip(
                label: Text(_cabTypes[i]),
                selected: _selected == i,
                avatar: _cabTypeIcons[i],
                onSelected: (bool selected) {
                  if (selected)
                    setState(() {
                      _selected = i;
                      _selectedCabType = _cabTypes[_selected];
                    });
                },
              ),
            ),
          ),
        ],
      ),
    );
    _showDialog(context) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool done = false;
              bool confirm = false;
              bool success = false;
              return StatefulBuilder(
                builder: (context, setState) {
                  var confirmBtn = TextButton(
                    onPressed: () {
                      setState(
                        () {
                          confirm = true;
                          _makeAnOrder().then((value) {
                            setState(() {
                              if (value == 'success') {
                                success = true;
                              }
                              done = true;
                            });
                          });
                        },
                      );
                    },
                    child: Text('Confirm'),
                  );
                  var cancelBtn = TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  );
                  var okBtn = TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  );
                  var doneBtn = TextButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => Root()),
                        (route) => false),
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.green),
                    ),
                  );
                  var doneDlg = AlertDialog(
                    title: Text(
                      'Success !',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    content: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start find a driver ...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 5),
                          Icon(
                            Icons.done_rounded,
                            color: Colors.green,
                            size: 60,
                          ),
                        ],
                      ),
                    ),
                    actions: [doneBtn],
                  );
                  var confirmDlg = AlertDialog(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    title: Text('Confirm order'),
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                      fontSize: 22,
                    ),
                    content: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image:
                                AssetImage('assets/images/confirm_order.jpg'),
                          ),
                        )),
                    actions: [confirmBtn, cancelBtn],
                  );
                  var waittingDlg = AlertDialog(
                    title: Center(child: Text('Creating')),
                    content: Container(
                      height: 60,
                      width: 60,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                  var errorDlg = AlertDialog(
                    title: Text('Error!'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Please, try again'),
                        SizedBox(height: 10),
                        Icon(
                          Icons.error_outline_outlined,
                          size: 60,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    actions: [okBtn],
                  );
                  if (done == true) {
                    return success == true ? doneDlg : errorDlg;
                  } else {
                    return confirm == false ? confirmDlg : waittingDlg;
                  }
                },
              );
            },
          );
        },
      );
    }

    Future<dynamic> _orderDetail(BuildContext context) {
      var orderButton = Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 30,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () => _showDialog(context),
          child: Text(
            'Order',
            style: TextStyle(fontSize: 15),
          ),
        ),
      );
      PlaceService _placeService =
          Provider.of<PlaceService>(context, listen: false);
      final duration = _placeService.direction?.duration;
      final distance = _placeService.direction?.distance;
      final double height = 50;
      var cabIcon = Icon(
        (_cabTypeIcons[_selected] as Icon).icon,
        size: 25,
        color: Theme.of(context).primaryColor,
      );
      return showModalBottomSheet(
        builder: (context) {
          return FutureBuilder<GeoPlace?>(
              future: GeoapifyService.geoReverseGeocoding(
                  _endPlace!.lat, _endPlace!.lon),
              builder: (context, snapshot) {
                return snapshot.data != null
                    ? OrderDetailBottom(
                        address: snapshot.data!.address!,
                        duration: duration,
                        distance: distance,
                        height: height,
                        cabIcon: cabIcon,
                        bottomExtend: orderButton)
                    : SizedBox.shrink();
              });
        },
        context: context,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _header,
            Expanded(
              child: Stack(
                children: [
                  GoogleMapScreen(),
                  if (_placeService.geoSearchResult.isNotEmpty)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        backgroundBlendMode: BlendMode.darken,
                      ),
                      child: ListView.builder(
                        itemCount: _placeService.geoSearchResult.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _placeService.geoSearchResult[index]?.address,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              _selectPlaceSearch(
                                  _placeService.geoSearchResult[index]);
                              // _placeService.geoSearchResult.clear();
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                            },
                          );
                        },
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 70),
                      child: ElevatedButton(
                        onPressed: _endPlace != null
                            ? () => _orderDetail(context)
                            : null,
                        child: Text('Make order'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
