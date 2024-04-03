//
//  JuageZeroSubmission.swift
//  Domain
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct JudgeZeroSubmissionVO: Codable {
    // TOKEN 값
    public var id: String
    
    // (표준 출력): 프로그램 실행 후의 표준 출력입니다.
    public var stdout: String
  
    // (표준 에러): 프로그램 실행 후의 표준 에러입니다.
    public var stderr: String
  
    // (컴파일 출력): 컴파일 후의 출력 내용입니다.
    public let compile_output: String
    public let time: String
    public let memory: Double
    
    // (상태): 제출 상태입니다.
    public let status: JudgeZeroStatus

    // (완료 일시): 제출이 처리된 일시입니다. 처리 중인 경우 null로 설정됩니다.
    public let finished_at: String
    
    public init(id: String,
                stdout: String,
                stderr: String,
                compile_output: String,
                time: String,
                memory: Double,
                status: JudgeZeroStatus,
                finished_at: String)
    {
        self.id = id
        self.stdout = stdout
        self.stderr = stderr
        self.compile_output = compile_output
        self.time = time
        self.memory = memory
        self.status = status
        self.finished_at = finished_at
    }
}

extension JudgeZeroSubmissionVO {
    public func toSubmissionVO(query: JZQuery) -> SubmissionVO {
        .init(id: self.id,
              sourceCode: query.code,
              problem: .init(id: query.problem.id, title: query.problem.title),
              member: .init(username: query.nickname),
              language: query.language,
              statusCode: self.status.mapJSONToSolveStatus(),
              cpuTime: Double(self.time) ?? 8,
              memoryUsage: self.memory,
              createdAt: self.finished_at)
    }
    
    public func isProccessing() -> Bool {
        let solveStatus = self.status.mapJSONToSolveStatus()
        switch solveStatus {
        case .PROCEESING:
            return true
        default:
            return false
        }
    }
}

// MARK: 안쓰는 필드 주석 처리, 추후 필드 도입 가능성 있음
// 프로그램에 대한 입력입니다. 입력이 필요하지 않을 경우 null로 설정됩니다.
// let stdin: String

//    // 프로그램의 예상 출력입니다. stdout과 비교할 때 사용됩니다. 프로그램의 출력이 예상 출력과 일치하는지 확인하는 데 사용됩니다.
//    let expected_output: String
//
//    // (CPU 시간 제한): 프로그램의 실행을 위한 CPU 시간 제한입니다. 단위는 초입니다.
//    let cpu_time_limit: Double
//
//    // (추가 CPU 시간): CPU 시간 제한을 초과할 경우 프로그램을 종료하기 전에 기다리는 추가 시간입니다. 이로 인해 실제 실행 시간이 제한을 약간 초과할 수 있습니다.
//    let cpu_extra_time: Double
//
//    // (실행 시간 제한): 프로그램의 전체 실행 시간 제한입니다. CPU 시간 제한과 달리 프로그램의 시작부터 종료까지 측정합니다.
//    let wall_time_limit: Double
//
//    // (메모리 제한): 프로그램이 사용할 수 있는 메모리의 한도입니다. 단위는 킬로바이트(KB)입니다.
//    let memory_limit: Double
//
//    // (스택 제한): 프로세스 스택의 최대 크기 제한입니다. 단위는 킬로바이트(KB)입니다.
//    let stack_limit: Int
//
//    // (최대 파일 크기): 프로그램이 생성하거나 수정할 수 있는 최대 파일 크기 제한입니다.
//    let max_file_size: Int
//

//    // (메시지): 제출 상태가 내부 오류인 경우 Judge0에서 제공하는 메시지 또는 isolate에서의 상태 메시지입니다.
    //var message: String?

//    // (생성 일시): 제출이 생성된 일시입니다.
//    let created_at: String
//
//
//    // (토큰): 특정 제출을 가져오기 위해 사용되는 고유 제출 토큰입니다.
//    let token: String
//
//    // (실행 시간): 프로그램의 실행 시간입니다.
//    let time: String
//
//    // (월 시간): 프로그램의 전체 실행 시간입니다. 실행 시간보다 크거나 같습니다.
//    let wall_time: String
//
//    // (메모리 사용량): 프로그램 실행 후 사용된 메모리 양입니다.
//    let memory: String
// (종료 코드): 프로그램의 종료 코드입니다.
// let exit_code: String

// (시그널 코드): 프로그램이 종료되기 전에 받은 시그널 코드입니다.
// let exit_signal: String

// (콜백 URL): Judge0가 제출 후 PUT 요청을 보낼 URL입니다.
// let callback_url: String

// (실행 횟수): 프로그램을 몇 번 실행하고 시간 및 메모리를 평균 내어 반환할지를 설정합니다.
// let number_of_runs: Int

// (추가 파일): 다중 파일 프로그램에 필요한 추가 파일(예: .zip)의 Base64 인코딩된 내용입니다.
// let additional_files: String

// (최대 프로세스 및 스레드 수): 프로그램이 생성할 수 있는 최대 프로세스 또는 스레드 수입니다.
// let max_processes_and_or_threads: Int

// (프로세스 및 스레드별 시간 제한 사용 여부): 각 프로세스 및 스레드에 대해 별도의 CPU 시간 제한을 사용할지 여부를 설정합니다.
// let enable_per_process_and_thread_time_limit: Bool

// (프로세스 및 스레드별 메모리 제한 사용 여부): 각 프로세스 및 스레드에 대해 별도의 메모리 제한을 사용할지 여부를 설정합니다.
// let enable_per_process_and_thread_memory_limit: Bool

// (stderr를 stdout으로 리다이렉션 여부): stderr를 stdout으로 리다이렉션할지 여부를 설정합니다.
// let redirect_stderr_to_stdout: Bool

// 프로그램을 위한 커맨드 라인 인자입니다. 최대 512자까지 설정할 수 있습니다.
// let command_line_arguments: String

// 컴파일러를 위한 옵션(예: 컴파일러 플래그)입니다. 최대 512자까지 설정할 수 있습니다.
// let compiler_options: String

// (네트워크 사용 여부): 프로그램이 네트워크에 액세스할 수 있는지 여부를 설정합니다.
// let enable_network: Bool
