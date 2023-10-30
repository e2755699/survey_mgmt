import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey Form Mgmt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SurveyMgmt(),
    );
  }
}

class SurveyMgmt extends StatelessWidget {
  final SurveyCubit _surveyCubit = SurveyCubit(SurveyData([]))..load();
  final ValueNotifier<String> _newSurveyName = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey Form MGMT"),
      ),
      body: BlocProvider<SurveyCubit>(
        create: (context) => _surveyCubit,
        child: Builder(
          builder: (context) {
            return BlocBuilder<SurveyCubit, SurveyData>(
                builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              _newSurveyName.value = value;
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () => _surveyCubit
                                .addNewSurveyFrom(_newSurveyName.value),
                            icon: Icon(Icons.add)),
                      ],
                    ),
                    ...state.surveyFormDatas
                        .map((surveyFormData) =>
                            SurveyFormWidget(surveyFormData))
                        .toList()
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

class SurveyFormWidget extends StatelessWidget {
  final SurveyFormCubit _surveyFormCubit;
  final ValueNotifier<LanguageType> _newLang = ValueNotifier(LanguageType.en);
  SurveyFormWidget(
    SurveyFormData _surveyFormData, {
    Key? key,
  })  : _surveyFormCubit = SurveyFormCubit(_surveyFormData),
        super(key: key);

  get _surveyFormData => _surveyFormCubit.state;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SurveyFormCubit>(
      create: (context) => _surveyFormCubit,
      child: Builder(builder: (context) {
        return BlocBuilder<SurveyFormCubit, SurveyFormData>(
          builder: (context, state) {
            return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1)),
                child: Column(
                  children: [
                    Text(_surveyFormData.name),
                    Row(
                      children: [
                        Text("lang"),
                        DropdownButton<LanguageType>(
                            items: LanguageType.values
                                .map((lang) => DropdownMenuItem(
                                      value: lang,
                                      child: Text(lang.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              _newLang.value = value ?? _newLang.value;
                            }),
                        IconButton(
                            onPressed: () =>
                                _surveyFormCubit.addNewLang(_newLang.value),
                            icon: Icon(Icons.add))
                      ],
                    ),
                    ...state.surveyFormByLangData
                        .map((e) => Text(e.languageType.name)),
                  ],
                ));
          },
        );
      }),
    );
  }
}

class SurveyFormCubit extends Cubit<SurveyFormData> {
  SurveyFormCubit(SurveyFormData initialState) : super(initialState);

  addNewLang(LanguageType value) {
    emit(SurveyFormData(
        state.name,
        List.from(state.surveyFormByLangData)
          ..add(SurveyFormByLangData(value))));
  }
}

enum LanguageType { en, th, id, vi }

class SurveyFormData {
  final String name;
  final List<SurveyFormByLangData> surveyFormByLangData;
  SurveyFormData(this.name, this.surveyFormByLangData);

  //todo 這段duplicate怎麼消除
  @override
  bool operator ==(Object other) {
    print(
        "identical(this, other) ${identical(this, other)} surveyFormByLangData.length :${surveyFormByLangData.length} other.surveyFormByLangData.length : ${(other is SurveyData) ? other.surveyFormDatas.length : 0}");
    return identical(this, other) ||
        other is SurveyData &&
            runtimeType == other.runtimeType &&
            surveyFormByLangData.length == other.surveyFormDatas.length;
  }

  // @override
  // int get hashCode => surveyFormByLangData.hashCode;
}

class SurveyFormByLangData {
  final LanguageType languageType;

  SurveyFormByLangData(this.languageType);
}

class SurveyCubit extends Cubit<SurveyData> {
  SurveyCubit(initialState) : super(initialState);

  void addNewSurveyFrom(String name) {
    //todo 怎麼handle一開始是空的lang form
    var surveyFormData = SurveyFormData(name, []);
    print("add new survey name : ${surveyFormData.name}");
    emit(SurveyData(List.from(state.surveyFormDatas)..add(surveyFormData)));
  }

  load() {}
}

class SurveyData {
  final List<SurveyFormData> surveyFormDatas;

  SurveyData(this.surveyFormDatas);

  @override
  bool operator ==(Object other) {
    print(
        "identical(this, other) ${identical(this, other)} surveyFormDatas.length :${surveyFormDatas.length} other.surveyFormDatas.length : ${(other is SurveyData) ? other.surveyFormDatas.length : 0}");
    return identical(this, other) ||
        other is SurveyData &&
            runtimeType == other.runtimeType &&
            surveyFormDatas.length == other.surveyFormDatas.length;
  }
  //todo 這是幹啥的？
  // @override
  // int get hashCode => surveyFormDatas.hashCode;
}

class SurveyBaseData {
  final int id;

  SurveyBaseData(this.id);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SurveyData && runtimeType == other.runtimeType && id == id;
  }
}
