// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchSubmissionsQuery: GraphQLQuery {
  public static let operationName: String = "FetchSubmissions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchSubmissions($offset: Int, $sort: String, $order: String) { getSubmissions(limit: 20, offset: $offset, sort: $sort, order: $order) { __typename content { __typename ...SubmissionFR } pageInfo { __typename ...PageInfoFR } } }"#,
      fragments: [LanguageFR.self, PageInfoFR.self, ProblemIdentityFR.self, SubmissionFR.self]
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
          .fragment(SubmissionFR.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var language: Language { __data["language"] }
        public var member: SubmissionFR.Member { __data["member"] }
        public var memoryUsage: Double? { __data["memoryUsage"] }
        public var problem: Problem { __data["problem"] }
        public var sourceCode: String { __data["sourceCode"] }
        public var cpuTime: Double? { __data["cpuTime"] }
        public var statusCode: String? { __data["statusCode"] }
        public var updatedAt: CodestackAPI.DateTime { __data["updatedAt"] }
        public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var submissionFR: SubmissionFR { _toFragment() }
        }

        /// GetSubmissions.Content.Language
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

        /// GetSubmissions.Content.Problem
        ///
        /// Parent Type: `Problem`
        public struct Problem: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }

          public var id: CodestackAPI.ID { __data["id"] }
          public var title: String { __data["title"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var problemIdentityFR: ProblemIdentityFR { _toFragment() }
          }
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
