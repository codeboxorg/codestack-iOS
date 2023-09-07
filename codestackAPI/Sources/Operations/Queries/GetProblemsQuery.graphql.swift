// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetProblemsQuery: GraphQLQuery {
  public static let operationName: String = "GetProblems"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetProblems($offset: Int, $sort: String, $order: String) {
        getProblems(limit: 10, offset: $offset, sort: $sort, order: $order) {
          __typename
          content {
            __typename
            id
            title
            context
            submission
            accepted
            tags {
              __typename
              id
              name
            }
            languages {
              __typename
              id
              name
              extension
            }
          }
          pageInfo {
            __typename
            offset
            limit
            totalPage
            totalContent
          }
        }
      }
      """#
    ))

  public var offset: GraphQLNullable<Int>
  public var sort: GraphQLNullable<String>
  public var order: GraphQLNullable<String>

  public init(
    offset: GraphQLNullable<Int>,
    sort: GraphQLNullable<String>,
    order: GraphQLNullable<String>
  ) {
    self.offset = offset
    self.sort = sort
    self.order = order
  }

  public var __variables: Variables? { [
    "offset": offset,
    "sort": sort,
    "order": order
  ] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getProblems", GetProblems.self, arguments: [
        "limit": 10,
        "offset": .variable("offset"),
        "sort": .variable("sort"),
        "order": .variable("order")
      ]),
    ] }

    public var getProblems: GetProblems { __data["getProblems"] }

    /// GetProblems
    ///
    /// Parent Type: `ProblemPage`
    public struct GetProblems: CodestackAPI.SelectionSet {
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

      /// GetProblems.Content
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
          .field("submission", Double.self),
          .field("accepted", Double.self),
          .field("tags", [Tag].self),
          .field("languages", [Language].self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var context: String { __data["context"] }
        public var submission: Double { __data["submission"] }
        public var accepted: Double { __data["accepted"] }
        public var tags: [Tag] { __data["tags"] }
        public var languages: [Language] { __data["languages"] }

        /// GetProblems.Content.Tag
        ///
        /// Parent Type: `Tag`
        public struct Tag: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", Double.self),
            .field("name", String.self),
          ] }

          public var id: Double { __data["id"] }
          public var name: String { __data["name"] }
        }

        /// GetProblems.Content.Language
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

      /// GetProblems.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("offset", Int.self),
          .field("limit", Int.self),
          .field("totalPage", Int.self),
          .field("totalContent", Int.self),
        ] }

        public var offset: Int { __data["offset"] }
        public var limit: Int { __data["limit"] }
        public var totalPage: Int { __data["totalPage"] }
        public var totalContent: Int { __data["totalContent"] }
      }
    }
  }
}
