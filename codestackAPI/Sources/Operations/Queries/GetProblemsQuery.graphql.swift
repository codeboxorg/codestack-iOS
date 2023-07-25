// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetProblemsQuery: GraphQLQuery {
  public static let operationName: String = "GetProblems"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetProblems($offset: Float, $sort: String, $order: String) {
        getProblems(limit: 10, offset: $offset, sort: $sort, order: $order) {
          __typename
          data {
            __typename
            id
            title
            context
            solvedMemberCount
            tags {
              __typename
              id
              name
            }
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
        .field("data", [Datum]?.self),
      ] }

      public var data: [Datum]? { __data["data"] }

      /// GetProblems.Datum
      ///
      /// Parent Type: `Problem`
      public struct Datum: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("title", String.self),
          .field("context", String.self),
          .field("solvedMemberCount", Double.self),
          .field("tags", [Tag].self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var context: String { __data["context"] }
        public var solvedMemberCount: Double { __data["solvedMemberCount"] }
        public var tags: [Tag] { __data["tags"] }

        /// GetProblems.Datum.Tag
        ///
        /// Parent Type: `Tag`
        public struct Tag: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", CodestackAPI.ID.self),
            .field("name", String.self),
          ] }

          public var id: CodestackAPI.ID { __data["id"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
