import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/CurrentForecast.dart';

import '../helper/description_code.dart';
import '../helper/icon_weather.dart';
import '../provider/WeatherProvider.dart';

class SavedLocation extends StatefulWidget {
  final bool isEdit;
  const SavedLocation({super.key, required this.isEdit});

  @override
  State<SavedLocation> createState() => _SavedLocationState();
}

// ignore: camel_case_types
class _SavedLocationState extends State<SavedLocation> {
  @override
  Widget build(BuildContext context) {
    final weatherData = Provider.of<WeatherProvider>(context);
    final listLocationsWeather = weatherData.getCurrentLocationsWeather;

    return Expanded(
      child: ReorderableListView(
          // buildDefaultDragHandles: false,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final CurrentForeCast item =
                  listLocationsWeather.removeAt(oldIndex);
              listLocationsWeather.insert(newIndex, item);
            });
          },
          children: [
            for (int index = 0; index < listLocationsWeather.length; index += 1)
              location(index, listLocationsWeather[index])
          ]),
    );
  }

  Widget location(int index, CurrentForeCast currentForeCast) {
    var temp = currentForeCast.main?.temp;

    var iconCode = currentForeCast.weather?[0].icon;
    var desCode = currentForeCast.weather?[0].description;

    var name = currentForeCast.name;
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(currentForeCast.dt! * 1000);

    var day = "${dateTime.day}".padLeft(2, '0');
    var month = "${dateTime.month}".padLeft(2, '0');

    var hour = "${dateTime.hour}".padLeft(2, '0');
    var minute = "${dateTime.minute}".padLeft(2, '0');

    return Row(key: Key('$index'), children: [
      if (widget.isEdit) const Icon(Icons.home),
      Flexible(
        flex: 1,
        child: Stack(children: [
          Container(
            margin: widget.isEdit
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                : const EdgeInsets.symmetric(vertical: 8),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: const Color.fromARGB(255, 2, 2, 2),
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10)),
            height: 100,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$name",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "$day/$month    $hour:$minute",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(children: [
                        getIcon(iconCode.toString()),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${temp?.round().toString()}  °C",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        )
                      ]),
                      Text("$desCode")
                      // getDesCode(iconCode.toString())
                    ],
                  ),
                ]),
          ),
          if (widget.isEdit)
            Positioned(
              top: 6,
              right: 14,
              child: GestureDetector(
                onTap: () {
                  print("delete location");
                },
                child: const Icon(
                  Icons.remove_circle,
                  size: 20,
                ),
              ),
            ),
        ]),
      ),
      if (widget.isEdit)
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color.fromARGB(255, 160, 178, 207)),
          padding: const EdgeInsets.all(3),
          child: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ),
    ]);
  }
}