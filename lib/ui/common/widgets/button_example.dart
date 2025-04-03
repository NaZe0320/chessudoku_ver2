import 'package:chessudoku/ui/common/widgets/app_button.dart';
import 'package:flutter/material.dart';

class ButtonExample extends StatelessWidget {
  const ButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('버튼 예제'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('기본 버튼 타입',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AppButton(
                    text: '기본 버튼',
                    type: ButtonType.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기본 버튼 클릭됨')),
                      );
                    },
                  ),
                  AppButton(
                    text: '보조 버튼',
                    type: ButtonType.secondary,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '성공 버튼',
                    type: ButtonType.success,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '경고 버튼',
                    type: ButtonType.warning,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '오류 버튼',
                    type: ButtonType.error,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '정보 버튼',
                    type: ButtonType.info,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('버튼 크기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppButton(
                    text: '작은 버튼',
                    size: ButtonSize.small,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '중간 버튼',
                    size: ButtonSize.medium,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '큰 버튼',
                    size: ButtonSize.large,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('비활성화 버튼',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AppButton(
                    text: '비활성화 버튼',
                    isDisabled: true,
                    onTap: () {},
                  ),
                  AppButton(
                    text: '비활성화 성공 버튼',
                    type: ButtonType.success,
                    isDisabled: true,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('전체 너비 버튼',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppButton(
                text: '전체 너비 버튼',
                isFullWidth: true,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              AppButton(
                text: '전체 너비 보조 버튼',
                type: ButtonType.secondary,
                isFullWidth: true,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              const Text('아이콘 버튼',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AppButton(
                    text: '접두 아이콘',
                    prefixIcon:
                        const Icon(Icons.add, color: Colors.white, size: 18),
                    onTap: () {},
                  ),
                  AppButton(
                    text: '접미 아이콘',
                    suffixIcon: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 18),
                    onTap: () {},
                  ),
                  AppButton(
                    text: '양쪽 아이콘',
                    prefixIcon:
                        const Icon(Icons.save, color: Colors.white, size: 18),
                    suffixIcon:
                        const Icon(Icons.check, color: Colors.white, size: 18),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
