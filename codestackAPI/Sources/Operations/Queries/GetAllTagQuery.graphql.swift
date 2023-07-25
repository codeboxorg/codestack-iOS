// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllTagQuery: GraphQLQuery {
  public static let operationName: String = "GetAllTag"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetAllTag {
        getAllTag(limit: 10, offset: 0) {
          __typename
          data {
            __typename
            id
            name
          }
          pageInfo {
            __typename
            offset
            limit
            totalPages
          }
        }
      }
      """#
    ))

  public init() {}

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getAllTag", GetAllTag.self, arguments: [
        "limit": 10,
        "offset": 0
      ]),
    ] }

    public var getAllTag: GetAllTag { __data["getAllTag"] }

    /// GetAllTag
    ///
    /// Parent Type: `TagPage`
    public struct GetAllTag: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.TagPage }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("data", [Datum]?.self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var data: [Datum]? { __data["data"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// GetAllTag.Datum
      ///
      /// Parent Type: `Tag`
      public struct Datum: CodestackAPI.SelectionSet {
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

      /// GetAllTag.PageInfo
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
          .field("totalPages", Int.self),
        ] }

        public var offset: Int { __data["offset"] }
        public var limit: Int { __data["limit"] }
        public var totalPages: Int { __data["totalPages"] }
      }
    }
  }
}
