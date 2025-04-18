//
//  BibleNoteViewController.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/7/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DomainEntity
import CoreInterface
import BibleNoteInterface

public final class BibleNoteViewController: BaseViewController, View {
  public typealias Reactor = BibleNoteReactor
  
  // MARK: - Properties
  private let headerView = BibleNoteHeaderView().setAutoLayout()
  
  private(set) var textView = TextView(
    placeholderText: "말씀을 묵상하며 노트를 자유롭게 작성해주세요.",
    frame: .zero,
    placeholderFont: .appleSDGothicNeo(.light, size: 13),
    placeholderTextColor: .palette(.description)
  ).then {
    $0.setAutoLayout()
    $0.alpha = 0
    $0.font = .appleSDGothicNeo(.regular, size: 13)
    $0.textColor = .palette(.primaryNuetralText)
    $0.backgroundColor = .clear
    $0.isScrollEnabled = true
    $0.isEditable = true
    $0.isSelectable = true
    
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
  }
  
  private var tooltipDescriptionMsg: String {
    let isFirstEntry = reactor?.initialState.isFirstTimeToWriteNote ?? false
    if isFirstEntry {
      return "이 구절이 와닿았다면, 터치하여 기록해주세요"
    } else {
      return "터치하여 수정할 수 있어요"
    }
  }
  
  public var disposeBag: DisposeBag = .init()
  
  private(set) lazy var tooltipDescriptionView = BottomBasedTooltipView(
    frame: .zero, colorInfo: .BaseTestamentSmallChapter,
    message: tooltipDescriptionMsg, labelFontType: .appleSDGothicNeo(.regular, size: 10)
  ).then {
    $0.setAutoLayout()
    $0.alpha = 0
  }
  
  /// 노트가 수정되거나, 저장됬다면 실제 값 반환, 그게 아닐 경우 nil 반환함.
  /// 수정된 경우에는 화면 맨 위로! ( date에 따라 자동 정렬 하도록 sqlite3 오더바이 쿼리 짰음 )
  /// 노트가 삭제되면 hasDeleted true
  private var delegate: BibleNoteViewControllerDelegate?
  
  private(set) var isAvailableSaveButton = false
  
  private var hasEntryAnimationDone = false
  
  public var hasModified: Bool {
    let initialNoteHash = reactor?.initialNoteHash ?? ""
    var currentNoteHash = ""
    if textView.text != "" {
      currentNoteHash = textHasher.toHash(of: textView.text)
    }
    return !textHasher.compare(lhs: currentNoteHash, rhs: initialNoteHash)
  }
  
  private let textHasher: TextHashable
  
  // MARK: - Lifecycle
  public init(delegate: BibleNoteViewControllerDelegate?, textHasher: TextHashable) {
    self.textHasher = textHasher
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
    hidesBottomBarWhenPushed = true
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { nil }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    UIView.performWithoutAnimation {
      textView.becomeFirstResponder()
      textView.resignFirstResponder()
    }
    textView.textViewDelegate = self
    view.isUserInteractionEnabled = true
    reactor?.action.onNext(.refresh)
    navigationItem.title = "성경 노트"
   observeKeyboardState()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if textView.isFirstResponder {
      textView.resignFirstResponder()
    }
    delegate?.handleModifiedNote(
      modifiedNote: reactor?.currentState.updatedBibleNote,
      hasUserModifiedTheNote: hasModified,
      hasUserDeletedTheNote: reactor?.currentState.deleted ?? false)
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    if !hasEntryAnimationDone {
      hasEntryAnimationDone = true
      headerView.cancelBibleVerseTypingAnimation()
    }
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: view)
    if !textView.frame.contains(touchLocation) {
      view.endEditing(true)
      setBackItem()
    }
  }
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
      if textView.isFirstResponder {
        setKeyboardItem()
        setSaveItem()
      } else {
        setBackItem()
        if reactor?.currentState.isFirstTimeToWriteNote ?? false {
          setSaveItem()
        } else {
          setMenuItem()
        }
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  public override func layoutUI() {
    [headerView, textView, tooltipDescriptionView].forEach(view.addSubview(_:))
    headerView.setContentCompressionResistancePriority(.init(123), for: .vertical)
    textView.setContentCompressionResistancePriority(.init(249), for: .vertical)
    
    NSLayoutConstraint.activate([
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      textView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
      textView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
      textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      
      tooltipDescriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 77),
      tooltipDescriptionView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -7)
    ])
  }
  
  // MARK: - Bind
  public func bind(reactor: BibleNoteReactor) {
    reactor.state
      .map { $0.hasNoteFetched }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] wannaRefresh in
        guard let self, wannaRefresh else { return }
        textView.text = reactor.currentState.bibleNote?.text ?? ""
        textView.invalidateIntrinsicContentSize()
        headerView.transform = .init(translationX: 0, y: 7)
        textView.transform = .init(translationX: 0, y: 7)
        if reactor.currentState.isFirstTimeToWriteNote {
          setSaveItem()
        } else {
          /// 아니 이상하게 다크모드일 때 글이 작성된 경우 이 옵션 버튼만 white모드일 때 이미지가 적용되네
          /// 그렇다고 키보드가 올라갔다 내려가면 다시 setMenuItem() 호출해주는데 그때는 dark mode의 옵션 이미지가 적용되고
          /// 진짜 이상해.
          /// iphone 16 pro 18.2 ver
          /// --> 해결.
          ///  이유: UIBarButtonItem+Factory.swift
            self.setMenuItem()
        }
        
        headerView.animate(with: reactor.currentState.bibleVerse) { [weak self] in
          guard let self else { return }
          hasEntryAnimationDone = true
          UIView.animate(withDuration: 0.5, delay: 0.45, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.textView.alpha = 1
            self.textView.transform = .identity
          }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
              self.performTooltipAnimation()
            })
          })
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.unexpectedErrorMessage }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] errorMessage in
        if errorMessage == "" { return }
        self?.showAlert(for: errorMessage)
      }).disposed(by: disposeBag)
      
    reactor.state
      .map { $0.noteModified }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] noteModified in
        guard noteModified else { return }
        self?.navigationController?.popViewController(animated: true)
      }).disposed(by: disposeBag)
  }
  
  // MARK: - NavigationBar
  func setLeftBarButton(_ barItem: UIBarButtonItem?, shouldAniamte: Bool) {
    navigationItem.setLeftBarButton(barItem, animated: shouldAniamte)
  }
  
  func setRightBarButton(_ barItem: UIBarButtonItem?, shouldAniamte: Bool) {
    navigationItem.setRightBarButton(barItem, animated: shouldAniamte)
  }
  
  func setKeyboardItem() {
    _=UIBarButtonItem.makeKeyboardItem(self, action: #selector(didTapKeyboardButton)).then {
      setLeftBarButton($0, shouldAniamte: false)
    }
  }
  
  func setIsAvailableSavebutton(_ flag: Bool) {
    isAvailableSaveButton = flag
  }
  
  // MARK: - Anim Helpers
  func addAnimationGroupInTooltipView(with group: CAAnimationGroup, forKey: String? = nil) {
    tooltipDescriptionView.layer.add(group, forKey: forKey)
  }
  
  func addAnimationInTooltipView(with animation: CABasicAnimation, forKey: String? = nil) {
    tooltipDescriptionView.layer.add(animation, forKey: forKey)
  }
}

// MARK: - Actions 헐 이상함.. 컨트롤러 이상하게 extension하면 actions동작 안됨
extension BibleNoteViewController {
  func observeKeyboardState() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc func didTapKeyboardButton() {
    textView.resignFirstResponder()
    setBackItem()
  }
  
  @objc func saveNote() {
    reactor?.action.onNext(.noteSave(textView.text))
  }
  
  @objc func updateNote() {
    reactor?.action.onNext(.noteContentModifiy(textView.text))
  }
  
  @objc func didTapMenuButton() {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let actions = [
      UIAlertAction(title: "수정 완료", style: .default) { [weak self] _ in self?.updateNote() },
      UIAlertAction(title: "노트 삭제", style: .destructive) { [weak self] _ in
        self?.reactor?.action.onNext(.noteDelete)
      },
      UIAlertAction(title: "취소", style: .cancel)]
    actions.forEach(actionSheet.addAction(_:))
    present(actionSheet, animated: true)
  }
  
  @objc func handleKeyboard(_ notification: Notification) {
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let _kayboardFrame = keyboardValue.cgRectValue
    
    if notification.name == UIResponder.keyboardWillHideNotification {
      textView.contentInset = .zero
    } else {
      textView.contentInset = UIEdgeInsets(
        top: 0, left: 0,
        bottom: _kayboardFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    textView.scrollIndicatorInsets = textView.contentInset
    let selectedRange = textView.selectedRange
    textView.scrollRangeToVisible(selectedRange)
  }
}

// MARK: - Navigation Bar Helpers
extension BibleNoteViewController {
  func setMenuItem() {
    let menuItem = UIBarButtonItem.makeMenu2Item(self, action: #selector(didTapMenuButton))
    setRightBarButton(menuItem, shouldAniamte: true)
  }
  
  func setBackItem() {
    let item = makeBackItem()
    item.isEnabled = true
    setLeftBarButton(item, shouldAniamte: true)
  }
  
  func setSaveItem() {
    let isFirstSave = (reactor?.currentState.isFirstTimeToWriteNote ?? false)
    
    var selector: Selector
    if isFirstSave {
      selector = #selector(saveNote)
    } else {
      selector = #selector(updateNote)
    }
    
    let saveItem = UIBarButtonItem.makeTitleItem(self, action: selector, title: "저장")
    setRightBarButton(nil, shouldAniamte: true)
    
    /// 수정안하거나 수정해도 공백이나 그런거로 구성될 꼉우엔 저장버튼 막자!
    if !hasModified || textView.text.isBlank {
      saveItem.isEnabled = false
      setRightBarButton(saveItem, shouldAniamte: true)
      navigationItem.rightBarButtonItem?.action = nil
      setIsAvailableSavebutton(false)
      
    } else {
      saveItem.isEnabled = true
      setRightBarButton(saveItem, shouldAniamte: true)
      setIsAvailableSavebutton(true)
    }
  }
  
  // MARK: - Animation Helpers
  func performTooltipAnimation() {
    let springAnimation = CASpringAnimation(keyPath: "position.y").then {
      $0.fromValue = tooltipDescriptionView.layer.position.y
      $0.toValue = tooltipDescriptionView.layer.position.y + 1
      $0.duration = $0.settlingDuration
      $0.damping = 20
      $0.mass = 10
      $0.initialVelocity = 10
      $0.stiffness = 200
    }
    
    let animationGroup = CAAnimationGroup().then {
      $0.duration = max(0.5, springAnimation.duration)
      $0.beginTime = CACurrentMediaTime() + 0.2
    }
    
    UIView.animate(withDuration: 0.7, delay: 0.1, options: [.curveEaseInOut]) {
      self.tooltipDescriptionView.alpha = 1
    }
    
    animationGroup.animations = [springAnimation]
    
    addAnimationGroupInTooltipView(with: animationGroup)
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.hideTooltipWithAnimation()
    }
  }
  
  func hideTooltipWithAnimation() {
    if tooltipDescriptionView.alpha == 0 {
      return
    }
    
    let moveAnimation = CABasicAnimation(keyPath: "position.y").then {
      $0.fromValue = tooltipDescriptionView.layer.position.y
      $0.toValue = tooltipDescriptionView.layer.position.y + tooltipDescriptionView.bounds.height/2
      $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      $0.duration = 0.56
    }
    
    addAnimationInTooltipView(with: moveAnimation)
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
      self.tooltipDescriptionView.alpha = 0
    } completion: { _ in
      self.tooltipDescriptionView.layer.removeAllAnimations()
    }
  }
}

// MARK: - TextViewDelegate
extension BibleNoteViewController: TextViewDelegate {
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    if tooltipDescriptionView.alpha != 0 {
      hideTooltipWithAnimation()
    }
    setKeyboardItem()
    setSaveItem()
    return true
  }
  
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    if reactor?.currentState.isFirstTimeToWriteNote ?? false {
      setSaveItem()
    } else {
      setMenuItem()
    }
    return true
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    if textView.text.isBlank {
      setIsAvailableSavebutton(false)
      setSaveItem()
      return
    }
    if hasModified {
      if !isAvailableSaveButton {
        setSaveItem()
      }
    } else {
      if isAvailableSaveButton {
        setSaveItem()
      }
    }
  }
  
}
