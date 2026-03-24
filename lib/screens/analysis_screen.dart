import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import '../model/review_workout.dart';
import '../model/workout_set.dart';
import '../model/daily_nutrition.dart';
import '../model/body_weight_log.dart';
import '../model/sleep_log.dart';
import '../model/user_profile.dart';

@immutable
class AnalysisMetric{
  final String id;
  final String name;
  final String category;

  const AnalysisMetric({
    required this.id,
    required this.name,
    required this.category,
  });

  @override
  bool operator==(Object other)=>
      identical(this, other) || 
      other is AnalysisMetric &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

class DailyAnalysisData{
  final DateTime date;
  final Map<String,double> values;  //metrics.id をキーとして持つ

  DailyAnalysisData({required this.date, required this.values});
}

class AnalysisScreen extends StatefulWidget{

  final List<ReviewWorkout> allWorkouts;
  final List<DailyNutrition> allDailyNutrition;
  final List<SleepLog> allSleepLogs;
  final List<BodyWeightLog> allBodyWeightLogs;
  final Map<String,List<String>> exerciseMenu;
  final UserProfile userProfile;

  const AnalysisScreen({
    super.key,
    required this.allWorkouts,
    required this.allDailyNutrition,
    required this.allSleepLogs,
    required this.allBodyWeightLogs,
    required this.exerciseMenu,
    required this.userProfile,
  });

  @override
  State<AnalysisScreen> createState()=>_AnalysisScreenState();
}

enum AnalysisPeriod { week, month, threeMonths, sixMonths, year, thousandDays}

class _AnalysisScreenState extends State<AnalysisScreen>{

  List<AnalysisMetric> _lineChartMetrics=[];
  AnalysisMetric? _scatterXMetric;
  AnalysisMetric? _scatterYMetric;
  List<AnalysisMetric> _availableMetrics=[];

  late DateTimeRange _dateRange;
  int _daysInView = 7; // 表示する日数（週間表示）
  double _dragOffset = 0.0; // ドラッグによるピクセル単位のズレ
  List<DailyAnalysisData> _lineChartData=[];
  List<DailyAnalysisData> _scatterPlotAllData=[];
  bool _isLoading=true; 
  final List<int> _dateIntervals = [7, 14, 30, 90, 180, 365,1000]; // 日数
  int _currentIntervalIndex = 0; // 現在の期間を指すインデックス (初期値は7日間)

  Map<DateTime,ReviewWorkout> _workoutMap={};
  Map<DateTime,DailyNutrition> _nutritionMap={};
  Map<DateTime,SleepLog> _sleepMap={};
  Map<DateTime,BodyWeightLog> _bodyWeightMap={};

  AnalysisPeriod _selectedPeriod=AnalysisPeriod.week;
  int _getDaysForPeriod(AnalysisPeriod period){
    switch(period){
      case AnalysisPeriod.week: return 7;
      case AnalysisPeriod.month: return 30;
      case AnalysisPeriod.threeMonths: return 90;
      case AnalysisPeriod.sixMonths: return 180;
      case AnalysisPeriod.year: return 365;
      case AnalysisPeriod.thousandDays: return 1000;
    }
  }

  String _getPeriodLabel(AnalysisPeriod period){
    switch (period) {
      case AnalysisPeriod.week: return '1週間';
      case AnalysisPeriod.month: return '1ヶ月';
      case AnalysisPeriod.threeMonths: return '3ヶ月';
      case AnalysisPeriod.sixMonths: return '半年';
      case AnalysisPeriod.year: return '1年';
      case AnalysisPeriod.thousandDays: return '1000日';
    }
  }

  @override
  void initState(){
    super.initState();
    _daysInView = _getDaysForPeriod(_selectedPeriod); // 初期化
    _updateDateRange(); // 日付範囲の計算をメソッド化
    _buildAvailableMetrics();
    _buildDataMaps();
    _prepareAllChartData();
  }

  void _updateDateRange({DateTime? endDate}) {
    final rawEnd = endDate ?? DateTime.now();
    
    final endAtMidnight = DateTime(rawEnd.year, rawEnd.month, rawEnd.day);
    
    _dateRange = DateTimeRange(
      start: endAtMidnight.subtract(Duration(days: _daysInView - 1)),
      end: endAtMidnight,
    );
  }

  @override
  void didUpdateWidget(covariant AnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allWorkouts != oldWidget.allWorkouts ||
        widget.allDailyNutrition != oldWidget.allDailyNutrition ||
        widget.allSleepLogs != oldWidget.allSleepLogs ||
        widget.allBodyWeightLogs != oldWidget.allBodyWeightLogs) {
      _buildAvailableMetrics();
      _prepareAllChartData();
    }
  }

  void _buildDataMaps(){
    _workoutMap={for(var e in widget.allWorkouts) DateTime(e.date.year, e.date.month, e.date.day) :e};
    _nutritionMap={for(var e in widget.allDailyNutrition) DateTime(e.day.year, e.day.month, e.day.day) :e};
    _sleepMap={for(var e in widget.allSleepLogs) DateTime(e.date.year, e.date.month, e.date.day) :e};
    _bodyWeightMap={for(var e in widget.allBodyWeightLogs) DateTime(e.date.year, e.date.month, e.date.day) :e};
  }

  void _updateChart(){
    setState((){
      _prepareLineChartData();
    });
  }

  void _prepareAllChartData(){
    _prepareLineChartData();
    _prepareScatterPlotData();
  }

  bool isSameDay(DateTime a, DateTime b){
    return a.year==b.year && a.month==b.month && a.day==b.day;
  }

  double? _getWeightForDate(DateTime date){
    widget.allBodyWeightLogs.sort((a,b)=>b.date.compareTo(a.date));
    final exactLog=widget.allBodyWeightLogs.firstWhereOrNull((log)=>isSameDay(log.date, date));
    if(exactLog!=null) return exactLog.bodyWeight;

    final pastLogs=widget.allBodyWeightLogs.firstWhereOrNull((log)=>log.date.isBefore(date));
    if(pastLogs!=null) return pastLogs.bodyWeight;

    return null;
  }

  double _calculateDailyWeightTrainingCalories(ReviewWorkout workout, double weight){
    if(weight<=0) return 0;
    const mets=3.5;
    return mets * weight * ((workout.totalSets * 3.5)/60) * 1.05;
  }

  double _calculateDailyCardioCalories(ReviewWorkout workout, double weight){
    if(weight<=0) return 0;
    return workout.cardioLogs.fold(0.0, (sum,log)=> sum+log.totalCaloriesBurned(weight));
  }

  void _buildAvailableMetrics(){
    final metrics=<AnalysisMetric>[];

    //体重
    metrics.add(const AnalysisMetric(id:'body_weight', name:'体重[kg]', category:'体重'));
    metrics.add(const AnalysisMetric(id:'body_fat', name:'体脂肪率[%]', category:'体重'));
    metrics.add(const AnalysisMetric(id:'muscle_mass', name:'筋肉量[kg]', category:'体重'));

    //睡眠
    metrics.add(const AnalysisMetric(id:'sleep_log', name:'睡眠時間[min]', category:'睡眠'));

    //代謝
    metrics.add(const AnalysisMetric(id:'bmr', name:'基礎代謝 (BMR)[kcal]', category:'代謝'));
    metrics.add(const AnalysisMetric(id:'tdee', name:'総消費カロリー (TDEE)[kcal]', category:'代謝'));
    metrics.add(const AnalysisMetric(id:'burned_calories_total', name:'運動消費カロリー[kcal]', category:'代謝'));

    //食事
    metrics.add(const AnalysisMetric(id:'nutrition_calories', name:'摂取カロリー[kcal]', category:'食事'));
    metrics.add(const AnalysisMetric(id:'nutrition_protein', name:'タンパク質[g]', category:'食事'));
    metrics.add(const AnalysisMetric(id:'nutrition_fat', name:'脂質[g]', category:'食事'));
    metrics.add(const AnalysisMetric(id:'nutrition_carbs', name:'炭水化物[g]', category:'食事'));

    //トレーニング全体
    metrics.add(const AnalysisMetric(id:'workout_total_volume', name:'総トレーニングボリューム[kg]', category:'トレーニング全体'));

    //トレーニング(部位別)
    widget.exerciseMenu.forEach((part, exercises){
      metrics.add(AnalysisMetric(id:'part_volume_$part', name:'$part トレーニングボリューム[kg]', category:'部位別トレーニング'));
    });
    //トレーニング(BIG3)
    const big3=['ベンチプレス', 'スクワット', 'ローバースクワット', 'デッドリフト', 'ワイドデッドリフト'];
    final recordedExercises = widget.allWorkouts
        .expand((w) => w.ListOftodayLog)
        .map((log)=> log.exerciseName)
        .toSet();
    
    for(var exercise in big3){
      if(recordedExercises.contains(exercise)){
        metrics.add(AnalysisMetric(id:'workout_volume_$exercise', name:'$exercise トレーニングボリューム[kg]', category:'BIG3'));
        metrics.add(AnalysisMetric(id:'workout_max_weight_$exercise', name:'$exercise Max重量[kg]', category:'BIG3'));
        metrics.add(AnalysisMetric(id:'workout_max_rm_$exercise', name:'$exercise Max1RM[kg]', category:'BIG3'));
      }
    }

    setState((){
      _availableMetrics=metrics;
    });
  }

  DailyAnalysisData _calculateDataForDate(DateTime date){
    final values=<String,double>{};
    final dateAtMidnight=DateTime(date.year,date.month,date.day);

    //1.各種ログの取得
    final workoutLog = _workoutMap[dateAtMidnight];
    final nutritionLog = _nutritionMap[dateAtMidnight];
    final sleepLog = _sleepMap[dateAtMidnight];
    final bodyWeightLog = _bodyWeightMap[dateAtMidnight];
    double? bodyWeightForDate = bodyWeightLog?.bodyWeight;
    values['body_weight'] = bodyWeightForDate ?? 0;
    values['body_fat']= bodyWeightLog?.bodyFatPercentage ?? 0;
    values['muscle_mass']= bodyWeightLog?.muscleMass ?? 0;

    //2.その日の体重を決定=>なければ60kg
    final bodyWeightForCalc= bodyWeightForDate ?? _getWeightForDate(date) ?? 60.0;
      
    //3.各種分析対象の値を計算して、Mapに格納
    //睡眠
    values['sleep_log']= sleepLog!=null ? sleepLog.wakeUpTime.difference(sleepLog.sleepInTime).inMinutes.toDouble() : 0;
    //代謝
    final bmr=widget.userProfile.calculateBMR(bodyWeightForCalc);
    final tdee=widget.userProfile.calculateTDEE(bodyWeightForCalc);
    values['bmr']=bmr ?? 0;
    values['tdee']=tdee ?? 0;
    //食事
    values['nutrition_calories']=nutritionLog?.totalCalories ?? 0;
    values['nutrition_protein']=nutritionLog?.totalProtein ?? 0;
    values['nutrition_fat']=nutritionLog?.totalFat ?? 0;
    values['nutrition_carbs']=nutritionLog?.totalCarbs ?? 0;
    //トレーニング関連
    if(workoutLog!=null){
      final workoutCalories = _calculateDailyWeightTrainingCalories(workoutLog, bodyWeightForCalc) ?? 0.0;
      final cardioCalories = _calculateDailyCardioCalories(workoutLog, bodyWeightForCalc) ?? 0.0;
      values['burned_calories_total']=workoutCalories+cardioCalories;
      values['workout_total_volume']=workoutLog.totalVolume;
      //部位別ボリューム
      widget.exerciseMenu.forEach((part, exercisesInpart){
        double partVolume=0;
        for(var log in workoutLog.ListOftodayLog){
          if(exercisesInpart.contains(log.exerciseName)){
            partVolume += log.totalVolume;
          }
        }
        values['part_volume_$part']=partVolume;
      });
      //BIG3データ
      const big3=['ベンチプレス', 'スクワット', 'ローバースクワット', 'デッドリフト', 'ワイドデッドリフト'];
      for(var log in workoutLog.ListOftodayLog){
        if(big3.contains(log.exerciseName)){
          values['workout_volume_${log.exerciseName}']=log.totalVolume;
          final validWeights = log.set.map((s)=>s.weight).where((w)=> w>0);
          if(validWeights.isNotEmpty){
            values['workout_max_weight_${log.exerciseName}']=validWeights.reduce((a,b)=> a>b ? a : b);
          }
          final validRms = log.set.map((s)=>s.estimate1RM).where((w)=> w>0);
          if(validRms.isNotEmpty){
            values['workout_max_rm_${log.exerciseName}']=validRms.reduce((a,b)=> a>b ?a :b);
          }
        }
      }
    }
    return DailyAnalysisData(date:dateAtMidnight, values:values);
  }

  void _prepareLineChartData(){
    setState(()=> _isLoading=true);
    final List<DailyAnalysisData> preparedData=[];
    //期間内の毎日をループ
    for(int i=0; i<= _dateRange.end.difference(_dateRange.start).inDays; i++){
      final date= _dateRange.start.add(Duration(days:i));
      preparedData.add(_calculateDataForDate(date));
    }
    setState((){
      _lineChartData=preparedData;
      _isLoading=false;
    });
  }

  void _prepareScatterPlotData(){
    final allDates={
      ...widget.allWorkouts.map((e)=>DateTime(e.date.year, e.date.month, e.date.day)),
      ...widget.allDailyNutrition.map((e)=>DateTime(e.day.year, e.day.month, e.day.day)),
      ...widget.allSleepLogs.map((e)=>DateTime(e.date.year, e.date.month, e.date.day)),
      ...widget.allBodyWeightLogs.map((e)=>DateTime(e.date.year, e.date.month, e.date.day)),
    }.toSet().toList();
    if(allDates.isEmpty){
      setState(()=>_scatterPlotAllData=[]);
      return;
    }
    final preparedData=allDates.map((date)=>_calculateDataForDate(date)).toList();
    setState((){
      _scatterPlotAllData=preparedData;
    });
  }
  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      body:SingleChildScrollView(
        child:Column(
          children:[
            Padding(
              padding:const EdgeInsets.all(16.0),
              child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children:[
                  const SizedBox(height:48),
                  _buildLineChartSection(),
                  const Divider(height:48, color:Colors.white24),
                  _buildScatterPlotSection(),
                  const SizedBox(height:48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineChartSection(){
    //グラフの色を指定
    final lineColors=[Colors.cyan, Colors.green, Colors.yellow, Colors.pink, Colors.orange];

    if (_lineChartMetrics.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child:Text(
              '時系列グラフ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          const SizedBox(height: 8),
          const Text('期間内の数値の推移を分析します。',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showLineChartMetricSelectionDialog,
                icon: const Icon(Icons.checklist),
                label: const Text('分析する指標を選択'),
              ),
              SizedBox(width:10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<AnalysisPeriod>(
                  value: _selectedPeriod,
                  dropdownColor: const Color(0xFF1e3a5f),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                  style: const TextStyle(color: Colors.white),
                  items: AnalysisPeriod.values.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(_getPeriodLabel(period)),
                    );
                  }).toList(),
                  onChanged: (AnalysisPeriod? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                        _daysInView = _getDaysForPeriod(newValue);
                        // 期間変更時は、最新の日付（今日）を基準にリセット
                        _updateDateRange(endDate: DateTime.now());
                      });
                      _prepareLineChartData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 350,
            alignment: Alignment.center,
            child: const Text('分析対象を選択してください',
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      );
    }

    String? leftAxisUnit;
    String? leftAxisCategory;
    String? rightAxisUnit;
    String? rightAxisCategory;
    final List<AnalysisMetric> leftMetrics=[];
    final List<AnalysisMetric> rightMetrics=[];

    final firstMertic=_lineChartMetrics.first;
    leftAxisUnit=_getUnitForMetric(firstMertic.id);
    leftAxisCategory=firstMertic.category;
    leftMetrics.add(firstMertic);

    for(int i=1; i<_lineChartMetrics.length; i++){
      final metric=_lineChartMetrics[i];
      final unit=_getUnitForMetric(metric.id);
      final category=metric.category;
      if (rightAxisUnit == null) {
            if (unit != leftAxisUnit) {
                rightAxisUnit = unit;
                rightMetrics.add(metric);
            } else if (category != leftAxisCategory) {
                rightAxisUnit = unit;
                rightAxisCategory = category;
                rightMetrics.add(metric);
            } else {
                leftMetrics.add(metric);
            }
        } else {
            final isRightUnit = unit == rightAxisUnit;
            final isRightCategory = rightAxisCategory != null ? category == rightAxisCategory : true;

            if (isRightUnit && isRightCategory) {
                rightMetrics.add(metric);
            } else {
                leftMetrics.add(metric);
            }
        }
    }
    
    final bool useDualAxis=rightMetrics.isNotEmpty;
    final allUnits = _lineChartMetrics.map((m)=>_getUnitForMetric(m.id)).toSet();
    final bool canDrawChart = allUnits.length <= 2;

    double minYLeft=0, maxYLeft=1;
    double minYRight=0, maxYRight=1;

    final leftValues=_lineChartData
          .expand((d)=>leftMetrics.map((m)=>d.values[m.id] ?? 0))
          .where((v)=> v>0);
    if(leftValues.isNotEmpty){
      minYLeft=leftValues.reduce((a,b)=> a<b ?a :b);
      maxYLeft=leftValues.reduce((a,b)=> a>b ?a :b);
    }

    var verticalPaddingLeft=(maxYLeft-minYLeft)*0.15;
      minYLeft =(minYLeft-verticalPaddingLeft).floorToDouble();
      if(minYLeft<0) minYLeft=0;
      maxYLeft =(maxYLeft+verticalPaddingLeft).ceilToDouble();
      if(maxYLeft <= minYLeft) maxYLeft=minYLeft+1;

    
    if(useDualAxis){
      final rightValues=_lineChartData
          .expand((d)=>rightMetrics.map((m)=>d.values[m.id] ?? 0))
          .where((v)=> v>0);
      if(rightValues.isNotEmpty){
        minYRight=rightValues.reduce((a,b)=> a<b ?a :b);
        maxYRight=rightValues.reduce((a,b)=> a>b ?a :b);
      }
      var verticalPaddingRight=(maxYRight-minYRight)*0.35;
      minYRight =(minYRight-verticalPaddingRight).floorToDouble();
      if(minYRight<0) minYRight=0;
      maxYRight =(maxYRight+verticalPaddingRight).ceilToDouble();
      if(maxYRight<=minYRight) maxYRight=minYRight+1;
    }

    //グラフデータの生成
    final List<LineChartBarData> lineBars=[];
    final allMetricsInOrder=[...leftMetrics, ...rightMetrics];

    for(var metric in allMetricsInOrder){
      final index=_lineChartMetrics.indexOf(metric);
      final isRightAxisMetric=rightMetrics.contains(metric);

      final validDataPoints=_lineChartData.where((data){
        final value=data.values[metric.id] ?? 0;
        return value>0;
      }).toList();
      final spots=validDataPoints.map((data){
        final xValue=data.date.difference(_dateRange.start).inDays.toDouble();
        final rawValue=data.values[metric.id]!;
        if(isRightAxisMetric){
          //右側のデータを左側のデータスケールに正規化
          final rangeRight = maxYRight - minYRight;
          final rangeLeft = maxYLeft - minYLeft;
          if(rangeLeft==0 || rangeRight==0) return FlSpot(xValue, minYLeft);
          final normalizedY = ((rawValue-minYRight)/rangeRight)*rangeLeft + minYLeft;
          return FlSpot(xValue, normalizedY);
        }else{
          return FlSpot(xValue, rawValue);
        }
      }).toList();

      lineBars.add(LineChartBarData(
        spots:spots,
        isCurved:false,
        color:lineColors[index % lineColors.length],
        barWidth:2,
        dotData: const FlDotData(show:true),
        dashArray: isRightAxisMetric ?[4,4] :null,
      ));
    }

    ExtraLinesData? extraLinesData;
    if(useDualAxis){
      final List<HorizontalLine> rightAxisLine=[];
      final rangeRight=maxYRight-minYRight;
      final interval=_getNiceInterval(rangeRight);
      //初めの目盛を計算
      final firstLabel=(minYRight/interval).ceil()*interval;
      //キリのいい目盛を最大値まで追加
      for(double currentLabel=firstLabel;
        currentLabel<=maxYRight;
        currentLabel+=interval){
          //キリのいい値を左軸上の正確な高さに変換
          final normalizedY=((currentLabel-minYRight)/rangeRight)*(maxYLeft-minYLeft)+minYLeft;
          rightAxisLine.add(
            HorizontalLine(
              y:normalizedY,
              color:Colors.white24,
              strokeWidth:0.8,
              dashArray:[4,4],
              label:HorizontalLineLabel(
                show:true,
                labelResolver:(_)=>currentLabel.toInt().toString(),
                alignment:Alignment.topRight,
                padding:const EdgeInsets.only(right:4,bottom:2),
                style:const TextStyle(color:Colors.white70, fontSize:10),
              ),
            ),
          );
        }
      extraLinesData=ExtraLinesData(horizontalLines: rightAxisLine);
    }

    return Listener(//スクロールを感知するリスナー
      onPointerSignal:(pointerSignal){
        if(pointerSignal is PointerScrollEvent){
          final centerDate=_dateRange.start.add(Duration(days:_dateRange.duration.inDays ~/2));
          setState((){
            if(pointerSignal.scrollDelta.dy > 0 && _currentIntervalIndex<_dateIntervals.length-1){
              _currentIntervalIndex++;
            }
            else if(pointerSignal.scrollDelta.dy < 0 && _currentIntervalIndex>0){
              _currentIntervalIndex--;
            }
            final newDaysInView=_dateIntervals[_currentIntervalIndex];
            _daysInView=newDaysInView;
            _dateRange=DateTimeRange(
              start:centerDate.subtract(Duration(days: newDaysInView ~/2)),
              end:centerDate.add(Duration(days: newDaysInView - (newDaysInView ~/2) - 1)),
            );
          });
          _prepareLineChartData();
        }
      },
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children:[
          const Text('時系列グラフ', style:TextStyle(color:Colors.white, fontSize:24,fontWeight:FontWeight.bold)),
          const SizedBox(height:8),
          const Text('期間内の数値の推移を分析します。', style:TextStyle(color:Colors.white54)),
          const SizedBox(height:16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed:_showLineChartMetricSelectionDialog,
                icon:const Icon(Icons.checklist),
                label:const Text('分析する指標を選択'),
              ),
              SizedBox(width:10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<AnalysisPeriod>(
                  value: _selectedPeriod,
                  dropdownColor: const Color(0xFF1e3a5f),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                  style: const TextStyle(color: Colors.white),
                  items: AnalysisPeriod.values.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(_getPeriodLabel(period)),
                    );
                  }).toList(),
                  onChanged: (AnalysisPeriod? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                        _daysInView = _getDaysForPeriod(newValue);
                        // 期間変更時は、最新の日付（今日）を基準にリセット
                        _updateDateRange(endDate: DateTime.now());
                      });
                      _prepareLineChartData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height:16),
          Container(
            height:350,
            child:GestureDetector(
              onHorizontalDragUpdate: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                final dayWidth = screenWidth / _daysInView;
                final daysToShift = (details.primaryDelta! / screenWidth * _daysInView).round();
                if (daysToShift != 0) {
                  setState(() {
                    // スワイプ方向とは逆に日付を動かす（左スワイプで未来、右で過去）
                    // 感覚に合わせて符号は調整してください（ここでは直感的に右に引くと過去が見えるように）
                    final newEnd = _dateRange.end.subtract(Duration(days: daysToShift));
                    _updateDateRange(endDate: newEnd);
                  });
                  _prepareLineChartData();
                }
              },
              child:  _isLoading
                  ? const Center(child:CircularProgressIndicator())
                  : _lineChartMetrics.isEmpty
                      ? const Center(child:Text('分析対象を選択してください', style:TextStyle(color:Colors.white70)))
                      : !canDrawChart
                          ? const Center(child:Text('比較できる単位は二種類までです', style:TextStyle(color:Colors.white)))
                          : LineChart(
                              LineChartData(
                                //ツールチップ設定
                                extraLinesData:extraLinesData,
                                lineTouchData:LineTouchData(
                                  touchTooltipData:LineTouchTooltipData(
                                    getTooltipItems:(touchedSpots){
                                      return touchedSpots.map((spot){
                                        final dataIndex=_lineChartData.indexWhere((d)=>d.date.difference(_dateRange.start).inDays.toDouble()==spot.x);
                                        if(dataIndex==-1)return null;

                                        final metric=_lineChartMetrics[spot.barIndex];
                                        final originalValue = _lineChartData[dataIndex].values[metric.id] ?? 0;
                                        final isRightAxis = rightMetrics.contains(metric);

                                        return LineTooltipItem(
                                          // 右軸のツールチップなら先頭に改行を追加してずらす
                                        '${isRightAxis ? '\n' : ''}${metric.name.split('[')[0]}\n${originalValue.toStringAsFixed(1)} ${_getUnitForMetric(metric.id)}',
                                        TextStyle(color: spot.bar.color ?? Colors.white, fontWeight: FontWeight.bold),
                                        );
                                      }).whereNotNull().toList();
                                    }
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false, // 縦のグリッド線は非表示
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(color: Colors.white70, strokeWidth: 0.8);
                                  },
                                ),
                                titlesData:_buildChartTitles(
                                  isDualAxis:useDualAxis,
                                  leftUnit:leftAxisUnit, 
                                  rightAxisUnit:rightAxisUnit ?? '',
                                ),
                                borderData:FlBorderData(
                                  show:true,
                                  border:Border.all(color:Colors.white70),
                                ),
                                minX:0,
                                maxX:(_daysInView-1).toDouble(),
                                minY: minYLeft,
                                maxY: maxYLeft,
                                //複数の分析対象をグラフに描画
                                lineBarsData:lineBars,
                              ),
                            ),
            ),
          ),
          //凡例を表示
          if(_lineChartMetrics.isNotEmpty) ...[
            const SizedBox(height:16),
            Wrap(
              spacing:16.0,
              runSpacing:8.0,
              children:_lineChartMetrics.mapIndexed((index,metric){
                return Row(
                  mainAxisSize:MainAxisSize.min,
                  children:[
                    Container(width:12, height:12, color:lineColors[index % lineColors.length]),
                    const SizedBox(width:8),
                    Text(metric.name, style:const TextStyle(color:Colors.white70)),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  double? _getIntervalForUnit(String unit, String? metricId) {
    switch (unit) {
      case 'kcal': return 200;
      case 'min': return 60;
      case 'g': return 50;
      case '%': return 2;
      case 'kg':
        if (metricId == null) return 1000;
        if (metricId.contains('total_volume')) return 1000;
        if (metricId.contains('part_volume')) return 500;
        if (metricId.contains('workout_volume')) return 250; // BIG3
        if (metricId.contains('max_weight') || metricId.contains('max_rm')) return 5;
        if (metricId.contains('body_weight')) return 2; // 体重
        return 500;
      default: return null;
    }
  }

  double _getNiceInterval(double range){
    if(range<=0)return 1;
    //範囲を元に、キリのいい単位を探す。
    final exponent=(log(range)/ln10).floor();
    final double magnitude = pow(10, exponent).toDouble();
    final double residual = range/magnitude;

    if(residual>5){
      return 10*magnitude/5; //e.g. range=800 => interval=200
    }else if(residual>2){
      return 5*magnitude/5; //e.g. range=400 => interval=100
    }else{
      return 2*magnitude/5; //e.g. range=400 => interval=100
    }
  }

  String _getUnitForMetric(String metricId) {
    if (metricId.contains('calories') || metricId.contains('bmr') || metricId.contains('tdee')) return 'kcal';
    if (metricId.contains('weight') || metricId.contains('muscle_mass')) return 'kg';
    if (metricId.contains('body_fat')) return '%';
    if (metricId.contains('protein') || metricId.contains('fat') || metricId.contains('carbs')) return 'g';
    if (metricId.contains('sleep_log')) return 'min';
    if (metricId.contains('volume') || metricId.contains('rm')) return 'kg'; // Volumeもkgベース
    return '';
  }

  double _getMaxYForUnit(String unit) {
    double maxVal = 0;
    for (var data in _lineChartData) {
      for (var metric in _lineChartMetrics) {
        if (_getUnitForMetric(metric.id) == unit) {
          final val = data.values[metric.id] ?? 0;
          if (val > maxVal) {
            maxVal = val;
          }
        }
      }
    }
    return maxVal > 0 ? maxVal * 1.2 : 1.0; // 少し余裕を持たせる
  }

  Widget _buildScatterPlotSection(){
    return Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:[
        const Center(child:Text('相関グラフ',style:TextStyle(color:Colors.white, fontSize:24, fontWeight:FontWeight.bold)),),
        const SizedBox(height:8),
        const Text('2つの指標の関連性を散布図で確認できます。',style:TextStyle(color:Colors.white)),
        const SizedBox(height:16),
        Row(
          children:[
            Expanded(
              child:DropdownButtonFormField<AnalysisMetric>(
                value:_scatterXMetric,
                isExpanded: true,
                style:TextStyle(overflow:TextOverflow.ellipsis,),
                hint:const Text('X軸を選択',style:TextStyle(color:Colors.white70)),
                dropdownColor:const Color(0xFF1e3a5f),
                decoration:const InputDecoration(
                  border:OutlineInputBorder(),
                  labelText:'X軸',
                  labelStyle:TextStyle(color:Colors.white),
                ),
                items:_availableMetrics.map((metric)=>DropdownMenuItem(
                  value:metric,
                  child:Text(metric.name, style:TextStyle(color:Colors.white)),
                )).toList(),
                onChanged:(value)=>setState(()=>_scatterXMetric=value),
              ),
            ),
            const SizedBox(width:10),
            Expanded(
              child:DropdownButtonFormField<AnalysisMetric>(
                value:_scatterYMetric,
                isExpanded: true,
                style:TextStyle(overflow:TextOverflow.ellipsis,),
                hint:const Text('Y軸を選択',style:TextStyle(color:Colors.white70)),
                dropdownColor:const Color(0xFF1e3a5f),
                decoration:const InputDecoration(
                  border:OutlineInputBorder(),
                  labelText:'Y軸',
                  labelStyle:TextStyle(color:Colors.white),
                ),
                items:_availableMetrics.map((metric)=>DropdownMenuItem(
                  value:metric,
                  child:Text(metric.name, style:TextStyle(color:Colors.white)),
                )).toList(),
                onChanged:(value)=>setState(()=>_scatterYMetric=value),
              ),
            ),
          ],
        ),
        const SizedBox(height:16),
        Container(
          height:400,
          padding:EdgeInsets.only(top:24, right:24, left:6, bottom:16),
          decoration:BoxDecoration(
            border:Border.all(color:Colors.white24),
            borderRadius:BorderRadius.circular(8),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_scatterXMetric == null || _scatterYMetric == null)
                  ? const Center(child:Text('X軸とY軸の両方を選択してください',style:TextStyle(color:Colors.white)))
                    : Builder(builder:(context){ 
                        final validScatterData=_scatterPlotAllData.where((data){
                          final x=data.values[_scatterXMetric!.id] ?? 0;
                          final y=data.values[_scatterYMetric!.id] ?? 0;
                          return x>0 && y>0;
                        }).toList();
                        if(validScatterData.isEmpty){
                          return const Center(child:Text('表示できるデータがありません', style:TextStyle(color:Colors.white70),),);
                        }
                        final spots=validScatterData.map((data){
                          final x=data.values[_scatterXMetric!.id] ?? 0;
                          final y=data.values[_scatterYMetric!.id] ?? 0;
                          return ScatterSpot(
                            x,
                            y,
                            dotPainter:FlDotCirclePainter(color:Colors.tealAccent),
                          );
                        }).toList();
                        final minX=spots.map((s)=>s.x).reduce(min);
                        final maxX=spots.map((s)=>s.x).reduce(max);
                        final minY=spots.map((s)=>s.y).reduce(min);
                        final maxY=spots.map((s)=>s.y).reduce(max);
                        final xPadding=(maxX-minX)*0.1;
                        final yPadding=(maxY-minY)*0.1;
                        final finalMinX=(minX==maxX) ? minX-1 : minX-xPadding;
                        final finalMaxX=(minX==maxX) ? maxX+1 : maxX+xPadding;
                        final finalMinY=(minY==maxY) ? minY-1 : minY-yPadding;
                        final finalMaxY=(minY==maxY) ? maxY+1 : maxY+yPadding;

                        final xInterval=_getNiceInterval(finalMaxX-finalMinX);
                        final yInterval=_getNiceInterval(finalMaxY-finalMinY);

                        return ScatterChart(
                          ScatterChartData(
                            scatterSpots: spots,
                            minX:finalMinX,
                            maxX:finalMaxX,
                            minY:finalMinY,
                            maxY:finalMaxY,
                            gridData: const FlGridData(show:false),
                            borderData:FlBorderData(show:true, border:Border.all(color:Colors.white70)),
                            titlesData:_buildChartTitles(
                              isScatter:true,
                              scatterXInterval:xInterval,
                              scatterYInterval:yInterval,
                            ),
                            scatterTouchData:ScatterTouchData(
                              enabled:true,
                              touchTooltipData:ScatterTouchTooltipData(
                                getTooltipColor:(spot)=>Colors.black.withOpacity(0.8),
                                getTooltipItems:(touchedSpot){
                                  final dataPoint=validScatterData.firstWhereOrNull(
                                    (d)=> d.values[_scatterXMetric!.id]==touchedSpot.x && d.values[_scatterYMetric!.id]==touchedSpot.y
                                  );
                                  if(dataPoint==null){return null;}
                                  final dateText=DateFormat('M/d').format(dataPoint.date);
                                  final xValue=touchedSpot.x.toStringAsFixed(1);
                                  final yValue=touchedSpot.y.toStringAsFixed(1);
                                  final xMetricName=_scatterXMetric!.name.split('[')[0];
                                  final yMetricName=_scatterYMetric!.name.split('[')[0];
                                  return ScatterTooltipItem(
                                    '$dateText\n$xMetricName: $xValue\n$yMetricName: $yValue',
                                    textStyle:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold),
                                    textAlign:TextAlign.center,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                    }),
        ),
      ],
    );
  }


  FlTitlesData _buildChartTitles({
    bool isScatter=false, bool isDualAxis=false,
    String leftUnit = '', String rightAxisUnit = '', 
    double? scatterXInterval, double? scatterYInterval,
  }){
    // --- 目盛り間隔を取得 ---
    final leftInterval = _getIntervalForUnit(leftUnit, _lineChartMetrics.firstWhereOrNull((m) => _getUnitForMetric(m.id) == leftUnit)?.id);
    
    final screenWidth=MediaQuery.of(context).size.width;
    final dayWidth = screenWidth/_daysInView;
    final daysShifted = _dragOffset/dayWidth;
    
    return FlTitlesData(
      topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
      rightTitles:AxisTitles(
        axisNameSize:22,
        sideTitles:SideTitles(
          showTitles: isDualAxis ? false : rightAxisUnit.isNotEmpty && !isScatter, // 散布図では右軸は使わない
          reservedSize:40,
          getTitlesWidget:(value, meta)=>const SizedBox.shrink(),
        ),
        axisNameWidget: rightAxisUnit.isNotEmpty && !isScatter 
            ? Text('[$rightAxisUnit]', style:const TextStyle(color:Colors.white70)) 
            : null,
      ),
      leftTitles: AxisTitles(
        axisNameSize:30,
        sideTitles:SideTitles(
          showTitles:true,
          reservedSize:40,
          interval: isScatter ? scatterYInterval : leftInterval,
          getTitlesWidget:(value, meta){
            if (value < meta.min || value > meta.max) return const SizedBox.shrink();
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            );
          }
        ),
        axisNameWidget: isScatter && _scatterYMetric!=null
            ? Text('${_scatterYMetric?.name.split('[')[0] ?? ''} [${_getUnitForMetric(_scatterYMetric!.id)}]', style: const TextStyle(color: Colors.white70))
            : Text('[$leftUnit]', style: const TextStyle(color: Colors.white70)),
      ),
      bottomTitles:AxisTitles(
        axisNameSize:22,
        sideTitles:SideTitles(
          showTitles:true,
          reservedSize:isScatter ?40 :40,
          interval: isScatter ? scatterXInterval :1,
          getTitlesWidget:(value, meta){
            if(isScatter){
              return Text(
                value.toInt().toString(),
                style:const TextStyle(color:Colors.white70, fontSize:10),
              );
            }else{
              // 折れ線グラフ用
              // 期間に応じた表示間隔の計算
              int interval;
              if (_daysInView <= 14) interval = 1; // 2週間以内なら毎日
              else if (_daysInView <= 30) interval = 5; // 1ヶ月なら5日ごと
              else if (_daysInView <= 90) interval = 14; // 3ヶ月なら2週間ごと
              else if (_daysInView <= 180) interval = 30; // 半年なら1ヶ月ごと
              else interval = 60; // 1年以上なら2ヶ月ごと

              final int intValue = value.toInt();
              final int maxIndex = _daysInView - 1;

              // 2. 描画するかどうかの判定
              // 基本はintervalごと、ただし「最後の点(今日)」は必ず表示し、その直前の点は重なるなら非表示にする
              bool shouldDraw = false;

              if (intValue == maxIndex) {
                // 右端（最新の日付）は必ず表示
                shouldDraw = true;
              } else if (intValue % interval == 0) {
                // 基本の間隔に合う場合
                // ただし、右端に近すぎる場合は表示しない（重なり防止）
                if (maxIndex - intValue > interval / 2) {
                    shouldDraw = true;
                }
              }

              if (shouldDraw) {
                final dateForValue = _dateRange.start.add(Duration(days: intValue));
                final today = DateTime.now();
                final bool isToday = isSameDay(dateForValue, today);

                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('M/d').format(dateForValue),
                    style: TextStyle(
                      color: isToday ? Colors.orangeAccent : Colors.white70,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
          }
        ),
        axisNameWidget: isScatter && _scatterXMetric!=null
            ? Text('${_scatterXMetric!.name.split('[')[0] ?? ''} [${_getUnitForMetric(_scatterXMetric!.id)}]', style: const TextStyle(color: Colors.white70))
            : null,
      ),
    );
  }

  

  void _showLineChartMetricSelectionDialog(){
    List<AnalysisMetric> tempSelectedMetrics=List.of(_lineChartMetrics);
    showModalBottomSheet(
      context:context,
      isScrollControlled:true,
      useSafeArea: true,
      builder:(context){
        final groupedMetrics=groupBy(_availableMetrics, (metric)=>metric.category);
        return StatefulBuilder(
          builder:(context, setDialogState){
            return SafeArea(
              child:Container(
                color:const Color(0xFF1e3a5f),
                child:Column(
                  mainAxisSize:MainAxisSize.min,
                  children:[
                    Padding(
                      padding:const EdgeInsets.all(16.0),
                      child:Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children:[
                          TextButton(
                            onPressed:()=>Navigator.pop(context),
                            child:Text('キャンセル', style:const TextStyle(color:Colors.white)),
                          ),
                          const Text('分析対象を選択',style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
                          TextButton(
                            onPressed:(){
                              setState((){
                                _lineChartMetrics=tempSelectedMetrics;
                              });
                              _updateChart();
                              Navigator.pop(context);
                            },
                            child:Text('適用', style:const TextStyle(color:Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color:Colors.white24, height:1),
                    Expanded(
                      child:ListView(
                        children:groupedMetrics.entries.map((entry){
                          return ExpansionTile(
                            title:Text(entry.key, style:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold)),
                            children:entry.value.map((metric){
                              return CheckboxListTile(
                                title:Text(metric.name, style:const TextStyle(color:Colors.white70)),
                                value:tempSelectedMetrics.contains(metric),
                                onChanged:(bool? selected){
                                  setDialogState((){
                                    if(selected==true){
                                      tempSelectedMetrics.add(metric);
                                    }else{
                                      tempSelectedMetrics.remove(metric);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    ).whenComplete(()=>setState(()=>_updateChart()));
  }
}