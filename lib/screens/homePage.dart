import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app/services/apiService.dart';
import 'package:share_plus/share_plus.dart';

import 'article_webview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  late Future<List<dynamic>> newsFuture;

  static const Color primaryAccent = Color(0xFF4F6BFF);
  static const Color softBackground = Color(0xFFEEF2FF);

  final List<String> categories = [
    'ALL',
    'SPORTS',
    'HEALTH',
    'SCIENCE',
    'TECHNOLOGY',
  ];

  @override
  void initState() {
    super.initState();
    newsFuture = Apiservice.getData(category: selectedCategory);
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      newsFuture = Apiservice.getData(category: category);
    });
  }

  void _shareArticle(Map<String, dynamic> item) {
    final String title = item['title'] ?? '';
    final String url = item['url'] ?? '';
    final String shareText = url.isNotEmpty ? '$title\n$url' : title;
    if (shareText.trim().isNotEmpty) {
      Share.share(shareText);
    }
  }

  void _openArticle(Map<String, dynamic> item) {
    final String url = item['url'] ?? '';
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ArticleWebViewPage(url: url, title: item['title'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'News App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryAccent),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final allNews = snapshot.data!;

            if (allNews.isEmpty) {
              return Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildCategoryRow(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Not Found',
                            style: GoogleFonts.roboto(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final hotTopics = allNews.take(5).toList();
            final latestNews = allNews.length > 5
                ? allNews.skip(5).toList()
                : <dynamic>[];
            final leftColumnNews = <dynamic>[];
            final rightColumnNews = <dynamic>[];
            for (int i = 0; i < latestNews.length; i++) {
              if (i % 2 == 0) {
                leftColumnNews.add(latestNews[i]);
              } else {
                rightColumnNews.add(latestNews[i]);
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      'Hot Topics',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    SizedBox(
                      height: 300.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hotTopics.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = hotTopics[index];
                          return _HotTopicCard(
                            item: item,
                            width: MediaQuery.of(context).size.width - 40.w,
                            onOpen: () => _openArticle(item),
                            onShare: () => _shareArticle(item),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'Latest News',
                      style: GoogleFonts.roboto(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _buildCategoryRow(),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: leftColumnNews.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = leftColumnNews[index];
                              return _LatestNewsCard(
                                item: item,
                                onOpen: () => _openArticle(item),
                                onShare: () => _shareArticle(item),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: rightColumnNews.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = rightColumnNews[index];
                              return _LatestNewsCard(
                                item: item,
                                onOpen: () => _openArticle(item),
                                onShare: () => _shareArticle(item),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final bool isSelected = category == selectedCategory;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => _onCategorySelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: isSelected ? primaryAccent : softBackground,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.roboto(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HotTopicCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final double width;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const _HotTopicCard({
    required this.item,
    required this.width,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: EdgeInsets.only(right: 15.w),
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item['urlToImage'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onShare,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.ios_share_rounded,
                    size: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['author'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          item['source']?['name'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _LatestNewsCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const _LatestNewsCard({
    required this.item,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.r),
                  ),
                  child: Image.network(
                    item['urlToImage'] ?? '',
                    height: 130.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130.h,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onShare,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.ios_share_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['author'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            color: Colors.black45,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        item['source']?['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          color: _HomePageState.primaryAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 8.sp,
                        ),
                      ),
                    ],
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
