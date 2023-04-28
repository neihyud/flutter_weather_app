import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Geometry.dart';
import '../models/Suggestion.dart';
import '../network/PlaceService.dart';

import '../provider/WeatherProvider.dart';
import 'PopularLocation.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  PlaceApiProvider apiClient = PlaceApiProvider();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Color.fromARGB(255, 51, 52, 94),
      appBarTheme: const AppBarTheme(
          elevation: 0, color: Color.fromARGB(255, 51, 52, 94)),
      hintColor: Colors.grey,
      inputDecorationTheme: InputDecorationTheme(
        disabledBorder: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(80.0),
        ),
        focusColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18),
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () async {
          final weatherData =
              Provider.of<WeatherProvider>(context, listen: false);

          weatherData.updateCurrentWeatherLocation(Geo(null, null), query);

          Navigator.pop(context);
        },
      )
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: popularLocation(context),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        (snapshot.data?[index] as Suggestion).formatted,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () {
                        close(context, snapshot.data?[index] as Suggestion);
                      },
                    );
                  },
                  itemCount: snapshot.data?.length,
                )
              : const Center(
                  child: Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return InkWell(
        onTap: () => {Navigator.pop(context)},
        child: const Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(
        child: Text(
      'Empty...',
      style: TextStyle(color: Colors.white, fontSize: 20),
    ));
  }
}
