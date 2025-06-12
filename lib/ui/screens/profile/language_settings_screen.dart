import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/data/models/language_pack.dart';
import 'package:chessudoku/domain/states/language_pack_state.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LanguageSettingsScreen extends HookConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 언어팩 목록 로드
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(languagePackNotifierProvider.notifier).loadLanguagePacks();
      });
      return null;
    }, []);

    final languageState = ref.watch(languagePackNotifierProvider);
    final translate = ref.watch(translationProvider);

    Widget buildErrorView(String errorMessage) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              translate('error'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(languagePackNotifierProvider.notifier)
                    .loadLanguagePacks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(translate('retry', '다시 시도')),
            ),
          ],
        ),
      );
    }

    Widget buildTrailingWidget(
      LanguagePack pack,
      bool isSelected,
      String Function(String, [String?]) translate,
    ) {
      if (isSelected) {
        return const Icon(
          Icons.check_circle,
          color: AppColors.success,
        );
      }

      if (!pack.isDownloaded) {
        return const Icon(
          Icons.download,
          color: AppColors.info,
        );
      }

      return const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
      );
    }

    void showDownloadDialog(
        LanguagePack pack, String Function(String, [String?]) translate) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            translate('downloading'),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                '${pack.nativeName} ${translate('다운로드 중...', 'downloading...')}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    void showSuccessMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    void showErrorMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    void handleLanguageItemTap(
      LanguagePack pack,
      String Function(String, [String?]) translate,
    ) async {
      final notifier = ref.read(languagePackNotifierProvider.notifier);
      final currentState = ref.read(languagePackNotifierProvider);

      try {
        if (!pack.isDownloaded) {
          // 언어팩 다운로드
          showDownloadDialog(pack, translate);
          await notifier.downloadLanguagePack(pack.id);
          Navigator.pop(context); // 다운로드 다이얼로그 닫기

          // 다운로드 완료 후 언어 변경
          await notifier.changeLanguage(pack.id);

          showSuccessMessage(translate('download_complete'));
        } else if (pack.id != currentState.currentLanguagePack?.id) {
          // 이미 다운로드된 언어팩으로 변경
          await notifier.changeLanguage(pack.id);
          showSuccessMessage(
              '${pack.nativeName}${translate('으로 언어가 변경되었습니다', ' language changed')}');
        }
      } catch (e) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // 다이얼로그가 열려있다면 닫기
        }
        showErrorMessage(translate('download_failed'));
      }
    }

    Widget buildLanguageItem(
      LanguagePack pack, {
      required bool isSelected,
      required String Function(String, [String?]) translate,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoLight : AppColors.surface,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                isSelected ? AppColors.primary : AppColors.secondary,
            child: Text(
              pack.languageCode.toUpperCase(),
              style: TextStyle(
                color:
                    isSelected ? AppColors.textWhite : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          title: Text(
            pack.nativeName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pack.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              if (!pack.isDownloaded)
                Text(
                  '${translate('download')} (${pack.formattedSize})',
                  style: const TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: buildTrailingWidget(pack, isSelected, translate),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () => handleLanguageItemTap(pack, translate),
        ),
      );
    }

    Widget buildLanguageList(LanguagePackState languageState,
        String Function(String, [String?]) translate) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 언어 섹션
            if (languageState.currentLanguagePack != null) ...[
              Text(
                translate('current_language'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: buildLanguageItem(
                    languageState.currentLanguagePack!,
                    isSelected: true,
                    translate: translate,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 다운로드된 언어팩 섹션
            if (languageState.downloadedPacks.isNotEmpty) ...[
              Text(
                translate('downloaded_languages'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: languageState.downloadedPacks
                        .where((pack) =>
                            pack.id != languageState.currentLanguagePack?.id)
                        .map((pack) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: buildLanguageItem(
                                pack,
                                isSelected: false,
                                translate: translate,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 사용 가능한 언어팩 섹션
            if (languageState.availablePacks.isNotEmpty) ...[
              Text(
                translate('available_languages'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: languageState.availablePacks
                        .map((pack) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: buildLanguageItem(
                                pack,
                                isSelected: false,
                                translate: translate,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          translate('language_settings'),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        centerTitle: true,
        elevation: 0,
      ),
      body: languageState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : languageState.errorMessage != null
              ? buildErrorView(languageState.errorMessage!)
              : buildLanguageList(languageState, translate),
    );
  }
}
