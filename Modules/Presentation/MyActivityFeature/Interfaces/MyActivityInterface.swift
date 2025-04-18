//
//  MyActivityInterface.swift
//  MyActivityFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Swinject

public protocol MyActivityInterface {
  func makeMyActivityModule(
    navigationController: UINavigationController?,
    resolver: any Resolver
  ) -> UIViewController
}
