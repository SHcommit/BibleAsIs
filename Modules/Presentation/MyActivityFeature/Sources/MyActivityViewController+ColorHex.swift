//
//  MyActivityViewController2+ColorHex.swift
//  MyActivityFeature
//
//  Created by 양승현 on 4/3/25.
//

import UIKit

extension MyActivityViewController {
  // MARK: 색깔도 4개 메뉴바 서로 다른거로 했는데
  // 그냥 단색 1개로 정해봤음 ㅇㅅㅇ
  //  private let menuColors: [UIColor] = [
  //    UIColor(hexCode: "#ED8554"), UIColor(hexCode: "#FEEFAD"),
  //    UIColor(hexCode: "#E5EFC1"), UIColor(hexCode: "#FFE3E1")]
  
  var safeAreaColorHex: String {
    if isDarkMode {
      "#323232"
    } else {
      "#222831"
    }
  }
  
  var deselectedMenuColorHex: String {
    if isDarkMode {
      "#242629"
    } else {
      "#30353D"
    }
  }
  
//  var deselectedMenuTitleColorHex: String {
//    if isDarkMode {
//      "#EDEDED"
//    } else {
//      "#BABABA"
//    }
//  }
  
  // MARK: selectedMenuColor는 .palette(.appearance)
  // MARK: selectedMenuTitleColor는 .palette(.title)
}
