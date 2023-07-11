// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CreateSubmissionInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    problemId: GraphQLNullable<Int> = nil,
    languageId: GraphQLNullable<Int> = nil,
    sourceCode: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "problemId": problemId,
      "languageId": languageId,
      "sourceCode": sourceCode
    ])
  }

  public var problemId: GraphQLNullable<Int> {
    get { __data["problemId"] }
    set { __data["problemId"] = newValue }
  }

  public var languageId: GraphQLNullable<Int> {
    get { __data["languageId"] }
    set { __data["languageId"] = newValue }
  }

  public var sourceCode: GraphQLNullable<String> {
    get { __data["sourceCode"] }
    set { __data["sourceCode"] = newValue }
  }
}
