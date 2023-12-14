// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SubmitSubmissionMutation: GraphQLMutation {
  public static let operationName: String = "SubmitSubmission"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation SubmitSubmission($languageId: ID!, $problemId: ID!, $sourceCode: String!) { createSubmission( languageId: $languageId problemId: $problemId sourceCode: $sourceCode ) { __typename ...SubmissionFR } }"#,
      fragments: [LanguageFR.self, ProblemIdentityFR.self, SubmissionFR.self]
    ))

  public var languageId: ID
  public var problemId: ID
  public var sourceCode: String

  public init(
    languageId: ID,
    problemId: ID,
    sourceCode: String
  ) {
    self.languageId = languageId
    self.problemId = problemId
    self.sourceCode = sourceCode
  }

  public var __variables: Variables? { [
    "languageId": languageId,
    "problemId": problemId,
    "sourceCode": sourceCode
  ] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createSubmission", CreateSubmission.self, arguments: [
        "languageId": .variable("languageId"),
        "problemId": .variable("problemId"),
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
        .fragment(SubmissionFR.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var language: Language { __data["language"] }
      public var member: SubmissionFR.Member { __data["member"] }
      public var memoryUsage: Double? { __data["memoryUsage"] }
      public var problem: Problem { __data["problem"] }
      public var sourceCode: String { __data["sourceCode"] }
      public var cpuTime: Double? { __data["cpuTime"] }
      public var statusCode: String? { __data["statusCode"] }
      public var updatedAt: CodestackAPI.DateTime { __data["updatedAt"] }
      public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var submissionFR: SubmissionFR { _toFragment() }
      }

      /// CreateSubmission.Language
      ///
      /// Parent Type: `Language`
      public struct Language: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }

        public var id: CodestackAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var `extension`: String { __data["extension"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var languageFR: LanguageFR { _toFragment() }
        }
      }

      /// CreateSubmission.Problem
      ///
      /// Parent Type: `Problem`
      public struct Problem: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var problemIdentityFR: ProblemIdentityFR { _toFragment() }
        }
      }
    }
  }
}
