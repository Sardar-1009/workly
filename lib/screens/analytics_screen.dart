import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  Map<String, int> _stats = {
    'views': 0,
    'swipes': 0,
    'applies': 0,
    'details': 0,
    'accepted': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _analyticsService.getWeeklyStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics (Today)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStats();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // KPI Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('Views', _stats['views'] ?? 0,
                            Icons.visibility, Colors.blue),
                        _buildStatCard('Swipes', _stats['swipes'] ?? 0,
                            Icons.swipe, Colors.orange),
                        _buildStatCard('Applies', _stats['applies'] ?? 0,
                            Icons.check_circle, Colors.green),
                        _buildStatCard('Accepted', _stats['accepted'] ?? 0,
                            Icons.handshake, Colors.teal),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Chart Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Weekly Activity',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10)
                          ]),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (_stats['views']?.toDouble() ?? 10) *
                              1.2, // Dynamic Max Y
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Colors.blueGrey,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = const Text('Views', style: style);
                                      break;
                                    case 1:
                                      text = const Text('Swipes', style: style);
                                      break;
                                    case 2:
                                      text =
                                          const Text('Applies', style: style);
                                      break;
                                    default:
                                      text = const Text('', style: style);
                                      break;
                                  }
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide, child: text);
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                    toY: (_stats['views'] ?? 0).toDouble(),
                                    color: Colors.blue,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(4))
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                    toY: (_stats['swipes'] ?? 0).toDouble(),
                                    color: Colors.orange,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(4))
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                    toY: (_stats['applies'] ?? 0).toDouble(),
                                    color: Colors.green,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(4))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
