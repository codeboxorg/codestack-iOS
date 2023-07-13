// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ProblemSubmitMutation: GraphQLMutation {
  public static let operationName: String = "ProblemSubmit"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation ProblemSubmit($submit: CreateSubmissionInput!) {
        createSubmission(input: $submit) {
          __typename
          sourceCode
          id
        }
      }
      """#
    ))

  public var submit: CreateSubmissionInput

  public init(submit: CreateSubmissionInput) {
    self.submit = submit
  }

  public var __variables: Variables? { ["submit": submit] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createSubmission", CreateSubmission?.self, arguments: ["input": .variable("submit")]),
    ] }

    public var createSubmission: CreateSubmission? { __data["createSubmission"] }

    /// CreateSubmission
    ///
    /// Parent Type: `Submission`
    public struct CreateSubmission: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("sourceCode", String?.self),
        .field("id", Int?.self),
      ] }

      public var sourceCode: String? { __data["sourceCode"] }
      public var id: Int? { __data["id"] }
    }
  }
}
