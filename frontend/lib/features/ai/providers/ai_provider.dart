import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/ai_message.dart';

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref.read(apiClientProvider));
});

class AiChatState {
  final List<AiMessage> messages;
  final List<String> suggestions;
  final bool loading;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.suggestions = const [
      'How can I save faster?',
      'What should I prioritize?',
      'Give me saving tips',
      'How do I stay motivated?',
    ],
    this.loading = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    List<String>? suggestions,
    bool? loading,
    String? error,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        suggestions: suggestions ?? this.suggestions,
        loading: loading ?? this.loading,
        error: error,
      );
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final ApiClient _api;

  AiChatNotifier(this._api) : super(const AiChatState());

  Future<void> sendMessage(String question, {String? goalId}) async {
    final userMsg = AiMessage(
      text: question,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      loading: true,
      suggestions: [],
      error: null,
    );

    try {
      final res = await _api.post<Map<String, dynamic>>('/ai/advice', data: {
        'question': question,
        if (goalId != null) 'goalId': goalId,
      });

      final data = res.data!;
      final aiMsg = AiMessage(
        text: data['answer'] as String,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      final suggestions = (data['suggestedQuestions'] as List<dynamic>)
          .cast<String>();

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        suggestions: suggestions,
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Could not reach the AI advisor. Try again.',
      );
    }
  }

  void clear() => state = const AiChatState();
}
