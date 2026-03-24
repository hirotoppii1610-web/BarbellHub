import 'dart:math';
import 'package:flutter/material.dart';

class SleepClockPainter extends CustomPainter{
  final DateTime sleepInTime;
  final DateTime wakeUpTime;

  SleepClockPainter({required this.sleepInTime, required this.wakeUpTime});

  @override
  void paint(Canvas canvas, Size size){
    final center=Offset(size.width/2, size.height/2);
    final radius=size.width/2;
    
    //1.睡眠時間の円弧をかく
    final sleepDuration=wakeUpTime.difference(sleepInTime);
    //2.時間を12時間制の円弧に変化
    double timeToAngle(DateTime time){
      final hour=time.hour %12 + time.minute/60 ;
      return (hour/12 *2*pi)-(pi/2);
    }
    //開始角度
    final startAngle=timeToAngle(sleepInTime);
    //睡眠時間を角度に
    final totalSweepAngle=(sleepDuration.inMinutes/(12*60))*2*pi;
    //12時間とそれ以上を計算
    final baseSweepAngle=min(totalSweepAngle, 2*pi);
    final overlapSweepAngle=totalSweepAngle-baseSweepAngle;
    //薄い水色を塗る(12時間以内)
    final baseArcPaint=Paint()..color=Colors.lightBlue.withOpacity(0.3);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), 
      startAngle,  
      baseSweepAngle, 
      true,
      baseArcPaint,
    );
    if(overlapSweepAngle>0){
      final overlapArcPaint=Paint()..color=Colors.lightBlue.withOpacity(0.6);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 
        startAngle,  
        overlapSweepAngle, 
        true,
        overlapArcPaint,
      );
    }
    //時計をかく
    final borderPaint=Paint()
      ..color=Colors.white
      ..style=PaintingStyle.stroke
      ..strokeWidth=2;
    canvas.drawCircle(center, radius, borderPaint);

    final centerPaint=Paint()..color=Colors.white;
    canvas.drawCircle(center, 6, centerPaint);
    //時計の数字を描画
    final textPainter=TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final textStyle=const TextStyle(color:Colors.white, fontSize: 20, fontWeight: FontWeight.bold);

    for(int i=1; i<=12; i++){
      final angle=(i/12*2*pi)-(pi/2);
      final position=Offset(
        center.dx+(radius-25)*cos(angle), 
        center.dy+(radius-25)*sin(angle),
      );
      textPainter.text=TextSpan(text:'$i', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, position-Offset(textPainter.width/2, textPainter.height/2));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    return true;
  }
}