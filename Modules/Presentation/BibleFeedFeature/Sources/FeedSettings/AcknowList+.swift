//
// Acknow.swift
//
// Copyright (c) 2015-2025 Vincent Tourraine (https://www.vtourraine.net)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import AcknowList

public struct _AcknowList {
  /**
   Header text to be displayed above the list of the acknowledgements.
   */
  public let headerText: String?
  
  /**
   List of acknowledgements.
   */
  public let acknowledgements: [_Acknow]
  
  /**
   Footer text to be displayed below the list of the acknowledgements.
   */
  public let footerText: String?
}

extension _AcknowList {
  static func + (lhs: Self, rhs: Self) -> _AcknowList {
    return _AcknowList(
      headerText: lhs.headerText ?? rhs.headerText,
      acknowledgements: lhs.acknowledgements + rhs.acknowledgements,
      footerText: lhs.footerText ?? rhs.footerText
    )
  }
}

/// Represents a single acknowledgement.
public struct _Acknow {
  
  /// The acknowledgement title (for instance: the pod or package’s name).
  public let title: String
  
  /// The acknowledgement body text (for instance: the pod’s license).
  public let text: String?
  
  /// The acknowledgement license (for instance the pod’s license type).
  public let license: String?
  
  /// The repository URL (for instance the package’s repository).
  public let repository: URL?
  
  /// Returns an object initialized from the given parameters.
  ///
  /// - Parameters:
  ///   - title: The acknowledgement title (for instance: the pod’s name).
  ///   - text: The acknowledgement body text (for instance: the pod’s license).
  ///   - license: The acknowledgement license (for instance the pod’s license type).
  public init(title: String, text: String? = nil, license: String? = nil, repository: URL? = nil) {
    self.title = title
    self.text = text
    self.license = license
    self.repository = repository
  }
}

public protocol AcknowDecoder {
  
  /**
   Returns acknowledgements decoded from a structured object.
   - Parameter data: The acknowledgements object to decode.
   - Returns: A `AcknowList` value, if the decoder can parse the data.
   */
  func decode(from data: Data) throws -> _AcknowList
}

/// An object that decodes acknowledgements from Swift Package Manager “resolved” file objects.
open class AcknowPackageDecoder: AcknowDecoder {
  
  public init() {}
  
  /**
   Returns acknowledgements decoded from a Swift Package Manager “resolved” file object.
   - Parameter data: The Swift Package Manager “resolved” file object to decode.
   - Returns: A `AcknowList` value, if the decoder can parse the data.
   */
  public func decode(from data: Data) throws -> _AcknowList {
    let decoder = JSONDecoder()
    if let root = try? decoder.decode(JSONV1Root.self, from: data) {
      let acknows = root.object.pins.map {
        _Acknow(title: $0.package, repository: URL(string: $0.repositoryURL))
      }
      return _AcknowList(headerText: nil, acknowledgements: acknows, footerText: nil)
    }
    
    let root = try decoder.decode(JSONV2Root.self, from: data)
    let acknows =  root.pins.map { _Acknow(title: $0.identity, repository: URL(string: $0.location)) }
    return _AcknowList(headerText: nil, acknowledgements: acknows, footerText: nil)
  }
  
  // MARK: - JSON format
  struct JSONV1Root: Codable {
    let object: JSONV1Object
    let version: Int
  }
  
  struct JSONV1Object: Codable {
    let pins: [JSONV1Pin]
  }
  
  struct JSONV1Pin: Codable {
    let package: String
    let repositoryURL: String
  }
  
  struct JSONV2Root: Codable {
    let pins: [JSONV2Pin]
    let version: Int
  }
  
  struct JSONV2Pin: Codable {
    let identity: String
    let location: String
  }
}

final class AcknowledgementsViewController: UITableViewController {
  private var acknowledgements: [_Acknow]
  init(acknowledgements: [_Acknow] = []) {
    self.acknowledgements = acknowledgements
    super.init(style: .plain)
    tableView.backgroundColor = .palette(.appearance)
    navigationItem.title = "오픈 소스"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.separatorStyle = .none
    tableView.rowHeight = 50
    tableView.backgroundColor = .palette(.appearance)
    tableView.delaysContentTouches = false
    tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .palette(.appearance)
    tableView.scrollIndicatorInsets = .init(top: 0, left: 0.7, bottom: 0, right: 0)
    tableView.dataSource = self
    tableView.delegate = self
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0
    }
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    acknowledgements.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    if cell.textLabel?.textColor != .palette(.primaryNuetralText) {
      cell.backgroundColor = .clear
      cell.selectionStyle = .none
      cell.textLabel?.font = .appleSDGothicNeo(.regular, size: 14)
      cell.textLabel?.textColor = .palette(.primaryNuetralText)
    }
    
    cell.textLabel?.text = acknowledgements[indexPath.row].title.replacingOccurrences(of: ".git", with: "")
    return cell
  }
}
