import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:example/platforms.dart';
import 'package:responsive_widgets_prefix/responsive_widgets_prefix.dart';

class LanguagesPage extends StatefulWidget {

  const LanguagesPage({Key? key}) : super(key: key);
  @override State<LanguagesPage> createState() => _LanguagesPageState();

}

class _LanguagesPageState extends State<LanguagesPage> {
  late List languages = [];

  _LanguagesPageState() : super() {
    _loadLanguages();
  }

  void _loadLanguages() async {
    final source = await rootBundle.loadString('assets/fixtures/languages.json');
    languages = json.decode(source)['results'];
    setState(() {});
  }

  Widget _listBuilder(BuildContext context, int index) {
    final item = languages[index];
    return Card(
        elevation: 1.5,
        margin: const EdgeInsets.fromLTRB(6, 12, 6, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        color: Colors.white,
        child: InkWell(
            key: Key('item_$index'),
            onTap: () {
              if(Platform.isAndroid) {
                  final route = MaterialPageRoute(builder: (BuildContext context) => LanguagePage(index: index, language: item));
                  Navigator.push<void>(context, route);
              } else {
                  final route = CupertinoPageRoute(builder: (BuildContext context) => LanguagePage(index: index, language: item));
                  Navigator.push<void>(context, route);
              }
            },
            child: LanguagePreview(index: index, language: item)),
      
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      key: const Key('item_list'),
      itemCount: languages.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: _listBuilder,
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      body: _buildBody(context)
    );
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: _buildBody(context)
      )
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIOS,
    );
  }

}

class LanguagePreview extends StatelessWidget {
  final int index;
  final Map language;

  const LanguagePreview({Key? key, required this.index, required this.language})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = language['name'];
    final year = language['year'];
    final logo = language['logo'];
    final hello = language['hello'];
    final subtext = language['person'];
    final category = language['category'];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/images/$logo')),
              const Padding(padding: EdgeInsets.only(left: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ResponsiveText(
                        name,
                        key: Key('item_${index}_name'),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ResponsiveText(
                        ' / ',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ResponsiveText(
                        '$year',
                        key: Key('item_${index}_year'),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  ResponsiveText(
                    subtext,
                    style: const TextStyle(
                      color: Colors.black
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  ResponsiveText(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 16)),
          Image.asset('assets/images/$hello')
        ],
      ),
    );
  }
}

class LanguageDetail extends StatelessWidget {
  final int index;
  final Map language;

  const LanguageDetail({Key? key, required this.index, required this.language})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = language['arguments'];
    final description = language['description'];

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/$arguments'),
          const Padding(padding: EdgeInsets.only(top: 16)),
          ResponsiveText(
            description,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
        ],
      ),
    );
  }
}

class LanguagePage extends StatefulWidget {
  final int index;
  final Map language;

  const LanguagePage({Key? key, required this.index, required this.language})
      : super(key: key);
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {


  Widget _buildBody(BuildContext context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            children: [
              LanguagePreview(index: widget.index, language: widget.language),
              LanguageDetail(index: widget.index, language: widget.language),
            ],
          ),
      );
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(),
      child: SafeArea(
        child: _buildBody(context)
      )
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildBody(context)
    );
  }


  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIOS,
    );
  }
}
