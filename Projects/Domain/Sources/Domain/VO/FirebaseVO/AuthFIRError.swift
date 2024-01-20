//
//  AuthFIRError.swift
//  Domain
//
//  Created by 박형환 on 1/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public enum AuthFIRError: Int, Error {
    
    case unknown = -10000
    // MARK: 설정 관련
    /// 애플리케이션 구성의 API 키가 유효하지 않음을 나타냅니다.
    case FIRAuthErrorCodeInvalidAPIKey = 17023
    
    /// 제공한 API 키로 앱이 Firebase 인증을 사용할 권한이 없음을 나타냅니다. Google API 콘솔로 가서 사용자 인증 정보 탭에서 사용 중인 API 키의 허용 목록에 애플리케이션의 번들 ID가 등록되어 있는지 확인하세요.
    case FIRAuthErrorCodeAppNotAuthorized = 17028
    
    /// 내부 오류가 발생했음을 나타냅니다. NSError 객체를 모두 포함해 오류를 신고해 주세요
    case FIRAuthErrorCodeInternalError = 17999
    
    /// 키체인 액세스 중에 오류가 발생했음을 나타냅니다. NSError.userInfo 사전 내의 NSLocalizedFailureReasonErrorKey 필드와 NSUnderlyingErrorKey 필드에는 오류에 대한 추가 정보가 있습니다.
    case FIRAuthErrorCodeKeychainError = 17995 // MARK: Sign Out
    
    /// 이메일 및 비밀번호 계정의 사용 설정이 되어 있지 않음을 나타냅니다. Firebase Console의 인증 섹션에서 사용 설정하세요.
    /// 사용자 인증 정보가 나타내는 ID 공급업체 계정이 사용 설정되어 있지 않음을 나타냅니다. Firebase Console의 인증 섹션에서 사용 설정하세요.
    case FIRAuthErrorCodeOperationNotAllowed = 17006
    
    // MARK: 네틍워크 관련
    /// 작업 중에 네트워크 오류가 발생했음을 나타냅니다.
    case FIRAuthErrorCodeNetworkError = 17020
    
    /// 호출 기기에서 Firebase 인증 서버로 비정상적인 횟수만큼 요청이 이루어진 후 요청이 차단되었음을 나타냅니다. 조금 후에 다시 시도하세요.
    case FIRAuthErrorCodeTooManyRequests = 17010
    
    
    // MARK: 계정 유효성
    /// 사용자 계정을 찾을 수 없었음을 나타냅니다. 사용자 계정이 삭제된 경우 발생할 수 있습니다.
    case FIRAuthErrorCodeUserNotFound = 17011
    
    /// 이메일 주소의 형식이 잘못되었음을 나타냅니다.
    case FIRAuthErrorCodeInvalidEmail = 17008
    
    /// 사용자가 틀린 비밀번호로 로그인을 시도했음을 나타냅니다.
    case FIRAuthErrorCodeWrongPassword = 17009
    
    /// 사용자의 계정이 사용 중지 상태임을 나타냅니다.
    ///  사용자의 계정이 사용 중지 상태이며, Firebase Console의 '사용자' 패널에서 다시 사용 설정을 할 때까지 사용할 수 없음을 나타냅니다.
    case FIRAuthErrorCodeUserDisabled = 17005
    
    /// 제공받은 사용자 인증 정보가 유효하지 않음을 나타냅니다. 사용자 인증 정보의 기한이 다했거나 형식이 잘못되었을 때 발생할 수 있습니다.
    case FIRAuthErrorCodeInvalidCredential = 17004
    
    /// 서비스 계정과 API 키가 서로 다른 프로젝트에 속함을 나타냅니다.
    case FIRAuthErrorCodeCustomTokenMismatch = 17002
    
    /// 너무 안전성이 낮은 비밀번호를 설정하려고 했음을 나타냅니다. NSError.userInfo 사전 객체 내의 NSLocalizedFailureReasonErrorKey 필드에 사용자에게 표시할 수 있는 자세한 설명이 있습니다.
    case FIRAuthErrorCodeWeakPassword = 17026
    
    /// 현재 사용자가 아닌 다른 사용자로 재인증을 시도했음을 나타냅니다.
    case FIRAuthErrorCodeUserMismatch = 17024
    
    /// 사용자의 비밀번호를 변경하는 것은 보안에 민감한 작업이므로, 사용자가 최근 로그인한 적이 있어야 진행할 수 있습니다. 이 오류는 사용자가 최근에 로그인하지 않았음을 나타냅니다. 해결하려면 FIRUser에 reauthenticateWithCredential:completion:을 호출하여 사용자를 재인증하세요.
    case FIRAuthErrorCodeRequiresRecentLogin = 17014
    
    ///  이미 이 계정에 연결되어 있는 유형의 제공업체를 연결하려고 시도했음을 나타냅니다.
    case FIRAuthErrorCodeProviderAlreadyLinked = 17015
    
    /// 이미 다른 Firebase 계정에 연결되어 있는 사용자 인증 정보를 연결하려고 시도했음을 나타냅니다.
    case FIRAuthErrorCodeCredentialAlreadyInUse = 17025
    
    
    /// 사용자 인증 정보에 담긴 이메일 주소(예: Facebook 액세스 토큰에 담긴 이메일 주소)를 기존 계정이 이미 사용 중이므로 이 로그인 방법으로 인증할 수 없음을 나타냅니다. 이 사용자의 이메일에 대해 fetchProvidersForEmail를 호출한 다음 반환된 로그인 제공업체 중 하나로 로그인하라는 메시지를 표시합니다. Firebase Console의 인증 설정에서 '이메일 주소당 계정 1개' 설정이 사용 설정 상태일 때만 발생하는 오류입니다.
    case FIRAuthErrorCodeEmailAlreadyInUse = 17007
    
    // MARK: 토큰 관련 에러
    /// 맞춤 토큰의 유효성 검사 오류를 나타냅니다.
    case FIRAuthErrorCodeInvalidCustomToken = 17000
    
    /// 로그인한 사용자의 세션 정보를 담고 있는 갱신 토큰이 유효하지 않음을 나타냅니다. 사용자에게 이 기기에서 다시 로그인하라는 메시지를 띄워야 합니다.
    case FIRAuthErrorCodeInvalidUserToken = 17017
    
    /// 현재 사용자의 토큰이 만료되었음을 나타냅니다. 예를 들어 사용자가 다른 기기에서 계정 비밀번호를 변경했을 수 있습니다. 사용자에게 이 기기에서 다시 로그인하라는 메시지를 띄워야 합니다.
    case FIRAuthErrorCodeUserTokenExpired = 17021

}
