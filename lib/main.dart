import 'package:dots_indicator/dots_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/helper/background_code.dart';
import 'package:weather_app/models/CurrentForecast.dart';
import 'package:weather_app/provider/WeatherProvider.dart';
import 'WeatherPageView.dart';
import 'database/database_helper.dart';
import 'location.dart';

final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsApp.debugAllowBannerOverride = false;
  await dbHelper.init();
  await dotenv.load(fileName: "lib/.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WeatherProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter App',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  bool _isLoading = false;
  String title = '';
  String code = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoading = true;
    });

    Provider.of<WeatherProvider>(context, listen: false)
        .getDetailDataOfAllPageView()
        .then((data) async {
      SharedPreferences pref = await SharedPreferences.getInstance();

      int initialPage = pref.getInt('currentIndex') ?? 0;
      setState(() {
        _isLoading = false;

        CurrentForeCast currentForeCast = [...data][initialPage][0];
        title = currentForeCast.name!;
        code = currentForeCast.weather![0].icon!;

        _currentIndex = initialPage;
        _pageController = PageController(initialPage: _currentIndex);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerWeather = Provider.of<WeatherProvider>(context);
    List<dynamic> data_ = [...providerWeather.getDetailDataOfAllPageWeather];

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: const Alignment(1, 1),
        colors: getBackgroundColor(code),
        tileMode: TileMode.mirror,
      )),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return LocationPage(
                        pageController: _pageController,
                      );
                    })).then((result) => {
                          setState(() {
                            title = providerWeather
                                .getDetailDataOfAllPageWeather[_currentIndex][0]
                                .name!;
                            code = providerWeather
                                .getDetailDataOfAllPageWeather[_currentIndex][0]
                                .weather![0]
                                .icon!;
                          })
                        });
                  },
                  child: const Icon(Icons.add)),
              centerTitle: true,
              title: _isLoading
                  ? null
                  : Column(
                      children: [
                        Text(title),
                        DotsIndicator(
                          dotsCount: providerWeather
                              .getCurrentWeatherOfLocations.length,
                          position: _currentIndex.toDouble(),
                          decorator: const DotsDecorator(
                              color: Colors.white70,
                              size: Size.square(5), // Inactive color
                              activeColor: Colors.white,
                              activeSize: Size.square(6)),
                        ),
                      ],
                    )),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : PageView(
                  onPageChanged: (index) {
                    CurrentForeCast currentForeCast = data_[index][0];
                    setState(() {
                      title = currentForeCast.name!;
                      code = currentForeCast.weather![0].icon!;
                      _currentIndex = index;
                    });
                  },
                  controller: _pageController,
                  children: data_
                      .map((dataWeather) => WeatherPageView(data: dataWeather))
                      .toList(),
                )),
    );
  }
}
