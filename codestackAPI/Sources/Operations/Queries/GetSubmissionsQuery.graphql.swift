// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSubmissionsQuery: GraphQLQuery {
  public static let operationName: String = "GetSubmissions"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetSubmissions($offset: Int, $sort: String, $order: String) {
        getSubmissions(limit: 20, offset: $offset, sort: $sort, order: $order) {
          __typename
          content {
            __typename
            id
            sourceCode
            statusCode
            problem {
              __typename
              id
              title
            }
            language {
              __typename
              id
              name
              extension
            }
            createdAt
            updatedAt
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
      .field("getSubmissions", GetSubmissions.self, arguments: [
        "limit": 20,
        "offset": .variable("offset"),
        "sort": .variable("sort"),
        "order": .variable("order")
      ]),
    ] }

    public var getSubmissions: GetSubmissions { __data["getSubmissions"] }

    /// GetSubmissions
    ///
    /// Parent Type: `SubmissionPage`
    public struct GetSubmissions: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.SubmissionPage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("content", [Content]?.self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var content: [Content]? { __data["content"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// GetSubmissions.Content
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
          .field("problem", Problem.self),
          .field("language", Language.self),
          .field("createdAt", CodestackAPI.DateTime.self),
          .field("updatedAt", CodestackAPI.DateTime.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var sourceCode: String { __data["sourceCode"] }
        public var statusCode: String? { __data["statusCode"] }
        public var problem: Problem { __data["problem"] }
        public var language: Language { __data["language"] }
        public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }
        public var updatedAt: CodestackAPI.DateTime { __data["updatedAt"] }

        /// GetSubmissions.Content.Problem
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

        /// GetSubmissions.Content.Language
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

      /// GetSubmissions.PageInfo
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
