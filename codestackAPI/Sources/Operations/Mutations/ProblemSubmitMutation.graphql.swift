// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ProblemSubmitMutation: GraphQLMutation {
  public static let operationName: String = "ProblemSubmit"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation ProblemSubmit($problemId: Float!, $languageId: Float!, $sourceCode: String!) {
        createSubmission(
          problemId: $problemId
          languageId: $languageId
          sourceCode: $sourceCode
        ) {
          __typename
          id
          sourceCode
        }
      }
      """#
    ))

  public var problemId: Double
  public var languageId: Double
  public var sourceCode: String

  public init(
    problemId: Double,
    languageId: Double,
    sourceCode: String
  ) {
    self.problemId = problemId
    self.languageId = languageId
    self.sourceCode = sourceCode
  }

  public var __variables: Variables? { [
    "problemId": problemId,
    "languageId": languageId,
    "sourceCode": sourceCode
  ] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createSubmission", CreateSubmission.self, arguments: [
        "problemId": .variable("problemId"),
        "languageId": .variable("languageId"),
        "sourceCode": .variable("sourceCode")
      ]),
    ] }

    public var createSubmission: CreateSubmission { __data["createSubmission"] }

    /// CreateSubmission
    ///
    /// Parent Type: `Submission`
    public struct CreateSubmission: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", CodestackAPI.ID.self),
        .field("sourceCode", String.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var sourceCode: String { __data["sourceCode"] }
    }
  }
}
