import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g14/widget/home_screen/food_card.dart';
import 'package:g14/widget/home_screen/home_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/widget/home_screen/youtuber_icon.dart';
import 'package:g14/screens/AllVideosScreen.dart';
import 'package:g14/screens/tab1-1.dart';
import 'package:g14/screens/tab1-2.dart';
import 'package:g14/screens/tab1-3.dart';



class Tab1 extends StatefulWidget {
  const Tab1({Key? key}) : super(key: key);

  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final double imageHeight = 132;
  String currentCat = "本格レシピ";
  final List<String> categories = ['本格レシピ', '朝ごはん', '昼ごはん', '夜ご飯'];
  final Map<String, String> categoryMap = {
    '本格レシピ': 'hardrecipe',
    '朝ごはん': 'breakfast',
    '昼ごはん': 'lunch',
    '夜ご飯': 'dinner',
    'pan': 'pan',
    'sweet': 'sweet',
    'famous_chef':'famous_chef',
    '和食':'和食',
    '洋食':'洋食',
    '中華':'中華',
  };
  final List<String> imageList = [
    "assets/images/tukaikata.png",
    "assets/images/oyako.png",
    "assets/images/man.png",
  ];

  Future<List<String>> fetchVideoIds(String category) async {
    final firestoreInstance = FirebaseFirestore.instance;
    String? field = categoryMap[category];
    if (field == null) {
      throw 'Category mapping not found for $category';
    }
    var document = await firestoreInstance.collection('VideoIds').doc('youtube_videos').get();
    if (document.exists) {
      var data = document.data();
      if (data != null && data.containsKey(field)) {
        return List<String>.from(data[field]);
      } else {
        throw 'Field $field not found in the document';
      }
    } else {
      throw 'Document "youtube_videos" not found';
    }
  }

  Widget buildVideoList(List<String> videoIds) {
    return Container(
      height: imageHeight + 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: videoIds.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: YouTubeVideoCard(videoId: videoIds[index]),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String categoryName, String categoryKey) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          categoryName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => _viewAll(categoryKey),
          child: Text('View All'),
        ),
      ],
    );
  }

  void _viewAll(String categoryKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllVideosScreen(categoryKey: categoryKey),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchVideoIds(currentCat);
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeAppbar(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == 0) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HowToPage()));
                      } else if (_currentPage == 1) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HowToPage2()));
                      } else if (_currentPage == 2) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HowToPage3()));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 170,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageList.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(imageList[index], fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                  ),
                    const SizedBox(height: 20),
                    const Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentCat = categories[index];
                                fetchVideoIds(categories[index]);
                              });
                              },
                            child: Container(
                              margin: const EdgeInsets.only(right: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                color: currentCat == categories[index]
                                    ? Colors.blue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color: currentCat == categories[index] ? Colors
                                      .white : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 30),

                    FutureBuilder<List<String>>(
                      future: fetchVideoIds(currentCat),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Container(
                              height: imageHeight + 84,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: YouTubeVideoCard(videoId: snapshot.data![index]),
                                  );
                                  },
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                        }
                        return Center(child: CircularProgressIndicator());
                        },
                    ),


                    const SizedBox(height: 20),
                    const Text(
                      "Creator",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CreatorsList(),








                    const SizedBox(height: 20),




                    _buildCategorySection("パン作り", 'pan'),
                    FutureBuilder<List<String>>(
                      future: fetchVideoIds('pan'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return buildVideoList(snapshot.data!); // パンカテゴリの動画リストを表示
                      } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                        }
                        return Center(child: CircularProgressIndicator());
                  },
                ),



                    const SizedBox(height: 20),
                    _buildCategorySection("スイーツ", 'sweet'),

                    FutureBuilder<List<String>>(
                        future: fetchVideoIds('sweet'),
                         builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              return buildVideoList(snapshot.data!); // スイーツカテゴリの動画リストを表示
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                    }
                          return Center(child: CircularProgressIndicator());
                  },
                ),

                    const SizedBox(height: 20),

                    _buildCategorySection("有名シェフ・シリーズ", 'famous_chef'),

                    FutureBuilder<List<String>>(
                      future: fetchVideoIds('famous_chef'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return buildVideoList(snapshot.data!); // スイーツカテゴリの動画リストを表示
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }}

                        return Center(child: CircularProgressIndicator());
                  },
                ),
                  const SizedBox(height: 20),
                  _buildCategorySection("和食", '和食'),
                  FutureBuilder<List<String>>(
                    future: fetchVideoIds('和食'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return buildVideoList(snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }}

                      return Center(child: CircularProgressIndicator());
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildCategorySection("洋食", '洋食'),
                  FutureBuilder<List<String>>(
                    future: fetchVideoIds('洋食'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return buildVideoList(snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }}

                      return Center(child: CircularProgressIndicator());
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildCategorySection("中華", '中華'),
                  FutureBuilder<List<String>>(
                    future: fetchVideoIds('中華'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return buildVideoList(snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }}

                      return Center(child: CircularProgressIndicator());
                    },
                  ),

                ],
                ),
              ),

            ),
          ),
        ),
    );
  }
}