// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ProblemsQuery: GraphQLQuery {
  public static let operationName: String = "Problems"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query Problems($pageNum: Int) {
        problems(limit: 20, page: $pageNum) {
          __typename
          content {
            __typename
            id
            title
            submission
            accepted
          }
          pageInfo {
            __typename
            totalPage
          }
        }
      }
      """#
    ))

  public var pageNum: GraphQLNullable<Int>

  public init(pageNum: GraphQLNullable<Int>) {
    self.pageNum = pageNum
  }

  public var __variables: Variables? { ["pageNum": pageNum] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("problems", Problems?.self, arguments: [
        "limit": 20,
        "page": .variable("pageNum")
      ]),
    ] }

    public var problems: Problems? { __data["problems"] }

    /// Problems
    ///
    /// Parent Type: `ProblemPagedResult`
    public struct Problems: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.ProblemPagedResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("content", [Content?]?.self),
        .field("pageInfo", PageInfo?.self),
      ] }

      public var content: [Content?]? { __data["content"] }
      public var pageInfo: PageInfo? { __data["pageInfo"] }

      /// Problems.Content
      ///
      /// Parent Type: `Problem`
      public struct Content: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", Int?.self),
          .field("title", String?.self),
          .field("submission", Int?.self),
          .field("accepted", Int?.self),
        ] }

        public var id: Int? { __data["id"] }
        public var title: String? { __data["title"] }
        public var submission: Int? { __data["submission"] }
        public var accepted: Int? { __data["accepted"] }
      }

      /// Problems.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalPage", Int?.self),
        ] }

        public var totalPage: Int? { __data["totalPage"] }
      }
    }
  }
}
