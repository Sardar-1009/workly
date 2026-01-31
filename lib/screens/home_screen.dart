import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../data/mock_vacancies.dart';
import '../models/vacancy.dart';
import '../widgets/vacancy_card.dart';
import '../widgets/action_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController controller = CardSwiperController();
  final List<Vacancy> vacancies = MockVacancyService.getVacancies();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workly'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CardSwiper(
                controller: controller,
                cardsCount: vacancies.length,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(0, 40),
                padding: const EdgeInsets.all(24.0),
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  return VacancyCard(vacancy: vacancies[index]);
                },
                onSwipe: _onSwipe,
                isLoop: false,
              ),
            ),
            ActionButtons(
              onPass: () => controller.swipe(CardSwiperDirection.left),
              onApply: () => controller.swipe(CardSwiperDirection.right),
            ),
             const SizedBox(height: 20),
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
    final vacancy = vacancies[previousIndex];
    if (direction == CardSwiperDirection.right) {
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
           backgroundColor: Colors.red,
           duration: const Duration(milliseconds: 500),
        ),
      );
    }
    return true;
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
