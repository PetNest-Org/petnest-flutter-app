import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/common/app_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(userName: "Rachit"),
              const SizedBox(height: 16),

              // 🔍 Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Search 'dog food' or 'grooming'...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 🎯 Promo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _PromoCarousel(),
              ),

              /* ================= SERVICES NEAR YOU ================= */

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Services near you",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "SEE ALL",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _ServiceCard(
                      icon: Icons.shield,
                      title: "Home Vet Visit",
                      time: "60 min",
                      price: "₹2499",
                    ),
                    SizedBox(width: 14),
                    _ServiceCard(
                      icon: Icons.cut,
                      title: "Full Grooming",
                      time: "90 min",
                      price: "₹1499",
                    ),
                    SizedBox(width: 14),
                    _ServiceCard(
                      icon: Icons.medical_services,
                      title: "Pet Vaccination",
                      time: "30 min",
                      price: "₹999",
                    ),
                    SizedBox(width: 14),
                    _ServiceCard(
                      icon: Icons.pets,
                      title: "Pet Training",
                      time: "45 min",
                      price: "₹1999",
                    ),
                  ],
                ),
              ),

              /* ================= BESTSELLERS ================= */

              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Bestsellers",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text("No products found"));
                    }

                    final products = snapshot.data!.docs;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 370,
                      ),
                      itemBuilder: (context, index) {
                        final p =
                            products[index].data() as Map<String, dynamic>;

                        return _BestsellerCard(
                          bgType: p['bg_type'] ?? 'yellow',
                          isTrending: p['isTrending'] ?? false,
                          label: p['category'],
                          weight: p['weight'],
                          title: p['name'],
                          rating: p['rating'].toString(),
                          reviews: "(${p['reviews']})",
                          time: p['delivery_time'],
                          price: "₹${p['price']}",
                          off: "${p['discount']}% OFF",
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= PROMO ================= */

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final controller = PageController();
  int index = 0;

  final items = const [
    ("Grooming\nSpecials", Color(0xFFE9F7F7), Color(0xFF2AA39A)),
    ("Free Vet\nConsultation", Color(0xFFFFF8E6), Color(0xFFE0A400)),
    ("50% OFF\nPet Food", Color(0xFFE6F5FF), Color(0xFF087EA3)),
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (_) {
      index = (index + 1) % items.length;
      controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: controller,
        itemCount: items.length,
        itemBuilder: (_, i) {
          return Container(
            decoration: BoxDecoration(
              color: items[i].$2,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              items[i].$1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: items[i].$3,
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ================= SERVICE CARD ================= */

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String price;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Book $price"),
          ),
        ],
      ),
    );
  }
}

/* ================= BESTSELLER CARD (UNCHANGED) ================= */

class _BestsellerCard extends StatefulWidget {
  final String bgType;
  final bool isTrending;
  final String label;
  final String weight;
  final String title;
  final String rating;
  final String reviews;
  final String time;
  final String price;
  final String off;

  const _BestsellerCard({
    required this.bgType,
    required this.isTrending,
    required this.label,
    required this.weight,
    required this.title,
    required this.rating,
    required this.reviews,
    required this.time,
    required this.price,
    required this.off,
  });

  @override
  State<_BestsellerCard> createState() => _BestsellerCardState();
}

class _BestsellerCardState extends State<_BestsellerCard> {
  bool isLiked = false;

  Color getBgColor() {
    switch (widget.bgType) {
      case 'blue':
        return const Color(0xFFE6F5FF);
      case 'purple':
        return const Color(0xFFF1E9FF);
      case 'green':
        return const Color(0xFFE9F7F1);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color getTextColor() {
    switch (widget.bgType) {
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.deepPurple;
      case 'green':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: getBgColor(),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: getTextColor(),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => isLiked = !isLiked),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              if (widget.isTrending)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Trending",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.weight),
          const SizedBox(height: 6),
          Text(
            widget.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text("⭐ ${widget.rating} ${widget.reviews}"),
          Text("⏱ ${widget.time}"),
          const Spacer(),
          Text(
            widget.off,
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.w800),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.price,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "ADD",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
