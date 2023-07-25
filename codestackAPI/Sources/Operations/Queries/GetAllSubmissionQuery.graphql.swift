// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllSubmissionQuery: GraphQLQuery {
  public static let operationName: String = "GetAllSubmission"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetAllSubmission($offset: Float, $sort: String, $order: String) {
        getAllSubmission(limit: 10, offset: $offset, sort: $sort, order: $order) {
          __typename
          data {
            __typename
            id
            problemId
            memberId
            languageId
            problem {
              __typename
              title
              context
              solvedMemberCount
            }
          }
          pageInfo {
            __typename
            totalPages
          }
        }
      }
      """#
    ))

  public var offset: GraphQLNullable<Double>
  public var sort: GraphQLNullable<String>
  public var order: GraphQLNullable<String>

  public init(
    offset: GraphQLNullable<Double>,
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
      .field("getAllSubmission", GetAllSubmission.self, arguments: [
        "limit": 10,
        "offset": .variable("offset"),
        "sort": .variable("sort"),
        "order": .variable("order")
      ]),
    ] }

    public var getAllSubmission: GetAllSubmission { __data["getAllSubmission"] }

    /// GetAllSubmission
    ///
    /// Parent Type: `SubmissionPage`
    public struct GetAllSubmission: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.SubmissionPage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("data", [Datum]?.self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var data: [Datum]? { __data["data"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// GetAllSubmission.Datum
      ///
      /// Parent Type: `Submission`
      public struct Datum: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("problemId", Double.self),
          .field("memberId", Double.self),
          .field("languageId", Double.self),
          .field("problem", Problem.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var problemId: Double { __data["problemId"] }
        public var memberId: Double { __data["memberId"] }
        public var languageId: Double { __data["languageId"] }
        public var problem: Problem { __data["problem"] }

        /// GetAllSubmission.Datum.Problem
        ///
        /// Parent Type: `Problem`
        public struct Problem: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("title", String.self),
            .field("context", String.self),
            .field("solvedMemberCount", Double.self),
          ] }

          public var title: String { __data["title"] }
          public var context: String { __data["context"] }
          public var solvedMemberCount: Double { __data["solvedMemberCount"] }
        }
      }

      /// GetAllSubmission.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalPages", Int.self),
        ] }

        public var totalPages: Int { __data["totalPages"] }
      }
    }
  }
}
