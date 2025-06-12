import 'package:chessudoku/data/models/language_pack.dart';

class LanguageMockData {
  static final List<LanguagePack> languagePacks = [
    LanguagePack(
      id: 'en_US',
      name: 'English (US)',
      nativeName: 'English',
      languageCode: 'en',
      countryCode: 'US',
      isDownloaded: true,
      isDefault: true,
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      downloadSize: 950000, // 950KB
      translations: {
        'app_name': 'CheSudoku',
        'loading': 'Loading...',
        'downloading': 'Downloading...',
        'download_complete': 'Download Complete',
        'download_failed': 'Download Failed',
        'home': 'Home',
        'puzzle': 'Puzzle',
        'pack': 'Pack',
        'profile': 'Profile',
        'settings': 'Settings',
        'language_settings': 'Language Settings',
        'select_language': 'Select Language',
        'download_language': 'Download Language',
        'current_language': 'Current Language',
        'available_languages': 'Available Languages',
        'downloaded_languages': 'Downloaded Languages',
        'update_available': 'Update Available',
        'update': 'Update',
        'delete': 'Delete',
        'confirm': 'Confirm',
        'cancel': 'Cancel',
        'error': 'Error',
        'success': 'Success',
        'initializing': 'Initializing...',
        'sync_puzzle_packs': 'Syncing puzzle packs...',
        'sync_language_packs': 'Syncing language packs...',
        'sync_complete': 'Sync complete',
        'retry': 'Retry',
        'download': 'Download',
        'app_description': 'Chess meets Sudoku',
        'game_settings': 'Game Settings',
        'sound_effects': 'Sound Effects',
        'vibration': 'Vibration',
        'theme_settings': 'Theme Settings',
        'general_settings': 'General Settings',
        'notification_settings': 'Notification Settings',
        'storage_management': 'Storage Management',
        'information': 'Information',
        'help': 'Help',
        'app_info': 'App Info',
        'privacy_policy': 'Privacy Policy',

        // Game Screen
        'chess_sudoku_game': 'CheSudoku Game',
        'generated_puzzle_screen':
            'Generated puzzle will be displayed here. (Board size: ',

        // Puzzle Creation
        'create_puzzle': 'Create Puzzle',
        'difficulty_easy': 'Easy',
        'difficulty_easy_desc': 'Chess pieces 1-2',
        'difficulty_normal': 'Normal',
        'difficulty_normal_desc': 'Chess pieces 3-5',
        'difficulty_hard': 'Hard',
        'difficulty_hard_desc': 'Chess pieces 5-8',
        'difficulty_expert': 'Expert',
        'difficulty_expert_desc': 'Complex piece combinations',
        'premium_subscription_required': 'Premium subscription required',
        'upgrade_to_premium': 'Upgrade to Premium',
        'premium': 'Premium',
        'puzzle_creation_failed': 'Puzzle creation failed: ',
        'unknown_error': 'Unknown error',

        // Main Navigation
        'friends': 'Friends',

        // Home Tabs
        'challenge': 'Challenge',
        'history': 'History',
        'recommend': 'Recommend',

        // Home Tab Content
        'daily_challenge': 'Daily Challenge',
        'streak_record': 'Streak Record',
        'recent_activity': 'Recent Activity',
        'weekly_leaderboard': 'Weekly Leaderboard',

        // Challenge Tab Content
        'daily_challenge_title': 'Daily Challenge',
        'daily_challenge_desc':
            'Complete puzzles with Bishop and Knight pieces.',
        'daily_challenge_reward': 'Reward: 50 points',
        'weekly_challenge': 'Weekly Challenge',
        'weekly_challenge_desc':
            'Complete 5 hard puzzles in a row within 10 minutes.',
        'weekly_challenge_reward': 'Reward: 200 points',

        // History Tab Content
        'statistics_summary': 'Statistics Summary',
        'completed_puzzles': 'Completed puzzles: 152',
        'average_time': 'Average time: 5:42',
        'success_rate': 'Success rate: 86%',
        'statistics_graph': 'Statistics Graph',
        'recent_records': 'Recent Records',

        // Recommend Tab Content
        'recommendations_for_you': 'Recommendations for You',
        'chess_master_pack': 'Chess Master Pack',
        'difficulty_hard_30_puzzles': 'Difficulty: Hard • 30 puzzles',
        'trending': 'Trending',

        // Pack Tabs
        'recommend_pack': 'Recommend',
        'difficulty_pack': 'By Difficulty',
        'theme_pack': 'By Theme',
        'progress_pack': 'In Progress',

        // Pack Tab Content
        'in_progress_packs': 'Packs in Progress',
        'difficulty_packs': 'Difficulty Packs',
        'theme_packs': 'Theme Packs',
        'try_again': 'Try Again',

        // Pack Card
        'puzzles': 'puzzles',

        // Notice Screen
        'notifications': 'Notifications',
        'all': 'All',
        'all_notifications': 'All Notifications',
        'friend_notifications': 'Friend Notifications',
        'game_notifications': 'Game Notifications',
        'system_notifications': 'System Notifications',

        // Language Settings
        'language_changed_to': ' language changed',
        'downloading_language': 'downloading...',
      },
    ),
    LanguagePack(
      id: 'ko_KR',
      name: 'Korean',
      nativeName: '한국어',
      languageCode: 'ko',
      countryCode: 'KR',
      isDownloaded: false,
      isDefault: false,
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      downloadSize: 1024000, // 1MB
      translations: {
        'app_name': 'CheSudoku',
        'loading': '로딩 중...',
        'downloading': '다운로드 중...',
        'download_complete': '다운로드 완료',
        'download_failed': '다운로드 실패',
        'home': '홈',
        'puzzle': '퍼즐',
        'pack': '팩',
        'profile': '프로필',
        'settings': '설정',
        'language_settings': '언어 설정',
        'select_language': '언어 선택',
        'download_language': '언어 다운로드',
        'current_language': '현재 언어',
        'available_languages': '사용 가능한 언어',
        'downloaded_languages': '다운로드된 언어',
        'update_available': '업데이트 사용 가능',
        'update': '업데이트',
        'delete': '삭제',
        'confirm': '확인',
        'cancel': '취소',
        'error': '오류',
        'success': '성공',
        'initializing': '초기화 중...',
        'sync_puzzle_packs': '퍼즐 팩 동기화 중...',
        'sync_language_packs': '언어 팩 동기화 중...',
        'sync_complete': '동기화 완료',
        'retry': '다시 시도',
        'download': '다운로드',
        'app_description': '체스와 스도쿠의 만남',
        'game_settings': '게임 설정',
        'sound_effects': '사운드 효과',
        'vibration': '진동',
        'theme_settings': '테마 설정',
        'general_settings': '일반 설정',
        'notification_settings': '알림 설정',
        'storage_management': '저장소 관리',
        'information': '정보',
        'help': '도움말',
        'app_info': '앱 정보',
        'privacy_policy': '개인정보 처리방침',

        // Game Screen
        'chess_sudoku_game': '체스도쿠 게임',
        'generated_puzzle_screen': '생성된 퍼즐을 표시할 화면입니다. (보드 사이즈: ',

        // Puzzle Creation
        'create_puzzle': '퍼즐 생성하기',
        'difficulty_easy': '쉬움',
        'difficulty_easy_desc': '체스 기물 1-2개',
        'difficulty_normal': '보통',
        'difficulty_normal_desc': '체스 기물 3-5개',
        'difficulty_hard': '어려움',
        'difficulty_hard_desc': '체스 기물 5-8개',
        'difficulty_expert': '전문가',
        'difficulty_expert_desc': '복잡한 기물 조합',
        'premium_subscription_required': '프리미엄 가입 후 이용 가능합니다',
        'upgrade_to_premium': '프리미엄으로 업그레이드',
        'premium': '프리미엄',
        'puzzle_creation_failed': '퍼즐 생성 실패: ',
        'unknown_error': '알 수 없는 오류',

        // Main Navigation
        'friends': '친구',

        // Home Tabs
        'challenge': '도전',
        'history': '기록',
        'recommend': '추천',

        // Home Tab Content
        'daily_challenge': '오늘의 도전',
        'streak_record': '연속 기록',
        'recent_activity': '최근 활동',
        'weekly_leaderboard': '주간 리더보드',

        // Challenge Tab Content
        'daily_challenge_title': '일일 도전',
        'daily_challenge_desc': '비숍과 나이트 기물이 포함된 퍼즐을 완료하세요.',
        'daily_challenge_reward': '보상: 50 포인트',
        'weekly_challenge': '주간 도전',
        'weekly_challenge_desc': '10분 이내에 어려운 퍼즐 5개를 연속으로 완료하세요.',
        'weekly_challenge_reward': '보상: 200 포인트',

        // History Tab Content
        'statistics_summary': '통계 요약',
        'completed_puzzles': '완료한 퍼즐: 152',
        'average_time': '평균 시간: 5:42',
        'success_rate': '성공률: 86%',
        'statistics_graph': '통계 그래프',
        'recent_records': '최근 기록',

        // Recommend Tab Content
        'recommendations_for_you': '당신을 위한 추천',
        'chess_master_pack': '체스 마스터 팩',
        'difficulty_hard_30_puzzles': '난이도: 어려움 • 30 퍼즐',
        'trending': '트렌딩',

        // Pack Tabs
        'recommend_pack': '추천',
        'difficulty_pack': '난이도별',
        'theme_pack': '테마별',
        'progress_pack': '진행 중',

        // Pack Tab Content
        'in_progress_packs': '진행 중인 팩',
        'difficulty_packs': '난이도별 팩',
        'theme_packs': '테마별 팩',
        'try_again': '다시 시도',

        // Pack Card
        'puzzles': '퍼즐',

        // Notice Screen
        'notifications': '알림',
        'all': '전체',
        'all_notifications': '전체 알림',
        'friend_notifications': '친구 알림',
        'game_notifications': '게임 알림',
        'system_notifications': '시스템 알림',

        // Language Settings
        'language_changed_to': '으로 언어가 변경되었습니다',
        'downloading_language': '다운로드 중...',
      },
    ),
    LanguagePack(
      id: 'ja_JP',
      name: 'Japanese',
      nativeName: '日本語',
      languageCode: 'ja',
      countryCode: 'JP',
      isDownloaded: false,
      isDefault: false,
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      downloadSize: 1200000, // 1.2MB
      translations: {
        'app_name': 'CheSudoku',
        'loading': '読み込み中...',
        'downloading': 'ダウンロード中...',
        'download_complete': 'ダウンロード完了',
        'download_failed': 'ダウンロード失敗',
        'home': 'ホーム',
        'puzzle': 'パズル',
        'pack': 'パック',
        'profile': 'プロフィール',
        'settings': '設定',
        'language_settings': '言語設定',
        'select_language': '言語選択',
        'download_language': '言語ダウンロード',
        'current_language': '現在の言語',
        'available_languages': '利用可能な言語',
        'downloaded_languages': 'ダウンロード済み言語',
        'update_available': 'アップデート利用可能',
        'update': 'アップデート',
        'delete': '削除',
        'confirm': '確認',
        'cancel': 'キャンセル',
        'error': 'エラー',
        'success': '成功',
        'initializing': '初期化中...',
        'sync_puzzle_packs': 'パズルパック同期中...',
        'sync_language_packs': '言語パック同期中...',
        'sync_complete': '同期完了',
        'retry': '再試行',
        'download': 'ダウンロード',
        'app_description': 'チェスとスドクの出会い',
        'game_settings': 'ゲーム設定',
        'sound_effects': 'サウンドエフェクト',
        'vibration': '振動',
        'theme_settings': 'テーマ設定',
        'general_settings': '一般設定',
        'notification_settings': '通知設定',
        'storage_management': 'ストレージ管理',
        'information': '情報',
        'help': 'ヘルプ',
        'app_info': 'アプリ情報',
        'privacy_policy': 'プライバシーポリシー',

        // Game Screen
        'chess_sudoku_game': 'チェス数独ゲーム',
        'generated_puzzle_screen': '生成されたパズルがここに表示されます。(ボードサイズ: ',

        // Puzzle Creation
        'create_puzzle': 'パズル作成',
        'difficulty_easy': '簡単',
        'difficulty_easy_desc': 'チェス駒1-2個',
        'difficulty_normal': '普通',
        'difficulty_normal_desc': 'チェス駒3-5個',
        'difficulty_hard': '難しい',
        'difficulty_hard_desc': 'チェス駒5-8個',
        'difficulty_expert': '専門家',
        'difficulty_expert_desc': '複雑な駒の組み合わせ',
        'premium_subscription_required': 'プレミアム加入後ご利用可能',
        'upgrade_to_premium': 'プレミアムにアップグレード',
        'premium': 'プレミアム',
        'puzzle_creation_failed': 'パズル作成失敗: ',
        'unknown_error': '不明なエラー',

        // Main Navigation
        'friends': '友達',

        // Home Tabs
        'challenge': 'チャレンジ',
        'history': '履歴',
        'recommend': 'おすすめ',

        // Home Tab Content
        'daily_challenge': '今日のチャレンジ',
        'streak_record': '連続記録',
        'recent_activity': '最近の活動',
        'weekly_leaderboard': '週間リーダーボード',

        // Challenge Tab Content
        'daily_challenge_title': 'デイリーチャレンジ',
        'daily_challenge_desc': 'ビショップとナイトの駒が含まれたパズルを完了してください。',
        'daily_challenge_reward': '報酬: 50ポイント',
        'weekly_challenge': 'ウィークリーチャレンジ',
        'weekly_challenge_desc': '10分以内に難しいパズルを5つ連続で完了してください。',
        'weekly_challenge_reward': '報酬: 200ポイント',

        // History Tab Content
        'statistics_summary': '統計概要',
        'completed_puzzles': '完了したパズル: 152',
        'average_time': '平均時間: 5:42',
        'success_rate': '成功率: 86%',
        'statistics_graph': '統計グラフ',
        'recent_records': '最近の記録',

        // Recommend Tab Content
        'recommendations_for_you': 'あなたへのおすすめ',
        'chess_master_pack': 'チェスマスターパック',
        'difficulty_hard_30_puzzles': '難易度: 難しい • 30パズル',
        'trending': 'トレンド',

        // Pack Tabs
        'recommend_pack': 'おすすめ',
        'difficulty_pack': '難易度別',
        'theme_pack': 'テーマ別',
        'progress_pack': '進行中',

        // Pack Tab Content
        'in_progress_packs': '進行中のパック',
        'difficulty_packs': '難易度別パック',
        'theme_packs': 'テーマ別パック',
        'try_again': '再試行',

        // Pack Card
        'puzzles': 'パズル',

        // Notice Screen
        'notifications': '通知',
        'all': 'すべて',
        'all_notifications': 'すべての通知',
        'friend_notifications': '友達の通知',
        'game_notifications': 'ゲーム通知',
        'system_notifications': 'システム通知',

        // Language Settings
        'language_changed_to': 'に言語が変更されました',
        'downloading_language': 'ダウンロード中...',
      },
    ),
    LanguagePack(
      id: 'zh_CN',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      languageCode: 'zh',
      countryCode: 'CN',
      isDownloaded: false,
      isDefault: false,
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      downloadSize: 1100000, // 1.1MB
      translations: {
        'app_name': 'CheSudoku',
        'loading': '加载中...',
        'downloading': '下载中...',
        'download_complete': '下载完成',
        'download_failed': '下载失败',
        'home': '首页',
        'puzzle': '谜题',
        'pack': '谜题包',
        'profile': '个人资料',
        'settings': '设置',
        'language_settings': '语言设置',
        'select_language': '选择语言',
        'download_language': '下载语言',
        'current_language': '当前语言',
        'available_languages': '可用语言',
        'downloaded_languages': '已下载语言',
        'update_available': '有可用更新',
        'update': '更新',
        'delete': '删除',
        'confirm': '确认',
        'cancel': '取消',
        'error': '错误',
        'success': '成功',
        'initializing': '初始化中...',
        'sync_puzzle_packs': '同步谜题包中...',
        'sync_language_packs': '同步语言包中...',
        'sync_complete': '同步完成',
        'retry': '重试',
        'download': '下载',
        'app_description': '国际象棋遇见数独',
        'game_settings': '游戏设置',
        'sound_effects': '音效',
        'vibration': '振动',
        'theme_settings': '主题设置',
        'general_settings': '常规设置',
        'notification_settings': '通知设置',
        'storage_management': '存储管理',
        'information': '信息',
        'help': '帮助',
        'app_info': '应用信息',
        'privacy_policy': '隐私政策',

        // Game Screen
        'chess_sudoku_game': '国际象棋数独游戏',
        'generated_puzzle_screen': '生成的谜题将在此显示。(棋盘大小: ',

        // Puzzle Creation
        'create_puzzle': '创建谜题',
        'difficulty_easy': '简单',
        'difficulty_easy_desc': '国际象棋棋子1-2个',
        'difficulty_normal': '普通',
        'difficulty_normal_desc': '国际象棋棋子3-5个',
        'difficulty_hard': '困难',
        'difficulty_hard_desc': '国际象棋棋子5-8个',
        'difficulty_expert': '专家',
        'difficulty_expert_desc': '复杂的棋子组合',
        'premium_subscription_required': '需要高级会员订阅',
        'upgrade_to_premium': '升级到高级版',
        'premium': '高级版',
        'puzzle_creation_failed': '谜题创建失败: ',
        'unknown_error': '未知错误',

        // Main Navigation
        'friends': '好友',

        // Home Tabs
        'challenge': '挑战',
        'history': '历史',
        'recommend': '推荐',

        // Home Tab Content
        'daily_challenge': '每日挑战',
        'streak_record': '连胜记录',
        'recent_activity': '最近活动',
        'weekly_leaderboard': '周排行榜',

        // Challenge Tab Content
        'daily_challenge_title': '每日挑战',
        'daily_challenge_desc': '完成包含主教和骑士棋子的谜题。',
        'daily_challenge_reward': '奖励: 50积分',
        'weekly_challenge': '每周挑战',
        'weekly_challenge_desc': '在10分钟内连续完成5个困难谜题。',
        'weekly_challenge_reward': '奖励: 200积分',

        // History Tab Content
        'statistics_summary': '统计摘要',
        'completed_puzzles': '已完成谜题: 152',
        'average_time': '平均时间: 5:42',
        'success_rate': '成功率: 86%',
        'statistics_graph': '统计图表',
        'recent_records': '最近记录',

        // Recommend Tab Content
        'recommendations_for_you': '为你推荐',
        'chess_master_pack': '国际象棋大师包',
        'difficulty_hard_30_puzzles': '难度: 困难 • 30个谜题',
        'trending': '热门',

        // Pack Tabs
        'recommend_pack': '推荐',
        'difficulty_pack': '按难度',
        'theme_pack': '按主题',
        'progress_pack': '进行中',

        // Pack Tab Content
        'in_progress_packs': '进行中的包',
        'difficulty_packs': '难度包',
        'theme_packs': '主题包',
        'try_again': '重试',

        // Pack Card
        'puzzles': '谜题',

        // Notice Screen
        'notifications': '通知',
        'all': '全部',
        'all_notifications': '全部通知',
        'friend_notifications': '好友通知',
        'game_notifications': '游戏通知',
        'system_notifications': '系统通知',

        // Language Settings
        'language_changed_to': '语言已更改为',
        'downloading_language': '下载中...',
      },
    ),
  ];

  /// 서버에서 받아온 것처럼 시뮬레이션하는 데이터
  static Map<String, dynamic> getMockServerResponse() {
    return {
      'status': 'success',
      'data': {
        'languages': languagePacks.map((pack) => pack.toMap()).toList(),
        'version': '1.0.0',
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      }
    };
  }
}
