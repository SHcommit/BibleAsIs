 
import Foundation

public struct BibleVerse: PrettyDebugStringConvertible, Equatable {
  public let reference: BibleReference
  public let content: String
  
  public var book: BibleBook {
    reference.book
  }
  
  public var chapter: Int {
    reference.chapter
  }
  
  public var verse: Int {
    reference.verse
  }
    
  // MARK: - Lifecycle
  
  public init(book: BibleBook, chapter: Int, verse: Int, content: String) {
    let ref = BibleReference(book: book, chapter: chapter, verse: verse)
    self.init(reference: ref, content: content)
  }
  
  public init(reference: BibleReference, content: String) {
    self.reference = reference
    self.content = content
  }
  
  // MARK: - Helpers
  public func isEqual(to otherVerse: Self) -> Bool {
    id == otherVerse.id
  }
  
  /// 구절이 
  public var id: Int {
    book.bookOrder * 1_000_000 + chapter * 1_000 + verse
  }
  
  public static func getId(book: BibleBook, chapter: Int, verse: Int) -> Int {
    book.bookOrder * 1_000_000 + chapter * 1_000 + verse
  }
  
  public func toBibleReference() -> BibleReference {
    return BibleReference(book: book, chapter: chapter, verse: verse)
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}
