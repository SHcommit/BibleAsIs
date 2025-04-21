//
//  BibleNoteHomeViewController.swift
//  BibleNoteHomeFeature
//
//  Created by 양승현 on 3/7/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DomainEntity
import BibleNoteInterface
import DesignSystemInterface
import BibleNoteHomeInterface

public final class BibleNoteHomeViewController: BaseViewController, View {
  public typealias Reactor = BibleNoteHomeReactor
  
  // MARK: - Properties
  private let noteView = UITableView.makeBibleNoteTableView().then {
    $0.setAutoLayout()
  }
  
  private var noteViewAdapter: BibleNoteTableViewAdapter!
  
  public var disposeBag: DisposeBag = .init()
  
  private var forPageView: Bool
  
  private var flowDependencies: BibleNoteHomeFlowDependencies
  
  private var entryWithNote: BibleNote?
  private var andEntryWithVerseForNote: BibleVerse?
  
  /// - Parameters forPageView:
  /// 페이지 뷰일 경우에는 레이아웃이 topAnchor
  /// 페이지뷰가 아닐 경우 safeAreaLayoutGuide.top으로 레이아웃 됨.
  ///
  /// - Parameters entryWithNote, andVerseForNote: 이 경우에 의해 들어오는 경우는, 사용자가 특정 화면에서 NoteHome -> specific note page로 이동해야 하는 경우다.
  public init(
    forPageView: Bool,
    flowDependencies: BibleNoteHomeFlowDependencies,
    entryWithNote: BibleNote?,
    andVerseForNote: BibleVerse?
  ) {
    self.entryWithNote = entryWithNote
    self.andEntryWithVerseForNote = andVerseForNote
    self.flowDependencies = flowDependencies
    self.forPageView = forPageView
    super.init(nibName: nil, bundle: nil)
  }
  
  /// 이게 지금 화면에서 push해서 특정한 노트 화면으로 이동할 때도 네비게이션에 의해 사라지고 -> 다시 푸시 애니메이션 과정에서 이 viewDidAppear가 호출 됨.
  /// 노트 홈 -> 노트 화면으로 이동하는데, push vc에 의해 현재 노트 홈이 그래서 사라지려고 하는 와중에도 refresh가 되버림
  ///
  /// 그래서 willShowSpecificNote 이거로 체크하자! notePage로 이동할 때는 viewWillAppear가 한번 더 호출된다는 것은, A -> B page push 완료 후 A가 다시 보여지는
  /// 애니메이션 끝에 의해 호출되는거로
  private var willShowSpecificNote: Int = 0
  
  /// 이거는 이 변수를 사용하기 전에, 업데이트 해주어야함.
  /// 이 변수가 새로운 값으로 수정되는 것은 특정한 노트 화면으로 present되기 직전에 값이 주입됨.
  private var modifiedNoteIndex: Int?
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { fatalError("미지원") }
  
  // MARK: - Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .palette(.appearance)
    showGradientView()
    if !forPageView {
      navigationItem.title = "바이블 노트"
    }
    if noteViewAdapter == nil {
      noteViewAdapter = BibleNoteTableViewAdapter(
        dataSource: reactor,
        delegate: self,
        tableView: noteView)
    }
  }
  
  /// 사용자가 일일이 리프래시 하지 않게
  /// 새로운 데이터 반영해주자.
  ///
  /// 근데 데이터가 깜빡일 수 있으니 제어해주자.
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    /// 이게 세부 노트 화면으로 이동할 때도 네비게이션에 의해 사라지고 -> 다시 이 viewDidAppear가 호출됨.
    /// 노트 홈 -> 노트 화면으로 이동하는데, push vc에 의해 현재 노트 홈이 그래서 사라지려고 하는 와중에도 refresh가 되버림
    ///
    /// 그래서 willShowSpecificNote 이거로 체크하자
    if willShowSpecificNote > 0 {
      willShowSpecificNote -= 1
      return
    }
    reactor?.action.onNext(.refresh)
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    view.addSubview(noteView)
    
    NSLayoutConstraint.activate([
      noteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      noteView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    if forPageView {
      NSLayoutConstraint.activate([
        noteView.topAnchor.constraint(equalTo: view.topAnchor),
        noteView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    } else {
      NSLayoutConstraint.activate([
        noteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        noteView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
  }
    
  // MARK: - Bind
  public func bind(reactor: BibleNoteHomeReactor) {
    reactor.state
      .map { $0.reloadForNewPage }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] wannaRefresh in
        guard let self else { return }
        guard wannaRefresh else { return }
        noteView.reloadData()
        if let entryBySpecificNote = entryWithNote, let andEntryBySpecificVerseForNote = andEntryWithVerseForNote {
          guard reactor.currentState.notes.contains(where: {$0.noteId == entryBySpecificNote.noteId}) else {
            ToastController.shared.showToast(message: "시스템 오류로 인해 해당 노트가 식별 불가능합니다.", type: .error)
            return
          }
          willShowSpecificNote += 1
          flowDependencies.showNotePage(
            bibleNote: entryBySpecificNote,
            noteId: entryBySpecificNote.noteId,
            range: entryBySpecificNote.range,
            bibleVerse: andEntryBySpecificVerseForNote,
            delegator: self)
          entryWithNote = nil
          andEntryWithVerseForNote = nil
        }
        
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] loading in
        guard let self else { return }
        /// 초기에 rx(리엑터)도 컴바인처럼 initial setup을 함. ( 서로 pub, sub연결을 위해서 바인딩을 수행하는데 그때 호출된다.
        /// 그래서 이렇게 초기에 데이터가 없다면 return을 하도록 하자
        /// 안하면 UITableViewAlertForLayoutOutsideViewHierarchy 이런거 체크하라는 경고 나왐
        if reactor.numberOfItems == 0 { return }
        if loading { return }
        
//        print(reactor.hasInitiallyFetched, reactor.currentState.reloadForNewPage)
        
        /// 초기에 진입될 때 isLoading이 아 이거 컬스택으로 암만봐도 isLoading을 reactor에서 방출하는 경우가 없는데.. false때매 initialState 때매 호출되는거네
        /// skip 1 써도 되는데 더 명확하게 하기위해서 noteView.tableFooterView == nil 이라는걸 추가했음 ㅎㅅㅎ
        /// 정확하게! isLoading 이어야만 tableFotoerView 가 true되니까.
        if noteView.tableFooterView == nil { return }
        noteView.tableFooterView = nil
        let startIndex = reactor.currentState.numberOfPrevItems
        let endIndex = reactor.currentState.items.count
        
        guard startIndex < endIndex else { return }
        
        let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        
        UIView.performWithoutAnimation {
          self.noteView.performBatchUpdates {
            self.noteView.insertRows(at: indexPaths, with: .none)
          }
        }
        
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.noteDeleted }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] noteDeleted in
        guard let self else { return }
        if noteDeleted, let deletedNoteIndex = reactor.currentState.deletedNoteIndex {
          noteView.performBatchUpdates {
            /// 여기서 그냥 바로 리로드 처리하지말고
            /// 마지막 구절까지 삭제했을 경우에 리프래쉬 한번 해보자. fetch해서 정말 없으면.. empty 화면 보여주자!
            ///
            /// 그리고 여기서 async처리한 이유는 이 stream이후에도 또 noteDeleted = false처리됨.
            /// reactorkit 특성성 내부 로직에서 많은 함수들이 호출되는데 이 scope에서 onNext를 호출해서 또 바로 동작하게 하면
            /// `⚠️ RxSwift Reentrancy anomaly detected` 이 에러가 발생됨
            if reactor.numberOfItems == 0 {
              DispatchQueue.main.async { self.reactor?.action.onNext(.refresh) }
            } else {
              self.noteView.deleteRows(at: [IndexPath(row: deletedNoteIndex, section: 0)], with: .automatic)
            }
          }
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.noteUpdated }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        // noteUpdated 매개변수로 받음
        guard let self, let updatedNoteIndex = reactor.currentState.updatedNoteIndex else { return }
        
        let numOfRows = noteView.numberOfRows(inSection: 0)
        if updatedNoteIndex == 0 { return }
        guard updatedNoteIndex < numOfRows, updatedNoteIndex > 0 else {
          assertionFailure("식별되지 않은 Note의 참조르 확인하려고 하고 있습니다: \(updatedNoteIndex)")
          return
        }
        
        let fromIndexPath = IndexPath(row: updatedNoteIndex, section: 0)
        let toIndexPath = IndexPath(row: 0, section: 0)
        
        noteView.performBatchUpdates {
          self.noteView.moveRow(at: fromIndexPath, to: toIndexPath)
        } completion: { _ in
          self.noteView.scrollToRow(at: toIndexPath, at: .top, animated: true)
        }
      }).disposed(by: disposeBag)
  }
}

// MARK: - BibleNoteTableViewAdapterDelegate
extension BibleNoteHomeViewController: BibleNoteTableViewAdapterDelegate {
  public func didScroll(offset: CGPoint) { }
  
  public func showNextPage() {
    noteView.tableFooterView = LoadingTableViewFooterView(
      frame: .init(origin: .zero,
                   size: .init(width: 0, height: LoadingTableViewFooterView.Height)))
    reactor?.action.onNext(.nextPage)
  }
  
  public func showNoteContent(with indexPath: IndexPath) {
    guard
      let verseItem = reactor?.item(for: indexPath),
        let note = reactor?.currentState.notes[indexPath.row]
    else {
      ToastController.shared.showToast(message: "\(indexPath) 에 대한 노트 정보가 없습니다.", type: .error)
      return
    }
    modifiedNoteIndex = indexPath.row
    willShowSpecificNote += 1
    
    flowDependencies.showNotePage(
      bibleNote: note,
      noteId: note.noteId,
      range: note.range,
      bibleVerse: verseItem,
      delegator: self)
  }
}

// MARK: - BibleNoteCoordinatorDelegate
extension BibleNoteHomeViewController: BibleNoteCoordinatorDelegate {
  public func handleModifiedNote(
    modifiedNote: BibleNote?,
    hasUserModifiedTheNote: Bool,
    hasUserDeletedTheNote: Bool
  ) {
    guard let modifiedNoteIndex else {
      // 여기선 뒤로갈 때 modifiedNoteIndex가 없으면 아무런 수행을 안한것임 지극히 자연스러운 로직이다. 이말인거야!
//      ToastController.shared.showToast(message: "시스템 오류로 인해 노트 수정 사항을 로드할 수 없습니다.", type: .error)
      return
    }
    if hasUserDeletedTheNote {
      reactor?.action.onNext(.noteDeleted(row: modifiedNoteIndex))
    } else if let modifiedNote {
      if hasUserModifiedTheNote {
        reactor?.action.onNext(.noteUpdated(note: modifiedNote, row: modifiedNoteIndex))
      }
    }
    self.modifiedNoteIndex = nil
  }
}
