// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchSearchproblemsQuery: GraphQLQuery {
  public static let operationName: String = "FetchSearchproblems"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchSearchproblems($keyword: String!, $limit: Int! = 10, $order: String! = "asc", $sort: String! = "id") { getSearchProblems(keyword: $keyword, limit: $limit, order: $order, sort: $sort) { __typename content { __typename ...ProblemFR } pageInfo { __typename ...PageInfoFR } } }"#,
      fragments: [LanguageFR.self, PageInfoFR.self, ProblemFR.self, TagFR.self]
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
        .field("pageInfo", PageInfo.self),
      ] }

      public var content: [Content]? { __data["content"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// GetSearchProblems.Content
      ///
      /// Parent Type: `Problem`
      public struct Content: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProblemFR.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var context: String { __data["context"] }
        public var languages: [Language] { __data["languages"] }
        public var tags: [Tag] { __data["tags"] }
        public var accepted: Double { __data["accepted"] }
        public var submission: Double { __data["submission"] }
        public var maxCpuTime: String { __data["maxCpuTime"] }
        public var maxMemory: Double { __data["maxMemory"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var problemFR: ProblemFR { _toFragment() }
        }

        /// GetSearchProblems.Content.Language
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

        /// GetSearchProblems.Content.Tag
        ///
        /// Parent Type: `Tag`
        public struct Tag: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }

          public var id: Double { __data["id"] }
          public var name: String { __data["name"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var tagFR: TagFR { _toFragment() }
          }
        }
      }

      /// GetSearchProblems.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PageInfoFR.self),
        ] }

        public var limit: Int { __data["limit"] }
        public var offset: Int { __data["offset"] }
        public var totalContent: Int { __data["totalContent"] }
        public var totalPage: Int { __data["totalPage"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var pageInfoFR: PageInfoFR { _toFragment() }
        }
      }
    }
  }
}
