// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMeSubmissionsQuery: GraphQLQuery {
  public static let operationName: String = "GetMeSubmissions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMeSubmissions { getMe { __typename submissions { __typename id statusCode sourceCode cpuTime memoryUsage createdAt problem { __typename id title } language { __typename name } } } }"#
    ))

  public init() {}

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getMe", GetMe.self),
    ] }

    public var getMe: GetMe { __data["getMe"] }

    /// GetMe
    ///
    /// Parent Type: `Member`
    public struct GetMe: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("submissions", [Submission].self),
      ] }

      public var submissions: [Submission] { __data["submissions"] }

      /// GetMe.Submission
      ///
      /// Parent Type: `Submission`
      public struct Submission: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("statusCode", String?.self),
          .field("sourceCode", String.self),
          .field("cpuTime", Double?.self),
          .field("memoryUsage", Double?.self),
          .field("createdAt", CodestackAPI.DateTime.self),
          .field("problem", Problem.self),
          .field("language", Language.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var statusCode: String? { __data["statusCode"] }
        public var sourceCode: String { __data["sourceCode"] }
        public var cpuTime: Double? { __data["cpuTime"] }
        public var memoryUsage: Double? { __data["memoryUsage"] }
        public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }
        public var problem: Problem { __data["problem"] }
        public var language: Language { __data["language"] }

        /// GetMe.Submission.Problem
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

        /// GetMe.Submission.Language
        ///
        /// Parent Type: `Language`
        public struct Language: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
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
