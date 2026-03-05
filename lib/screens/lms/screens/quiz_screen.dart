import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/lms/quiz_answers.dart';
import 'package:socialv/network/lms_rest_apis.dart';
import 'package:socialv/screens/lms/components/finish_quiz_component.dart';
import 'package:socialv/screens/lms/components/locked_content_widget.dart';
import 'package:socialv/screens/lms/components/quiz_component.dart';
import 'package:socialv/screens/lms/components/start_quiz_component.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class QuizScreen extends StatefulWidget {
  final int quizId;
  final bool isLocked;
  final Function(bool) completeQuiz;

  QuizScreen({required this.quizId, this.isLocked = false, required this.completeQuiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  ProfileMenuStore quizScreenVars = ProfileMenuStore();

  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isLocked.validate()) getQuiz();
  }

  Future<void> getQuiz() async {
    quizScreenVars.setLoading(true);
    await getQuizById(quizId: widget.quizId).then((value) async {
      quizScreenVars.quiz = value;
      quizScreenVars.isFetched = true;

      if (value.results!.status.validate() == CourseStatus.started) {
        if (!lmsStore.quizList.any((element) => element.quizId == widget.quizId)) {
          value.questions.validate().forEach((e) {
            quizScreenVars.answers.add(Answers(questionId: e.id.validate().toString()));
          });

          lmsStore.quizList.add(QuizAnswers(
            quizId: widget.quizId,
            answers: quizScreenVars.answers,
            startQuizTime: DateTime.now().toString(),
            isHours: quizScreenVars.quiz.duration.validate().split(' ').last == 'hours',
          ));

          await setValue(SharePreferencesKey.LMS_QUIZ_LIST, jsonEncode(lmsStore.quizList));
        }
      }
      if (value.results!.results != null) {
        if (value.results!.results!.graduation.validate() == CourseStatus.passed) {
          widget.completeQuiz(true);
        } else {
          widget.completeQuiz(false);
        }
      }
      quizScreenVars.setLoading(false);
    }).catchError((e) {
      quizScreenVars.isError = true;
      quizScreenVars.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      onBack: () {
        if (quizScreenVars.isLoading) quizScreenVars.setLoading(false);
        finish(context, isChanged);
      },
      child: Stack(
        children: [
          if (widget.isLocked) LockedContentWidget(),
          Observer(builder: (context) {
            return quizScreenVars.isFetched
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        StartQuizComponent(
                          quiz: quizScreenVars.quiz,
                          callback: () {
                            getQuiz();
                          },
                        ).visible(quizScreenVars.quiz.results!.status.validate().isEmpty),
                        QuizComponent(
                          quiz: quizScreenVars.quiz,
                          callback: () {
                            isChanged = true;

                            if (quizScreenVars.isReviewQuiz) {
                              quizScreenVars.isReviewQuiz = false;
                            } else {
                              getQuiz();
                            }
                          },
                          answers: quizScreenVars.reviewAnswers,
                          isReviewQuiz: quizScreenVars.isReviewQuiz,
                        ).visible(quizScreenVars.quiz.results!.status.validate() == CourseStatus.started || quizScreenVars.isReviewQuiz),
                        FinishQuizComponent(
                          quiz: quizScreenVars.quiz,
                          onReview: (ans) {
                            quizScreenVars.isReviewQuiz = true;
                            quizScreenVars.reviewAnswers.addAll(ans);
                          },
                          onRetake: () {
                            isChanged = true;
                            quizScreenVars.isReviewQuiz = false;
                            quizScreenVars.reviewAnswers.clear();
                            getQuiz();
                          },
                        ).visible(quizScreenVars.quiz.results!.status.validate() == CourseStatus.completed && !quizScreenVars.isReviewQuiz),
                      ],
                    ),
                  )
                : Offstage();
          }),
          Observer(builder: (context) {
            return NoDataWidget(
              imageWidget: NoDataLottieWidget(),
              title: language.noTopicsFound,
            ).visible(quizScreenVars.isError && !widget.isLocked);
          }),
        ],
      ),
    );
  }
}
