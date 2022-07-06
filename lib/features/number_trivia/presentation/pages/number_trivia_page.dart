import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_architecture_reso/injection_container.dart';

import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return const MessageDisplay(
                      message: 'Start searchingg!',
                    );
                  }
                  if (state is Error) {
                    return MessageDisplay(message: state.errorMessage);
                  }
                  if (state is Loaded) {
                    return TriviaDisplay(
                        numberTriviaEntity: state.triviaEntity);
                  }
                  if (state is Loading) {
                    return const LoadingWidget();
                  }

                  return Container();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const TriviaControls()
            ],
          ),
        ),
      ),
    );
  }
}
