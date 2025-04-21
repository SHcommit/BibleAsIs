//
//  Animator.swift
//  MyActivityFeature
//
//  Created by 양승현 on 3/1/25.
//

import UIKit
import DesignSystem
import BibleReadingChecklistInterface

/// UIViewControllerAnimatedTransitioning 이 객체를 이제 UIViewControllerTransitioningDelegate 여기서 animationController(forPresented:) 이곳에서 present될 때 실행할 애니메이션으로! 넣기
///
/// - 스냅샷 안됨. 스냅샷이라 scale커지는 애니메이션 줄 때 까다로움. 그리고 나는 이미지도 확대 되어야함.
///   scaleAsfectFit처럼,,
///
/// -> transform 쓰자 : )
///
/// - 아 그리고 frame 으로 애니메이션 해봤는데, 초기에 위치해야할 프레임이 적용이 안되고, startFrame.origin은 적용되는데 크기는 finalFrame.size 이게 적용되버림..
///   그래서 트랜스폼!
///
/// - 그리고 이게 transitionContext.view(forKey: .from) 이거로 fromVC를 가져올 수 없음..
///     페이지컨트롤러를 사용중이기 때문에 좀 복잡함. 루트로부터 몇 번 체이닝 거쳐서 가져와야함.
public class DailyReadingPlanExpendingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  private let duration: TimeInterval = 0.45
  
  private var isPresenting: Bool
  
  private weak var fromVC: BibleReadingPlanHomeViewController!
  
  private var blur: UIView? = BlurWithVibrancyView()
  
  private let frameForStartingCustomTransitionComponent: CGRect
  
  init(
    isPresenting: Bool,
    fromVC: BibleReadingPlanHomeViewController,
    frameForStartingCustomTransitionComponent: CGRect
  ) {
    self.frameForStartingCustomTransitionComponent = frameForStartingCustomTransitionComponent
    self.isPresenting = isPresenting
    self.fromVC = fromVC
  }
  
  deinit { print("\(Self.self)")}
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if isPresenting {
      let containerView = transitionContext.containerView
      guard
        let toView = transitionContext.view(forKey: .to),
        let toVC = transitionContext.viewController(forKey: .to)
      else { assertionFailure("애니메이션 진행하려고 하는데 transitionContext key 식별 불가"); return }
      guard var targetVC = toVC as? BibleReadingChecklistHeroAnimatable else { return }
      
      let blur = BlurWithVibrancyView(blurStyle: .regular, vibrancyStyle: .fill).then {
        $0.alpha = 0
        containerView.addSubview($0)
        NSLayoutConstraint.activate([
          $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
          $0.topAnchor.constraint(equalTo: containerView.topAnchor),
          $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
          $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)])}
      
      targetVC.initialLoadingCompletionHandler = { [weak self] in

        guard let self else { return }
        toView.alpha = 0
//        toView.setShadow(with: .normalComponent, cornerRadius: 0)
        /// 애니메이션할때 베지어 패스 그려두면 정말 너무너무너무너무 안좋은거 임!
        toView.layer.shadowPath = nil
        toView.layer.shadowOpacity = 0
        fromVC.setHidingDailyBibleChallengeView()
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        let finalFrame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: 284)
        let scaleX = finalFrame.width / frameForStartingCustomTransitionComponent.width
        let scaleY = finalFrame.height / frameForStartingCustomTransitionComponent.height
        toView.frame  = frameForStartingCustomTransitionComponent
        toView.transform = .init(scaleX: 1/scaleX, y: 1/scaleY)
        toView.layoutIfNeeded()
//        UIView.animate(withDuration: duration/1.75, animations: { blur.alpha = 0.85 })
        
        let cardViewToTopAnimate = {
          toView.transform = .identity
          toView.frame = finalFrame
          toView.alpha = 1
          blur.alpha = 0.85
        }
        
//        let containerViewFullExpandingAnimate = {
//          containerView.layoutIfNeeded()
//        }
        
        let containerViewFullExpandingAnimateHandler = { (_: Bool) in
          transitionContext.completeTransition(true)
          targetVC.shouldShowGradient()
          blur.removeFromSuperview()
          self.fromVC.setShowingDailyBibleChallengeView()
        }
        
        let cardViewToTopAnimateHandler = { (_: Bool) in
          toView.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            toView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toView.topAnchor.constraint(equalTo: containerView.topAnchor),
            toView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)])
          UIView.performWithoutAnimation {
            containerView.layoutIfNeeded()
          }
          containerViewFullExpandingAnimateHandler(false)
          
          // 애니메이션 주는거보다 직관적으로 업뎃하는게 자연스러움 ( 위에 expanding에 초점이 맞춰지니까
//          UIView.animate(
//            withDuration: 0.35, delay: 0, options: [.curveEaseInOut],
//            animations: containerViewFullExpandingAnimate,
//            completion: containerViewFullExpandingAnimateHandler)
        }
          
        UIView.animate(
          withDuration: duration,
          delay: 0,
          options: [.curveEaseInOut],
          animations: cardViewToTopAnimate,
          completion: cardViewToTopAnimateHandler)
      }
      
    } else {
      //
      //      guard let detailView = transitionContext.view(forKey: .from),
      //            let detailVC = transitionContext.viewController(forKey: .from) as? BibleReadingChecklistViewController,
      //            let startFrame = detailVC.startingFrame
      //      else { assertionFailure("노노노노논"); return }
      //
      //      let blurV = BlurWithVibrancyView(
      //        blurStyle: .regular, vibrancyStyle: .tertiaryFill
      //      ).then {
      //        $0.alpha = 1
      //        containerView.addSubview($0)
      //        NSLayoutConstraint.activate([
      //          $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      //          $0.topAnchor.constraint(equalTo: containerView.topAnchor),
      //          $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      //          $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)])
      //      }
      //
      //      fromVC.animateChallengeViewToOrigin()
      //
      //      let scaledBigWidth = containerView.frame.width * 0.8
      //      let scaledBigHeight = containerView.frame.height * 0.8
      //
      //      /// 이거는 좌표가 스케일 0.8 로 됬을 떄 0,0 에서 몇으로 이동하는가 임
      //      let 델타축소된좌표X = containerView.bounds.width * (1 - 0.8)/2
      //      let 델타축소된좌표Y = containerView.bounds.height * (1 - 0.8)/2
      //
      //
      //      let 축소된뷰가원래카드뷰위치까지이동해야하는x = startFrame.origin.x - 델타축소된좌표X
      //      let 축소된뷰가원래카드뷰위치까지이동해야하는y = startFrame.origin.y - 델타축소된좌표Y
      //
      //      UIView.animate(withDuration: 0.2) {
      //        containerView.transform = .init(scaleX: 0.8, y: 0.8)
      //      }
      //
      //      let toOriginScaleX = startFrame.width / scaledBigWidth
      //      let toOriginScaleH = startFrame.height / scaledBigHeight
      //
      //
      //      UIView.animate(withDuration: 0.4, delay: 0.15, animations: {
      //        containerView.transform = .init(scaleX: toOriginScaleX, y: toOriginScaleH).translatedBy(x: 축소된뷰가원래카드뷰위치까지이동해야하는x, y: 축소된뷰가원래카드뷰위치까지이동해야하는y)
      //        containerView.alpha = 0
      //      }, completion: { _ in
      //        detailView.removeFromSuperview()
      //        transitionContext.completeTransition(true)
      //      })
      //    }
      //
      //
      //
    }
  }
}
