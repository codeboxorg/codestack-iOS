// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchMeSubmissionHistoryQuery: GraphQLQuery {
  public static let operationName: String = "FetchMeSubmissionHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchMeSubmissionHistory($limit: Int = 100, $offset: Int) { getSubmissions(limit: $limit, offset: $offset) { __typename content { __typename createdAt } pageInfo { __typename ...PageInfoFR } } }"#,
      fragments: [PageInfoFR.self]
    ))

  public var limit: GraphQLNullable<Int>
  public var offset: GraphQLNullable<Int>

  public init(
    limit: GraphQLNullable<Int> = 100,
    offset: GraphQLNullable<Int>
  ) {
    self.limit = limit
    self.offset = offset
  }

  public var __variables: Variables? { [
    "limit": limit,
    "offset": offset
  ] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getSubmissions", GetSubmissions.self, arguments: [
        "limit": .variable("limit"),
        "offset": .variable("offset")
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
          .field("createdAt", CodestackAPI.DateTime.self),
        ] }

        public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }
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
