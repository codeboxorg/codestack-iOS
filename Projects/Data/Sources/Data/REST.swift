//
//  REST.swift
//  Data
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import Data

public enum REST {
    case reissue(RefreshToken)
    case regitster(MemberDTO)
    case password(Pwd,NewPwd)
    case profile(ImageData)
    case health
    case auth(OAuthProvider)
}
