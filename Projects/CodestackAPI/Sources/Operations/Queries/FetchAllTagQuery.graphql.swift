// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchAllTagQuery: GraphQLQuery {
  public static let operationName: String = "FetchAllTag"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchAllTag($offset: Int) { getAllTag(limit: 10, offset: $offset, sort: "id", order: "asc") { __typename content { __typename ...TagFR } pageInfo { __typename ...PageInfoFR } } }"#,
      fragments: [PageInfoFR.self, TagFR.self]
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
          .fragment(TagFR.self),
        ] }

        public var id: Double { __data["id"] }
        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var tagFR: TagFR { _toFragment() }
        }
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
