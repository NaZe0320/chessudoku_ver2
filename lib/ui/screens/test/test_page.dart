import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../domain/notifiers/test_notifier.dart';
import '../../../domain/states/test_state.dart';

class TestPage extends HookConsumerWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();

    // 페이지 로드 시 데이터 가져오기
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(testNotifierProvider.notifier).loadTests();
      });
      return null;
    }, []);

    final testState = ref.watch(testNotifierProvider);
    final testNotifier = ref.read(testNotifierProvider.notifier);

    void createTest() async {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('테스트 이름을 입력해주세요')),
        );
        return;
      }

      final success = await testNotifier.createTest(
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? '설명 없음'
            : descriptionController.text.trim(),
      );

      if (success) {
        nameController.clear();
        descriptionController.clear();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('테스트가 생성되었습니다')),
          );
        }
      }
    }

    void showDeleteDialog(String testId, String testName) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('테스트 삭제'),
          content: Text('\'$testName\'을(를) 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await testNotifier.deleteTest(testId);

                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('\'$testName\'이(가) 삭제되었습니다')),
                  );
                }
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    Color getStatusColor(TestStatus status) {
      switch (status) {
        case TestStatus.initial:
          return Colors.grey;
        case TestStatus.loading:
          return Colors.orange;
        case TestStatus.success:
          return Colors.green;
        case TestStatus.failure:
          return Colors.red;
      }
    }

    String getStatusText(TestState state) {
      final statusText = switch (state.status) {
        TestStatus.initial => '초기 상태',
        TestStatus.loading => '로딩 중...',
        TestStatus.success => '성공',
        TestStatus.failure => '실패',
      };

      final actionText = <String>[];
      if (state.isCreating) actionText.add('생성 중');
      if (state.isUpdating) actionText.add('수정 중');
      if (state.isDeleting) actionText.add('삭제 중');

      return actionText.isEmpty
          ? statusText
          : '$statusText (${actionText.join(', ')})';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository 아키텍처 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => testNotifier.loadTests(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상태 표시 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: getStatusColor(testState.status),
            child: Text(
              getStatusText(testState),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 에러 메시지 표시
          if (testState.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      testState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    onPressed: () => testNotifier.clearError(),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),

          // 새 테스트 추가 영역
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새 테스트 추가',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '테스트 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: testState.isCreating ? null : createTest,
                      child: testState.isCreating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('생성 중...'),
                              ],
                            )
                          : const Text('테스트 추가'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 테스트 목록
          Expanded(
            child: testState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : testState.tests.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '테스트 데이터가 없습니다',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: testState.tests.length,
                        itemBuilder: (context, index) {
                          final test = testState.tests[index];
                          final isSelected =
                              testState.selectedTest?.id == test.id;

                          return Card(
                            color: isSelected ? Colors.blue[50] : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(test.id),
                              ),
                              title: Text(
                                test.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(test.description),
                                  Text(
                                    '생성일: ${test.createdAt.toString().substring(0, 19)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        testNotifier.setSelectedTest(
                                      isSelected ? null : test,
                                    ),
                                    icon: Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected ? Colors.blue : null,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: testState.isDeleting
                                        ? null
                                        : () => showDeleteDialog(
                                            test.id, test.name),
                                    icon: Icon(
                                      Icons.delete,
                                      color: testState.isDeleting
                                          ? Colors.grey
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),

          // 하단 정보 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Text(
              '총 ${testState.tests.length}개의 테스트 | '
              '선택된 테스트: ${testState.selectedTest?.name ?? '없음'}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
