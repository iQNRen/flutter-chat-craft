import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_craft/widget/barrage/barrage_config.dart';
import 'package:flutter_chat_craft/widget/barrage/barrage_track.dart';
import 'package:flutter_chat_craft/widget/barrage/barrage_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'barrage_item.dart';

class BarrageUtils {
  static Size getDanmakuBulletSizeByText(String text) {
    const constraints = BoxConstraints(
      maxWidth: 999.0, // maxWidth calculated
      minHeight: 0.0,
      minWidth: 0.0,
    );
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14.sp,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    renderParagraph.layout(constraints);
    double w = renderParagraph.getMinIntrinsicWidth(14).ceilToDouble();
    double h = renderParagraph.getMinIntrinsicHeight(999).ceilToDouble();
    return Size(w, h);
  }

  // 根据文字长度计算每一帧需要run多少距离
  static double getBulletEveryFrameRateRunDistance(double bulletWidth) {
    assert(bulletWidth > 0);
    return BarrageConfig.baseRunDistance +
        (bulletWidth / BarrageConfig.everyFrameRateRunDistanceScale);
  }

  // 算轨道相对可用区域是否溢出
  static bool isEnableTrackOverflowArea(BarrageTrack track) =>
      track.offsetTop + track.trackHeight > BarrageConfig.showAreaHeight;

  // 偏移子弹是否有空间能插入
  static hasInsertOffsetSpaceComputed(
      BarrageModel trackLastBullet, double willInsertBulletRunDistance) {
    return (trackLastBullet.runDistance - trackLastBullet.bulletSize.width) >
        willInsertBulletRunDistance;
  }

  // 子弹剩余多少帧离开屏幕
  static double remainderTimeLeaveScreen(
      double runDistance, double textWidth, double everyFramerateDistance) {
    assert(runDistance >= 0);
    assert(textWidth >= 0);
    assert(everyFramerateDistance > 0);
    double remainderDistance =
        (BarrageConfig.areaSize.width + textWidth) - runDistance;
    return remainderDistance / everyFramerateDistance;
  }

  // 轨道注入子弹是否会碰撞
  static bool trackInsertBulletHasBump(
      BarrageModel trackLastBullet, Size needInsertBulletSize,
      {int offsetMS = 0}) {
    // 是否离开了右边的墙壁
    if (!trackLastBullet.allOutRight) return true;
    double willInsertBulletEveryFrameRateRunDistance =
        BarrageUtils.getBulletEveryFrameRateRunDistance(
            needInsertBulletSize.width);
    bool hasInsertOffsetSpace = true;
    double willInsertBulletRunDistance = offsetMS == null
        ? 0
        : (offsetMS / BarrageConfig.unitTimer) *
            willInsertBulletEveryFrameRateRunDistance;
    hasInsertOffsetSpace = hasInsertOffsetSpaceComputed(
        trackLastBullet, willInsertBulletRunDistance);
      if (!hasInsertOffsetSpace) return true;
    // 要注入的节点速度比上一个快
    if (willInsertBulletEveryFrameRateRunDistance >
        trackLastBullet.everyFrameRunDistance) {
      // 是否会追尾
      // 将要注入的弹幕全部离开减去上一个弹幕宽度需要的时间
      double willInsertBulletLeaveScreenRemainderTime =
          remainderTimeLeaveScreen(willInsertBulletRunDistance, 0,
              willInsertBulletEveryFrameRateRunDistance);
      print(trackLastBullet.leaveScreenRemainderTime);
      print(willInsertBulletLeaveScreenRemainderTime);
      return trackLastBullet.leaveScreenRemainderTime >
          willInsertBulletLeaveScreenRemainderTime;
    } else {
      return false;
    }
  }
}
