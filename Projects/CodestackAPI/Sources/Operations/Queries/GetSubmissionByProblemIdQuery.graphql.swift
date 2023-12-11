// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSubmissionByProblemIdQuery: GraphQLQuery {
  public static let operationName: String = "GetSubmissionByProblemId"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSubmissionByProblemId($offset: Int! = 0, $problemId: Float!) { getSubmissionsByProblemId( limit: 20 offset: $offset order: "asc" problemId: $problemId sort: "id" ) { __typename content { __typename id sourceCode statusCode language { __typename name extension } problem { __typename id title } updatedAt createdAt } } }"#
    ))

  public var offset: Int
  public var problemId: Double

  public init(
    offset: Int = 0,
    problemId: Double
  ) {
    self.offset = offset
    self.problemId = problemId
  }

  public var __variables: Variables? { [
    "offset": offset,
    "problemId": problemId
  ] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getSubmissionsByProblemId", GetSubmissionsByProblemId.self, arguments: [
        "limit": 20,
        "offset": .variable("offset"),
        "order": "asc",
        "problemId": .variable("problemId"),
        "sort": "id"
      ]),
    ] }

    public var getSubmissionsByProblemId: GetSubmissionsByProblemId { __data["getSubmissionsByProblemId"] }

    /// GetSubmissionsByProblemId
    ///
    /// Parent Type: `SubmissionPage`
    public struct GetSubmissionsByProblemId: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.SubmissionPage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("content", [Content]?.self),
      ] }

      public var content: [Content]? { __data["content"] }

      /// GetSubmissionsByProblemId.Content
      ///
      /// Parent Type: `Submission`
      public struct Content: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("sourceCode", String.self),
          .field("statusCode", String?.self),
          .field("language", Language.self),
          .field("problem", Problem.self),
          .field("updatedAt", CodestackAPI.DateTime.self),
          .field("createdAt", CodestackAPI.DateTime.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var sourceCode: String { __data["sourceCode"] }
        public var statusCode: String? { __data["statusCode"] }
        public var language: Language { __data["language"] }
        public var problem: Problem { __data["problem"] }
        public var updatedAt: CodestackAPI.DateTime { __data["updatedAt"] }
        public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }

        /// GetSubmissionsByProblemId.Content.Language
        ///
        /// Parent Type: `Language`
        public struct Language: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("extension", String.self),
          ] }

          public var name: String { __data["name"] }
          public var `extension`: String { __data["extension"] }
        }

        /// GetSubmissionsByProblemId.Content.Problem
        ///
        /// Parent Type: `Problem`
        public struct Problem: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", CodestackAPI.ID.self),
            .field("title", String.self),
          ] }

          public var id: CodestackAPI.ID { __data["id"] }
          public var title: String { __data["title"] }
        }
      }
    }
  }
}
