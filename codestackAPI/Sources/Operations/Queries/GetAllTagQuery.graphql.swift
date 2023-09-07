// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllTagQuery: GraphQLQuery {
  public static let operationName: String = "GetAllTag"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetAllTag($offset: Int) {
        getAllTag(limit: 10, offset: $offset, sort: "id", order: "asc") {
          __typename
          content {
            __typename
            id
            name
          }
          pageInfo {
            __typename
            totalPage
            totalContent
          }
        }
      }
      """#
    ))

  public var offset: GraphQLNullable<Int>

  public init(offset: GraphQLNullable<Int>) {
    self.offset = offset
  }

  public var __variables: Variables? { ["offset": offset] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getAllTag", GetAllTag.self, arguments: [
        "limit": 10,
        "offset": .variable("offset"),
        "sort": "id",
        "order": "asc"
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
        .field("content", [Content]?.self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var content: [Content]? { __data["content"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// GetAllTag.Content
      ///
      /// Parent Type: `Tag`
      public struct Content: CodestackAPI.SelectionSet {
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

      /// GetAllTag.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalPage", Int.self),
          .field("totalContent", Int.self),
        ] }

        public var totalPage: Int { __data["totalPage"] }
        public var totalContent: Int { __data["totalContent"] }
      }
    }
  }
}
