import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/quiz_question_model/content_questions.dart';
import 'package:slidesync/data/models/quiz_question_model/quiz_question.dart';
import 'package:slidesync/data/repos/content_questions_repo.dart';
import 'package:slidesync/features/quiz/providers/quiz_screen_provider.dart';
import 'package:slidesync/features/quiz/ui/screens/quiz_screen.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';

class QuizListing extends ConsumerStatefulWidget {
  const QuizListing({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizListingState();
}

class _QuizListingState extends ConsumerState<QuizListing> {
  late final Future<List<ContentQuestions>> allQuestionsFuture;

  @override
  void initState() {
    super.initState();
    allQuestionsFuture = ContentQuestionsRepo.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarContainer(child: AppBarContainerChild(context.isDarkMode, title: "Questions available")),
      body: FutureBuilder(
        future: allQuestionsFuture,
        builder: (context, sp) {
          if (sp.hasData && sp.data != null) {
            return ListView.builder(
              padding: EdgeInsets.only(top: 12, bottom: 24),
              itemCount: sp.data!.length,
              itemBuilder: (context, index) {
                final curr = sp.data![index];
                log("${sp.data![index].questions.map((e) => QuestionParser.parse(e)).toList()}");
                //
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 8),
                  child: ListTile(
                    title: CustomText(curr.title),
                    subtitle: CustomText("${curr.questions.length} questions", fontSize: 12),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageAnimation.pageRouteBuilder(
                          QuizScreen(
                            config: QuizScreenConfig(questions: QuestionParser.parse(sp.data![index].questions[index])),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return Center(child: CircularLoadingIndicator());
        },
      ),
    );
  }
}
