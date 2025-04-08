import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordsPage extends ConsumerStatefulWidget {
  const RecordsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends ConsumerState<RecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange); 

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final intent = ref.read(recordsIntentProvider);
    intent.loadBestRecord();
    intent.loadRecords();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final intent = ref.read(recordsIntentProvider);
      intent.changeDifficulty(_getDifficultyFromTabIndex(_tabController.index));
    }
  }

  Difficulty _getDifficultyFromTabIndex(int index) {
    switch (index) {
      case 0:
        return Difficulty.easy;
      case 1:
        return Difficulty.medium;
      case 2:
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기록실'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '쉬움'),
            Tab(text: '보통'),
            Tab(text: '어려움'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordList(Difficulty.easy),
          _buildRecordList(Difficulty.medium),
          _buildRecordList(Difficulty.hard),
        ],
      ),
    );
  }

  Widget _buildRecordList(Difficulty difficulty) {
    final state = ref.watch(recordsProvider);
    final intent = ref.read(recordsIntentProvider);

    // 현재 선택된 탭의 난이도와 일치하는지 확인
    final isCurrentTab = state.difficulty == difficulty;

    return RefreshIndicator(
      onRefresh: () => intent.refreshRecords(),
      child: Column(
        children: [
          // 최고 기록 헤더
          _buildBestRecordHeader(difficulty),

          // 기록 목록
          Expanded(
            child: state.records.isEmpty && !state.isLoading
                ? const Center(
                    child: Text('기록이 없습니다.'),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (isCurrentTab &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          !state.isLoading &&
                          state.hasMoreRecords) {
                        intent.loadRecords();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: isCurrentTab
                          ? state.records.length +
                              (state.hasMoreRecords ? 1 : 0)
                          : 0,
                      itemBuilder: (context, index) {
                        if (index == state.records.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final record = state.records[index];
                        final recordIndex =
                            (state.currentPage - 1) * state.itemsPerPage +
                                index +
                                1;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            title: Text('완료 시간: ${record['completionTime']}'),
                            subtitle:
                                Text('날짜: ${_formatDate(record['createdAt'])}'),
                            leading: CircleAvatar(
                              backgroundColor: _getDifficultyColor(difficulty),
                              radius: 16,
                              child: Text(
                                '$recordIndex',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestRecordHeader(Difficulty difficulty) {
    final state = ref.watch(recordsProvider);
    final isCurrentTab = state.difficulty == difficulty;

    if (!isCurrentTab || state.bestRecord == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text('아직 최고 기록이 없습니다.'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: _getDifficultyColor(difficulty).withAlpha(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: _getDifficultyColor(difficulty),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '최고 기록',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '완료 시간: ${state.bestRecord!['completionTime']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatDate(state.bestRecord!['createdAt']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
