import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_concrete_number_trivia_usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_architecture_reso/injection_container.dart';

import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: buildBody(context),
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
              TriviaControls()
            ],
          ),
        ),
      ),
    );
  }
}

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  String inputString = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: ((value) {
            inputString = value;
          }),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: emitConcrete, child: Text('Search'))),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                  onPressed: emitRandom, child: Text('Get random trivia')),
            ),
          ],
        )
      ],
    );
  }

  void emitConcrete() {
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputString));
  }

  void emitRandom() {
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
