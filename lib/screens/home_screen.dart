import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../data/mock_vacancies.dart';
import '../models/vacancy.dart';
import '../widgets/vacancy_card.dart';
import '../widgets/action_buttons.dart';
import '../services/user_job_service.dart';
import '../services/analytics_service.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController controller = CardSwiperController();
  final List<Vacancy> allVacancies = MockVacancyService.getVacancies();
  List<Vacancy> filteredVacancies = [];

  final UserJobService _userJobService = UserJobService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Search & Filter State
  String _searchQuery = '';
  FilterResult? _currentFilters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVacancies = List.from(allVacancies);
  }

  void _applyFilters() {
    setState(() {
      filteredVacancies = allVacancies.where((v) {
        // Search
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final matchesTitle = v.title.toLowerCase().contains(query);
          final matchesCompany = v.company.toLowerCase().contains(query);
          if (!matchesTitle && !matchesCompany) return false;
        }

        // Filters
        if (_currentFilters != null) {
          // Work Format
          if (_currentFilters!.workFormat != null &&
              v.workFormat != _currentFilters!.workFormat) {
            return false;
          }
          // Experience
          if (_currentFilters!.experience != null &&
              v.experience != _currentFilters!.experience) {
            return false;
          }
          // Salary logic skipped for MVP simplicity (parsing strings is fragile)
        }

        return true;
      }).toList();
    });
  }

  void _openFilters() async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FilterScreen(initialFilters: _currentFilters),
    );

    if (result != null) {
      _currentFilters = result;
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workly'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _openFilters,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              ),
            ),

            Expanded(
              child: filteredVacancies.isEmpty
                  ? const Center(child: Text("No jobs found"))
                  : CardSwiper(
                      key: ValueKey(
                          filteredVacancies.length), // Rebuild if list changes
                      controller: controller,
                      cardsCount: filteredVacancies.length,
                      numberOfCardsDisplayed: filteredVacancies.length < 3
                          ? filteredVacancies.length
                          : 3,
                      backCardOffset: const Offset(0, 40),
                      padding: const EdgeInsets.all(24.0),
                      cardBuilder: (context, index, percentThresholdX,
                          percentThresholdY) {
                        // Log generic view roughly
                        _analyticsService.logEvent(AnalyticsEventType.view);
                        // Verify bounds
                        if (index >= filteredVacancies.length)
                          return const SizedBox();
                        return VacancyCard(vacancy: filteredVacancies[index]);
                      },
                      onSwipe: _onSwipe,
                      isLoop: false,
                    ),
            ),
            const SizedBox(height: 16),
            if (filteredVacancies.isNotEmpty)
              ActionButtons(
                onPass: () => controller.swipe(CardSwiperDirection.left),
                onApply: () => controller.swipe(CardSwiperDirection.right),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex >= filteredVacancies.length) return true;

    final vacancy = filteredVacancies[previousIndex];
    // Mark as viewed in history
    _userJobService.markJobViewed(vacancy.id);
    _analyticsService.logEvent(AnalyticsEventType.swipe);

    if (direction == CardSwiperDirection.right) {
      // Save application
      _userJobService.saveAppliedJob(vacancy.id);
      _analyticsService.logEvent(AnalyticsEventType.apply);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied to ${vacancy.company}'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 500),
        ),
      );
    } else if (direction == CardSwiperDirection.left) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passed on ${vacancy.company}'),
          backgroundColor: Colors.grey,
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
    return true;
  }
}
