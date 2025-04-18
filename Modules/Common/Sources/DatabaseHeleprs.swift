//
//  DatabaseHeleprs.swift
//  Common
//
//  Created by 양승현 on 2/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import SQLite3
import Foundation

public protocol SqliteDatabaseHelper: AnyObject {
  var database: OpaquePointer? { get }
  var statement: OpaquePointer? { get set }
}

extension SqliteDatabaseHelper {
  public func finalizeQuery() {
    if let statement = statement {
      sqlite3_finalize(statement)
      self.statement = nil
    }
    
  }
  
  public func prepareDatabase(query: String) -> Bool {
    if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
      return true
    }
    assertionFailure("""
      DEBUG: Database Couldn't be prepared
      query: \(query)
      ErrorMEssage: \(String(cString: sqlite3_errmsg(database)))
    """)
    return false
  }
  
  public func showTableNames(_ qeury: String? = nil) {
    let query = qeury ?? "SELECT name FROM sqlite_master WHERE type='table';"
    statement = nil
    guard prepareDatabase(query: query) else { return }
    while sqlite3_step(statement) == SQLITE_ROW {
      let tableName = String(cString: sqlite3_column_text(statement, 0))
      print("DEBUG: Table name - \(tableName)")
    }
    finalizeQuery()
  }

  public func numberOfRows(for tableName: String) -> Int {
    let query = "SELECT COUNT(*) FROM \(tableName)"
    statement = nil
    var rowCount = 0
    
    guard prepareDatabase(query: query) else { return rowCount }
    if sqlite3_step(statement) == SQLITE_ROW {
      rowCount = Int(sqlite3_column_int(statement, 0))
    } else {
      print("ERROR: Failed to fetch row count")
    }
    
    return rowCount
  }
  
  public func executeQuery(_ query: String) {
    statement = nil
    guard prepareDatabase(query: query) else { return }
    if sqlite3_step(statement) != SQLITE_DONE {
      let errorMessage = String(cString: sqlite3_errmsg(database))
      assertionFailure("DEBUG: Error executing query. SQLite Error: \(errorMessage)")
    }
    finalizeQuery()
  }
  
  /// query 준비 되면 각 행 읽어들임
  public func executeRows(_ task: () -> Void) {
    while sqlite3_step(statement) == SQLITE_ROW {
      task()
    }
  }
  
  public func sqlite3BindText(forIndex: Int, text: String) {
    let textCString = (text as NSString).utf8String
    sqlite3_bind_text(statement, Int32(forIndex), textCString, -1, nil)
  }
  
  public func sqlite3BindInt(forIndex: Int, integer: Int) {
    sqlite3_bind_int(statement, Int32(forIndex), Int32(integer))
  }
}

// MARK: - Additional convenience Helpers
extension SqliteDatabaseHelper {
  public var unexpectedOccuredDatabaseErrorMessage: String {
    String.init(cString: sqlite3_errmsg(database))
  }
}
