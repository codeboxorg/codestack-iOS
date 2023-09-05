// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateSubmissionMutation: GraphQLMutation {
  public static let operationName: String = "CreateSubmission"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation CreateSubmission($languageId: ID!, $problemId: ID!, $sourceCode: String!) {
        createSubmission(
          languageId: $languageId
          problemId: $problemId
          sourceCode: $sourceCode
        ) {
          __typename
          id
          language {
            __typename
            name
            extension
          }
          member {
            __typename
            nickname
          }
          sourceCode
          problem {
            __typename
            id
            title
            context
            languages {
              __typename
              id
              name
              extension
            }
            maxCpuTime
            maxMemory
            tags {
              __typename
              name
            }
          }
          statusCode
          createdAt
        }
      }
      """#
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
        .field("id", CodestackAPI.ID.self),
        .field("language", Language.self),
        .field("member", Member.self),
        .field("sourceCode", String.self),
        .field("problem", Problem.self),
        .field("statusCode", String?.self),
        .field("createdAt", CodestackAPI.DateTime.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var language: Language { __data["language"] }
      public var member: Member { __data["member"] }
      public var sourceCode: String { __data["sourceCode"] }
      public var problem: Problem { __data["problem"] }
      public var statusCode: String? { __data["statusCode"] }
      public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }

      /// CreateSubmission.Language
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

      /// CreateSubmission.Member
      ///
      /// Parent Type: `Member`
      public struct Member: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nickname", String.self),
        ] }

        public var nickname: String { __data["nickname"] }
      }

      /// CreateSubmission.Problem
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
          .field("context", String.self),
          .field("languages", [Language].self),
          .field("maxCpuTime", String.self),
          .field("maxMemory", Double.self),
          .field("tags", [Tag].self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var context: String { __data["context"] }
        public var languages: [Language] { __data["languages"] }
        public var maxCpuTime: String { __data["maxCpuTime"] }
        public var maxMemory: Double { __data["maxMemory"] }
        public var tags: [Tag] { __data["tags"] }

        /// CreateSubmission.Problem.Language
        ///
        /// Parent Type: `Language`
        public struct Language: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", CodestackAPI.ID.self),
            .field("name", String.self),
            .field("extension", String.self),
          ] }

          public var id: CodestackAPI.ID { __data["id"] }
          public var name: String { __data["name"] }
          public var `extension`: String { __data["extension"] }
        }

        /// CreateSubmission.Problem.Tag
        ///
        /// Parent Type: `Tag`
        public struct Tag: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
          ] }

          public var name: String { __data["name"] }
        }
      }
    }
  }
}
