// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSearchproblemsQuery: GraphQLQuery {
  public static let operationName: String = "GetSearchproblems"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSearchproblems($keyword: String!, $limit: Int! = 10, $order: String! = "asc", $sort: String! = "id") { getSearchProblems(keyword: $keyword, limit: $limit, order: $order, sort: $sort) { __typename content { __typename id title context languages { __typename id name extension } } } }"#
    ))

  public var keyword: String
  public var limit: Int
  public var order: String
  public var sort: String

  public init(
    keyword: String,
    limit: Int = 10,
    order: String = "asc",
    sort: String = "id"
  ) {
    self.keyword = keyword
    self.limit = limit
    self.order = order
    self.sort = sort
  }

  public var __variables: Variables? { [
    "keyword": keyword,
    "limit": limit,
    "order": order,
    "sort": sort
  ] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getSearchProblems", GetSearchProblems.self, arguments: [
        "keyword": .variable("keyword"),
        "limit": .variable("limit"),
        "order": .variable("order"),
        "sort": .variable("sort")
      ]),
    ] }

    public var getSearchProblems: GetSearchProblems { __data["getSearchProblems"] }

    /// GetSearchProblems
    ///
    /// Parent Type: `ProblemPage`
    public struct GetSearchProblems: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.ProblemPage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("content", [Content]?.self),
      ] }

      public var content: [Content]? { __data["content"] }

      /// GetSearchProblems.Content
      ///
      /// Parent Type: `Problem`
      public struct Content: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("title", String.self),
          .field("context", String.self),
          .field("languages", [Language].self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var context: String { __data["context"] }
        public var languages: [Language] { __data["languages"] }

        /// GetSearchProblems.Content.Language
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
      }
    }
  }
}
