//
//  String+DIDescription.swift
//  Common
//
//  Created by 양승현 on 3/25/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

extension String {
  /// 어셈블리에 등록할때 fatalError메시지
  /// 이거는 이제 외부 모듈의 type을 특정 Assembly에서 불러올 때
  public static func registrationErrorMsgByOuter<T, A>(type: T.Type, inAssembly: A.Type) -> Self {
    "\(Self(describing: T.self)) 등록이 안됬습니다. 아니면 AppDIC에서 \(Self(describing: A.self)) Assembly를 등록하지 않았습니다.\n 아니면 뭐 argument 확인 해봐유.."
  }
  
  /// 어셈블리에 등록할때 fatalError메시지
  /// 이거는 이제 외부 모듈의 type을 특정 Assembly에서 불러올 때
  /// 근데 외부 모듈의 구체타입을 모름
  public static func registrationErrorMsgByUnknownOuter<T>(type: T.Type) -> Self {
    "\(Self(describing: T.self)) 등록이 안됬습니다. 아니면 AppDIC에서 \(Self(describing: type.self)) 관련 Assembly가 호출되지 않았습니다.\n 아니면 뭐 argument 확인 해봐유.."
  }
  
  /// 이거는 이제 내부 모듈에서 등록된 type을 내부 모듈에서 꺼내올 때
  public static func registrationErrorMsgByInner<T>(_: T.Type) -> Self {
    "\(Self(describing: T.self)) 등록이 안됬습니다. 위쪽에서 등록 잘 됬나 확인해보세요\n 아니면 뭐 argument 확인 해봐유.."
  }
}
